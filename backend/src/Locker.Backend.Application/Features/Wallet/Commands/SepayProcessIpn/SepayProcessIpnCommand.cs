using System.Globalization;
using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Models;
using Locker.Backend.Domain.Entities;
using Locker.Backend.Domain.Enums;
using MediatR;

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
    private readonly IRealtimeNotificationService _notificationService;

    public SepayProcessIpnCommandHandler(
        IPaymentRepository paymentRepository,
        IWalletTransactionRepository walletTransactionRepository,
        IRealtimeNotificationService notificationService)
    {
        _paymentRepository = paymentRepository;
        _walletTransactionRepository = walletTransactionRepository;
        _notificationService = notificationService;
    }

    public async Task<SepayProcessIpnResponse> Handle(
        SepayProcessIpnCommand request,
        
        CancellationToken cancellationToken)
    {
        var ipn = request.Request;

        Console.WriteLine("========== SEPAY HANDLER ==========");

        Console.WriteLine(
            $"NotificationType: {ipn.NotificationType}");

        Console.WriteLine(
            $"InvoiceNumber: {ipn.Order?.OrderInvoiceNumber}");

        Console.WriteLine(
            $"OrderStatus: {ipn.Order?.OrderStatus}");

        Console.WriteLine(
            $"OrderAmount: {ipn.Order?.OrderAmount}");

        Console.WriteLine(
            $"TransactionStatus: {ipn.Transaction?.TransactionStatus}");

        Console.WriteLine(
            $"TransactionAmount: {ipn.Transaction?.TransactionAmount}");

        Console.WriteLine(
            $"TransactionId: {ipn.Transaction?.TransactionId}");

        Console.WriteLine(
            $"TransactionDate: {ipn.Transaction?.TransactionDate}");

        Console.WriteLine("==================================");

        // 1. Chỉ xử lý ORDER_PAID
        if (!string.Equals(
                ipn.NotificationType,
                "ORDER_PAID",
                StringComparison.OrdinalIgnoreCase))
        {
            return new SepayProcessIpnResponse(
                true,
                $"Ignored notification type: {ipn.NotificationType}");
        }

        // 2. Order phải CAPTURED
        if (!string.Equals(
                ipn.Order?.OrderStatus,
                "CAPTURED",
                StringComparison.OrdinalIgnoreCase))
        {
            return new SepayProcessIpnResponse(
                true,
                $"Order is not CAPTURED. Status={ipn.Order?.OrderStatus}");
        }

        // 3. Transaction phải APPROVED
        if (!string.Equals(
                ipn.Transaction?.TransactionStatus,
                "APPROVED",
                StringComparison.OrdinalIgnoreCase))
        {
            return new SepayProcessIpnResponse(
                true,
                $"Transaction is not APPROVED. Status={ipn.Transaction?.TransactionStatus}");
        }

        // 4. Parse invoice number
        if (!TryParseTopUpInvoiceNumber(
                ipn.Order.OrderInvoiceNumber,
                out var paymentId))
        {
            return new SepayProcessIpnResponse(
                false,
                $"Invalid invoice number: {ipn.Order.OrderInvoiceNumber}");
        }

        Console.WriteLine(
            $"PaymentId extracted: {paymentId}");

        // 5. Tìm Payment
        var payment = await _paymentRepository.GetByIdAsync(
            paymentId,
            cancellationToken);

        if (payment == null)
        {
            return new SepayProcessIpnResponse(
                false,
                $"Payment not found: {paymentId}",
                paymentId);
        }

        Console.WriteLine(
            $"Payment found: Id={payment.Id}, " +
            $"Amount={payment.Amount}, " +
            $"Status={payment.Status}");

        // 6. Kiểm tra method
        if (!string.Equals(
                payment.Method,
                "sepay",
                StringComparison.OrdinalIgnoreCase))
        {
            return new SepayProcessIpnResponse(
                false,
                $"Payment method mismatch: {payment.Method}",
                paymentId);
        }

        // 7. Kiểm tra amount
        if (!IsSameAmount(
                payment.Amount,
                ipn.Order.OrderAmount,
                ipn.Transaction.TransactionAmount))
        {
            return new SepayProcessIpnResponse(
                false,
                $"Payment amount mismatch. " +
                $"Expected={payment.Amount}, " +
                $"Order={ipn.Order.OrderAmount}, " +
                $"Transaction={ipn.Transaction.TransactionAmount}",
                paymentId);
        }

        // 8. Chống xử lý trùng bằng atomic transition Pending -> Completed
        var gatewayTransactionId =
            FirstNotEmpty(
                ipn.Transaction.TransactionId,
                ipn.Transaction.Id,
                ipn.Order.OrderId);

        var paidAt =
            ParseSepayDate(ipn.Transaction.TransactionDate)
            ?? DateTime.UtcNow;

        var completedPayment =
            await _paymentRepository.TryCompletePendingAsync(
                payment.Id,
                gatewayTransactionId,
                paidAt,
                cancellationToken);

        if (completedPayment is null)
        {
            // Caller này không phải người thắng — kiểm tra trạng thái hiện tại
            var refreshed = await _paymentRepository.GetByIdAsync(
                payment.Id,
                cancellationToken);

            if (refreshed is not null
                && refreshed.Status == PaymentStatus.Completed)
            {
                return new SepayProcessIpnResponse(
                    true,
                    "Payment already processed.",
                    paymentId);
            }

            return new SepayProcessIpnResponse(
                false,
                $"Payment is not pending. Status={refreshed?.Status}",
                paymentId);
        }

        // 9. Kiểm tra WalletTransaction (sau khi đã atomic claim xong)
        var existingWalletTransaction =
            await _walletTransactionRepository.FindOneAsync(
                x =>
                    x.ReferenceId == completedPayment.Id.ToString()
                    && x.Type == TransactionType.TopUp,
                cancellationToken);

        // 10. Tạo WalletTransaction
        if (existingWalletTransaction == null)
        {
            var walletTransaction = new WalletTransaction
            {
                UserId = completedPayment.UserId,

                Amount = completedPayment.Amount,

                Type = TransactionType.TopUp,

                Status = TransactionStatus.Completed,

                Description =
                    $"Nap tien vi qua SePay. " +
                    $"Ma GD: {gatewayTransactionId}",

                ReferenceId = completedPayment.Id.ToString(),

                CreatedAt =
                    completedPayment.PaidAt ?? DateTime.UtcNow,

                UpdatedAt = DateTime.UtcNow
            };

            await _walletTransactionRepository.CreateAsync(
                walletTransaction,
                cancellationToken);
        }

        Console.WriteLine(
            $"SEPAY PAYMENT COMPLETED: " +
            $"PaymentId={completedPayment.Id}, " +
            $"TransactionId={gatewayTransactionId}");

        await _notificationService.NotifyUserAsync(
            completedPayment.UserId,
            "Nạp tiền thành công",
            $"Ví E-Box Pay của bạn đã được cộng {completedPayment.Amount:N0} đ.",
            cancellationToken);

        return new SepayProcessIpnResponse(
            true,
            "Payment updated successfully.",
            paymentId);
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
                    out var parsed))
            {
                if (decimal.Round(parsed, 0) ==
                    decimal.Round(expectedAmount, 0))
                {
                    return true;
                }
            }
        }

        return false;
    }

    private static DateTime? ParseSepayDate(string? value)
    {
        if (string.IsNullOrWhiteSpace(value))
            return null;

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

        if (string.IsNullOrWhiteSpace(invoiceNumber))
            return false;

        if (!invoiceNumber.StartsWith(
                prefix,
                StringComparison.OrdinalIgnoreCase))
            return false;

        return Guid.TryParseExact(
            invoiceNumber[prefix.Length..],
            "N",
            out paymentId);
    }
}