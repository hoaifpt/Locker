using System;
using System.Globalization;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Models;
using Locker.Backend.Domain.Entities;
using Locker.Backend.Domain.Enums;
using MediatR;
using Microsoft.Extensions.Options;

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
    private readonly SepaySettings _sepaySettings;
    private readonly IPaymentRepository _paymentRepository;
    private readonly IWalletTransactionRepository _walletTransactionRepository;
    private readonly IRealtimeNotificationService _notificationService;
    private readonly IPaymentRealtimeNotifier _paymentRealtimeNotifier;

    public SepayProcessIpnCommandHandler(
        IOptions<SepaySettings> sepaySettings,
        IPaymentRepository paymentRepository,
        IWalletTransactionRepository walletTransactionRepository,
        IRealtimeNotificationService notificationService,
        IPaymentRealtimeNotifier paymentRealtimeNotifier)
    {
        _sepaySettings = sepaySettings.Value;
        _paymentRepository = paymentRepository;
        _walletTransactionRepository = walletTransactionRepository;
        _notificationService = notificationService;
        _paymentRealtimeNotifier = paymentRealtimeNotifier;
    }

    public async Task<SepayProcessIpnResponse> Handle(
        SepayProcessIpnCommand request,
        CancellationToken cancellationToken)
    {
        var ipn = request.Request;

        Console.WriteLine("========== SEPAY HANDLER ==========");
        Console.WriteLine($"NotificationType: {ipn.NotificationType}");
        Console.WriteLine($"InvoiceNumber: {ipn.Order?.OrderInvoiceNumber}");
        Console.WriteLine($"OrderStatus: {ipn.Order?.OrderStatus}");
        Console.WriteLine($"OrderAmount: {ipn.Order?.OrderAmount}");
        Console.WriteLine($"TransactionStatus: {ipn.Transaction?.TransactionStatus}");
        Console.WriteLine($"TransactionAmount: {ipn.Transaction?.TransactionAmount}");
        Console.WriteLine($"TransactionId: {ipn.Transaction?.TransactionId}");
        Console.WriteLine($"TransactionDate: {ipn.Transaction?.TransactionDate}");
        Console.WriteLine("==================================");

        // 1. Chỉ xử lý ORDER_PAID
        if (!string.Equals(ipn.NotificationType, "ORDER_PAID", StringComparison.OrdinalIgnoreCase))
        {
            return new SepayProcessIpnResponse(true, $"Ignored notification type: {ipn.NotificationType}");
        }

        // 2. Order phải CAPTURED
        if (!string.Equals(ipn.Order?.OrderStatus, "CAPTURED", StringComparison.OrdinalIgnoreCase))
        {
            return new SepayProcessIpnResponse(true, $"Order is not CAPTURED. Status={ipn.Order?.OrderStatus}");
        }

        // 3. Transaction phải APPROVED
        if (!string.Equals(ipn.Transaction?.TransactionStatus, "APPROVED", StringComparison.OrdinalIgnoreCase))
        {
            return new SepayProcessIpnResponse(true, $"Transaction is not APPROVED. Status={ipn.Transaction?.TransactionStatus}");
        }

        // =========================================================
        // 4. PARSE INVOICE NUMBER VÀ BÓC TÁCH GUID CHÍNH XÁC
        // =========================================================
        bool hasValidGuid = TryParseTopUpInvoiceNumber(ipn.Order?.OrderInvoiceNumber, out var paymentId);

        Console.WriteLine($"[SEPAY] Has Valid Guid in InvoiceNumber: {hasValidGuid} | Parsed PaymentId: {paymentId}");

        // CHẶN BỎ HOÀN TOÀN CƠ CHẾ DÒ TÌM THEO SỐ TIỀN BẰNG CÁCH YÊU CẦU GUID BẮT BUỘC
        if (!hasValidGuid || paymentId == Guid.Empty)
        {
            Console.WriteLine($"❌ [SEPAY] Bỏ qua giao dịch vì không định danh được PaymentId chuẩn từ: {ipn.Order?.OrderInvoiceNumber}");
            return new SepayProcessIpnResponse(
                false,
                $"Cannot identify valid PaymentId from InvoiceNumber: {ipn.Order?.OrderInvoiceNumber}",
                Guid.Empty);
        }

        // =========================================================
        // 5. TÌM PAYMENT TRONG DATABASE THEO GUID ĐÃ BÓC TÁCH
        // =========================================================
        var payment = await _paymentRepository.GetByIdAsync(paymentId, cancellationToken);

        if (payment == null)
        {
            Console.WriteLine($"❌ [SEPAY] Không tìm thấy PaymentId = {paymentId} trong Database!");
            return new SepayProcessIpnResponse(
                false,
                $"Payment not found for PaymentId: {paymentId}",
                paymentId);
        }

        Console.WriteLine($"✅ [SEPAY] Tìm thấy đúng đơn hàng! PaymentId={payment.Id}, UserId={payment.UserId}");

        // 6. Timeout: nếu IPN đến sau khi đã quá PaymentTimeoutMinutes thì không cộng tiền.
        //    Áp dụng cùng pattern với VnPayProcessReturnCommandHandler để tránh user quét QR muộn
        //    vẫn bị trừ tiền sau khi frontend đã hiển thị "hết hạn".
        if (payment.Status == PaymentStatus.Pending
            && (DateTime.UtcNow - payment.CreatedAt).TotalMinutes > _sepaySettings.PaymentTimeoutMinutes)
        {
            payment.Status = PaymentStatus.Failed;
            await _paymentRepository.UpdateAsync(payment, cancellationToken);

            await _paymentRealtimeNotifier.NotifyStatusChangedAsync(
                payment.UserId,
                new PaymentStatusChangedEvent
                {
                    PaymentId = payment.Id,
                    Amount = payment.Amount,
                    Status = payment.Status.ToString(),
                },
                cancellationToken);

            Console.WriteLine($"⏰ [SEPAY] Payment {payment.Id} expired (> {_sepaySettings.PaymentTimeoutMinutes}min). Marked Failed.");

            return new SepayProcessIpnResponse(
                true,
                $"Payment expired (>{_sepaySettings.PaymentTimeoutMinutes}min). Status={payment.Status}",
                paymentId);
        }

        // 8. Kiểm tra method
        if (!string.Equals(payment.Method, "sepay", StringComparison.OrdinalIgnoreCase))
        {
            return new SepayProcessIpnResponse(
                false,
                $"Payment method mismatch: {payment.Method}",
                paymentId);
        }

        // 9. Kiểm tra amount
        if (!IsSameAmount(payment.Amount, ipn.Order?.OrderAmount, ipn.Transaction?.TransactionAmount))
        {
            return new SepayProcessIpnResponse(
                false,
                $"Payment amount mismatch. Expected={payment.Amount}, Order={ipn.Order?.OrderAmount}, Transaction={ipn.Transaction?.TransactionAmount}",
                paymentId);
        }

        // 10. Chống xử lý trùng bằng atomic transition Pending -> Completed
        var gatewayTransactionId = FirstNotEmpty(
            ipn.Transaction?.TransactionId,
            ipn.Transaction?.Id,
            ipn.Order?.OrderId);

        var paidAt = ParseSepayDate(ipn.Transaction?.TransactionDate) ?? DateTime.UtcNow;

        var completedPayment = await _paymentRepository.TryCompletePendingAsync(
            payment.Id,
            gatewayTransactionId,
            paidAt,
            cancellationToken);

        if (completedPayment is null)
        {
            var refreshed = await _paymentRepository.GetByIdAsync(payment.Id, cancellationToken);

            if (refreshed is not null && refreshed.Status == PaymentStatus.Completed)
            {
                return new SepayProcessIpnResponse(true, "Payment already processed.", paymentId);
            }

            return new SepayProcessIpnResponse(
                false,
                $"Payment is not pending. Status={refreshed?.Status}",
                paymentId);
        }

        // 11. Kiểm tra WalletTransaction
        var existingWalletTransaction = await _walletTransactionRepository.FindOneAsync(
            x => x.ReferenceId == completedPayment.Id.ToString() && x.Type == TransactionType.TopUp,
            cancellationToken);

        // 12. Tạo WalletTransaction
        if (existingWalletTransaction == null)
        {
            var walletTransaction = new WalletTransaction
            {
                UserId = completedPayment.UserId,
                Amount = completedPayment.Amount,
                Type = TransactionType.TopUp,
                Status = TransactionStatus.Completed,
                Description = $"Nap tien vi qua SePay. Ma GD: {gatewayTransactionId}",
                ReferenceId = completedPayment.Id.ToString(),
                CreatedAt = completedPayment.PaidAt ?? DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };

            await _walletTransactionRepository.CreateAsync(walletTransaction, cancellationToken);
        }

        Console.WriteLine($"SEPAY PAYMENT COMPLETED: PaymentId={completedPayment.Id}, TransactionId={gatewayTransactionId}");

        await _notificationService.NotifyUserAsync(
            completedPayment.UserId,
            "Nạp tiền thành công",
            $"Ví E-Box Pay của bạn đã được cộng {completedPayment.Amount:N0} đ.",
            cancellationToken);

        await _paymentRealtimeNotifier.NotifyStatusChangedAsync(
            completedPayment.UserId,
            new PaymentStatusChangedEvent
            {
                PaymentId = completedPayment.Id,
                Amount = completedPayment.Amount,
                Status = completedPayment.Status.ToString(),
                PaidAt = completedPayment.PaidAt,
                TransactionId = completedPayment.TransactionId,
            },
            cancellationToken);

        return new SepayProcessIpnResponse(true, "Payment updated successfully.", paymentId);
    }

    private static bool IsSameAmount(decimal expectedAmount, params string?[] amountValues)
    {
        foreach (var amountValue in amountValues)
        {
            if (string.IsNullOrWhiteSpace(amountValue))
                continue;

            if (decimal.TryParse(amountValue, NumberStyles.Number, CultureInfo.InvariantCulture, out var parsed))
            {
                if (decimal.Round(parsed, 0) == decimal.Round(expectedAmount, 0))
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

    private static string FirstNotEmpty(params string?[] values)
    {
        return values.FirstOrDefault(value => !string.IsNullOrWhiteSpace(value)) ?? Guid.NewGuid().ToString("N");
    }

    private static bool TryParseTopUpInvoiceNumber(string? invoiceNumber, out Guid paymentId)
    {
        paymentId = Guid.Empty;

        if (string.IsNullOrWhiteSpace(invoiceNumber))
            return false;

        var clean = invoiceNumber.Trim();

        // 1. Xóa các tiền tố TOPUP_ hoặc TOPUP (không phân biệt hoa thường, có hoặc không có dấu gạch dưới)
        if (clean.StartsWith("TOPUP_", StringComparison.OrdinalIgnoreCase))
        {
            clean = clean[6..];
        }
        else if (clean.StartsWith("TOPUP", StringComparison.OrdinalIgnoreCase))
        {
            clean = clean[5..];
        }
        // 2. Trường hợp mã PAY từ SePay
        else if (clean.StartsWith("PAY", StringComparison.OrdinalIgnoreCase) && clean.Length >= 20)
        {
            try
            {
                string hexPart = clean[3..];
                if (hexPart.Length > 8)
                {
                    hexPart = hexPart.Remove(8, 1);
                }
                return Guid.TryParseExact(hexPart, "N", out paymentId);
            }
            catch
            {
                return false;
            }
        }

        // 3. Parse trực tiếp GUID (hỗ trợ cả dạng 32 ký tự liền hoặc có dấu gạch ngang)
        return Guid.TryParseExact(clean, "N", out paymentId) || Guid.TryParse(clean, out paymentId);
    }
}