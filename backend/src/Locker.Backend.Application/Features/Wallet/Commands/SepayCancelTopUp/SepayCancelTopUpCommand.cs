using System;
using System.Threading;
using System.Threading.Tasks;
using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Models;
using Locker.Backend.Domain.Entities;
using Locker.Backend.Domain.Enums;
using MediatR;

namespace Locker.Backend.Application.Features.Wallet.Commands.SepayCancelTopUp;

public record SepayCancelTopUpCommand(
    Guid PaymentId,
    Guid UserId
) : IRequest<SepayCancelTopUpResponse>;

public record SepayCancelTopUpResponse(
    bool Success,
    string Message,
    PaymentStatus? NewStatus = null,
    Guid? PaymentId = null
);

public class SepayCancelTopUpCommandHandler
    : IRequestHandler<SepayCancelTopUpCommand, SepayCancelTopUpResponse>
{
    private readonly IPaymentRepository _paymentRepository;
    private readonly IPaymentRealtimeNotifier _paymentRealtimeNotifier;
    private readonly IWalletTransactionRepository _walletTransactionRepository;

    public SepayCancelTopUpCommandHandler(
        IPaymentRepository paymentRepository,
        IPaymentRealtimeNotifier paymentRealtimeNotifier,
        IWalletTransactionRepository walletTransactionRepository)
    {
        _paymentRepository = paymentRepository;
        _paymentRealtimeNotifier = paymentRealtimeNotifier;
        _walletTransactionRepository = walletTransactionRepository;
    }

    public async Task<SepayCancelTopUpResponse> Handle(
        SepayCancelTopUpCommand request,
        CancellationToken cancellationToken)
    {
        // 1. Ownership + lookup
        var payment = await _paymentRepository.GetByIdAsync(request.PaymentId, cancellationToken);

        if (payment is null)
        {
            return new SepayCancelTopUpResponse(
                false,
                "Payment not found.",
                PaymentId: request.PaymentId);
        }

        if (payment.UserId != request.UserId)
        {
            return new SepayCancelTopUpResponse(
                false,
                "You do not own this payment.",
                PaymentId: request.PaymentId);
        }

        // 2. Already terminal → idempotent reply
        if (payment.Status == PaymentStatus.Cancelled)
        {
            return new SepayCancelTopUpResponse(
                true,
                "Payment already cancelled.",
                PaymentStatus.Cancelled,
                payment.Id);
        }

        if (payment.Status == PaymentStatus.Completed)
        {
            return new SepayCancelTopUpResponse(
                false,
                "Payment already completed. Cannot cancel.",
                PaymentStatus.Completed,
                payment.Id);
        }

        if (payment.Status == PaymentStatus.Refunded)
        {
            return new SepayCancelTopUpResponse(
                false,
                "Payment already refunded. Cannot cancel.",
                PaymentStatus.Refunded,
                payment.Id);
        }

        if (payment.Status != PaymentStatus.Pending)
        {
            return new SepayCancelTopUpResponse(
                false,
                $"Payment is in an invalid state: {payment.Status}.",
                payment.Status,
                payment.Id);
        }

        // 3. Atomic transition Pending → Cancelled
        //    Race-safe: nếu SePay IPN tới cùng lúc, TryCompletePendingAsync cũng filter
        //    Status == Pending, nên chỉ 1 trong 2 transitions thắng.
        var cancelled = await _paymentRepository.TryCancelPendingAsync(payment.Id, cancellationToken);

        if (cancelled is null)
        {
            // Đã bị concurrent transition (IPN complete hoặc timeout fail).
            var refreshed = await _paymentRepository.GetByIdAsync(payment.Id, cancellationToken);
            return new SepayCancelTopUpResponse(
                false,
                $"Payment could not be cancelled. Current status: {refreshed?.Status}.",
                refreshed?.Status,
                payment.Id);
        }

        // 4. Ghi WalletTransaction Cancelled để user thấy trong lịch sử ví.
        //    Idempotent: nếu đã có record Cancelled cho payment này thì không tạo lại.
        var existingCancelled = await _walletTransactionRepository.GetByUserIdAsync(cancelled.UserId, cancellationToken);
        var alreadyRecorded = existingCancelled.Any(t =>
            t.ReferenceId == cancelled.Id.ToString() && t.Status == TransactionStatus.Cancelled);

        if (!alreadyRecorded)
        {
            var walletTransaction = new WalletTransaction
            {
                UserId = cancelled.UserId,
                Amount = cancelled.Amount,
                Type = TransactionType.TopUp,
                Status = TransactionStatus.Cancelled,
                Description = $"Huỷ giao dịch nạp tiền #{cancelled.Id:N}",
                ReferenceId = cancelled.Id.ToString(),
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };
            await _walletTransactionRepository.CreateAsync(walletTransaction, cancellationToken);
        }

        // 5. Notify realtime → FE nhận event, đóng modal, show toast
        await _paymentRealtimeNotifier.NotifyStatusChangedAsync(
            cancelled.UserId,
            new PaymentStatusChangedEvent
            {
                PaymentId = cancelled.Id,
                Amount = cancelled.Amount,
                Status = cancelled.Status.ToString(),
            },
            cancellationToken);

        return new SepayCancelTopUpResponse(
            true,
            "Payment cancelled.",
            PaymentStatus.Cancelled,
            cancelled.Id);
    }
}
