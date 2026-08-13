using System.Globalization;
using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Models;
using Locker.Backend.Domain.Entities;
using Locker.Backend.Domain.Enums;
using MediatR;
using Microsoft.Extensions.Logging;

namespace Locker.Backend.Application.Features.Wallet.Commands.SepayProcessIpn;

public record SepayProcessIpnCommand(
    SepayIpnRequest Request
) : IRequest<SepayProcessIpnResponse>;

public record SepayProcessIpnResponse(
    bool Success,
    string Message,
    Guid? PaymentId = null
);

public class SepayProcessIpnCommandHandler
    : IRequestHandler<SepayProcessIpnCommand, SepayProcessIpnResponse>
{
    private readonly IPaymentRepository _paymentRepository;
    private readonly IWalletTransactionRepository _walletTransactionRepository;
    private readonly ILogger<SepayProcessIpnCommandHandler> _logger;

    public SepayProcessIpnCommandHandler(
        IPaymentRepository paymentRepository,
        IWalletTransactionRepository walletTransactionRepository,
        ILogger<SepayProcessIpnCommandHandler> logger)
    {
        _paymentRepository = paymentRepository;
        _walletTransactionRepository = walletTransactionRepository;
        _logger = logger;
    }

    public async Task<SepayProcessIpnResponse> Handle(
        SepayProcessIpnCommand request,
        CancellationToken cancellationToken)
    {
        var ipn = request.Request;

        _logger.LogInformation(
            "SePay IPN received. NotificationType={NotificationType}, OrderStatus={OrderStatus}, TransactionStatus={TransactionStatus}, Invoice={Invoice}, OrderAmount={OrderAmount}, TransactionAmount={TransactionAmount}",
            ipn.NotificationType,
            ipn.Order.OrderStatus,
            ipn.Transaction.TransactionStatus,
            ipn.Order.OrderInvoiceNumber,
            ipn.Order.OrderAmount,
            ipn.Transaction.TransactionAmount
        );

        // 1. Kiểm tra thanh toán thành công
        if (!IsPaidNotification(ipn))
        {
            _logger.LogWarning(
                "SePay IPN ignored because payment is not paid. NotificationType={NotificationType}, OrderStatus={OrderStatus}, TransactionStatus={TransactionStatus}",
                ipn.NotificationType,
                ipn.Order.OrderStatus,
                ipn.Transaction.TransactionStatus
            );

            return new SepayProcessIpnResponse(
                true,
                "IPN ignored because it is not a paid notification."
            );
        }

        // 2. Parse Payment ID
        if (!TryParseTopUpInvoiceNumber(
                ipn.Order.OrderInvoiceNumber,
                out var paymentId))
        {
            _logger.LogError(
                "Invalid SePay invoice number: {Invoice}",
                ipn.Order.OrderInvoiceNumber
            );

            return new SepayProcessIpnResponse(
                false,
                "Invalid order invoice number."
            );
        }

        _logger.LogInformation(
            "SePay PaymentId parsed: {PaymentId}",
            paymentId
        );

        // 3. Tìm Payment
        var payment = await _paymentRepository.GetByIdAsync(
            paymentId,
            cancellationToken
        );

        if (payment == null)
        {
            _logger.LogError(
                "Payment not found: {PaymentId}",
                paymentId
            );

            return new SepayProcessIpnResponse(
                false,
                "Payment not found.",
                paymentId
            );
        }

        _logger.LogInformation(
            "Payment found. PaymentId={PaymentId}, UserId={UserId}, Amount={Amount}, Status={Status}",
            payment.Id,
            payment.UserId,
            payment.Amount,
            payment.Status
        );

        // 4. Kiểm tra method
        if (!string.Equals(
                payment.Method,
                "sepay",
                StringComparison.OrdinalIgnoreCase))
        {
            _logger.LogError(
                "Payment method mismatch. Expected=sepay, Actual={Method}",
                payment.Method
            );

            return new SepayProcessIpnResponse(
                false,
                "Payment method mismatch.",
                paymentId
            );
        }

        // 5. Kiểm tra amount
        if (!IsSameAmount(
                payment.Amount,
                ipn.Order.OrderAmount,
                ipn.Transaction.TransactionAmount))
        {
            _logger.LogError(
                "Payment amount mismatch. Expected={Expected}, OrderAmount={OrderAmount}, TransactionAmount={TransactionAmount}",
                payment.Amount,
                ipn.Order.OrderAmount,
                ipn.Transaction.TransactionAmount
            );

            return new SepayProcessIpnResponse(
                false,
                "Payment amount mismatch.",
                paymentId
            );
        }

        // 6. Chống cộng tiền 2 lần
        if (payment.Status == PaymentStatus.Completed)
        {
            _logger.LogInformation(
                "Payment already completed: {PaymentId}",
                paymentId
            );

            return new SepayProcessIpnResponse(
                true,
                "Payment already processed.",
                paymentId
            );
        }

        if (payment.Status != PaymentStatus.Pending)
        {
            _logger.LogWarning(
                "Payment is not pending. PaymentId={PaymentId}, Status={Status}",
                paymentId,
                payment.Status
            );

            return new SepayProcessIpnResponse(
                false,
                "Payment is not pending.",
                paymentId
            );
        }

        // 7. Transaction ID
        var gatewayTransactionId = FirstNotEmpty(
            ipn.Transaction.TransactionId,
            ipn.Transaction.Id,
            ipn.Order.OrderId
        );

        // 8. Kiểm tra wallet transaction đã tồn tại chưa
        var existingWalletTransaction =
            await _walletTransactionRepository.FindOneAsync(
                x =>
                    x.ReferenceId == payment.Id.ToString() &&
                    x.Type == TransactionType.TopUp,
                cancellationToken
            );

        // 9. Update Payment
        payment.Status = PaymentStatus.Completed;
        payment.TransactionId = gatewayTransactionId;
        payment.PaidAt =
            ParseSepayDate(ipn.Transaction.TransactionDate)
            ?? DateTime.UtcNow;

        await _paymentRepository.UpdateAsync(
            payment,
            cancellationToken
        );

        _logger.LogInformation(
            "Payment marked COMPLETED. PaymentId={PaymentId}, TransactionId={TransactionId}",
            paymentId,
            gatewayTransactionId
        );

        // 10. Tạo WalletTransaction
        if (existingWalletTransaction == null)
        {
            var walletTransaction = new WalletTransaction
            {
                UserId = payment.UserId,
                Amount = payment.Amount,
                Type = TransactionType.TopUp,
                Status = TransactionStatus.Completed,
                Description =
                    $"Nạp tiền ví qua SePay. Mã GD: {gatewayTransactionId}",
                ReferenceId = payment.Id.ToString(),
                CreatedAt = payment.PaidAt ?? DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };

            await _walletTransactionRepository.CreateAsync(
                walletTransaction,
                cancellationToken
            );

            _logger.LogInformation(
                "WalletTransaction CREATED. UserId={UserId}, Amount={Amount}, PaymentId={PaymentId}",
                payment.UserId,
                payment.Amount,
                paymentId
            );
        }
        else
        {
            _logger.LogInformation(
                "WalletTransaction already exists. PaymentId={PaymentId}",
                paymentId
            );
        }

        _logger.LogInformation(
            "========== SEPAY PAYMENT SUCCESS ==========" +
            " PaymentId={PaymentId}, UserId={UserId}, Amount={Amount}",
            paymentId,
            payment.UserId,
            payment.Amount
        );

        return new SepayProcessIpnResponse(
            true,
            "Payment updated.",
            paymentId
        );
    }

    private static bool IsPaidNotification(SepayIpnRequest ipn)
    {
        return string.Equals(
                   ipn.NotificationType,
                   "ORDER_PAID",
                   StringComparison.OrdinalIgnoreCase)
               &&
               string.Equals(
                   ipn.Order.OrderStatus,
                   "CAPTURED",
                   StringComparison.OrdinalIgnoreCase)
               &&
               string.Equals(
                   ipn.Transaction.TransactionStatus,
                   "APPROVED",
                   StringComparison.OrdinalIgnoreCase);
    }

    private static bool IsSameAmount(
        decimal expectedAmount,
        params string[] amountValues)
    {
        foreach (var amountValue in amountValues)
        {
            if (string.IsNullOrWhiteSpace(amountValue))
                continue;

            if (decimal.TryParse(
                    amountValue,
                    NumberStyles.Number,
                    CultureInfo.InvariantCulture,
                    out var parsed)
                &&
                decimal.Round(parsed, 0)
                    == decimal.Round(expectedAmount, 0))
            {
                return true;
            }
        }

        return false;
    }

    private static DateTime? ParseSepayDate(string? value)
    {
        if (DateTime.TryParseExact(
                value,
                "yyyy-MM-dd HH:mm:ss",
                CultureInfo.InvariantCulture,
                DateTimeStyles.AssumeLocal,
                out var parsed))
        {
            return parsed.ToUniversalTime();
        }

        return null;
    }

    private static string FirstNotEmpty(params string[] values)
    {
        return values.FirstOrDefault(
                   value => !string.IsNullOrWhiteSpace(value))
               ?? Guid.NewGuid().ToString("N");
    }

    private static bool TryParseTopUpInvoiceNumber(
        string? invoiceNumber,
        out Guid paymentId)
    {
        paymentId = Guid.Empty;

        const string prefix = "TOPUP_";

        if (string.IsNullOrWhiteSpace(invoiceNumber) ||
            !invoiceNumber.StartsWith(
                prefix,
                StringComparison.OrdinalIgnoreCase))
        {
            return false;
        }

        return Guid.TryParseExact(
            invoiceNumber[prefix.Length..],
            "N",
            out paymentId
        );
    }
}