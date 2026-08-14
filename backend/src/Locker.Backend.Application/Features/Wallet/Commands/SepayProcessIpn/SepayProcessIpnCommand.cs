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

        // =========================================================
        // 4. PARSE INVOICE NUMBER (ĐÃ BỎ QUA VÌ SEPAY KHÔNG TRUYỀN GUID)
        // =========================================================

        // Thay vì trả về lỗi, ta thử ép kiểu xem có Guid không, nếu không có ta sẽ dùng cơ chế dò tìm theo Số tiền
        bool hasValidGuid = TryParseTopUpInvoiceNumber(ipn.Order.OrderInvoiceNumber, out var paymentId);

        Console.WriteLine($"[SEPAY] Has Valid Guid in InvoiceNumber: {hasValidGuid}");

        // =========================================================
        // 5. TÌM PAYMENT TRONG DATABASE
        // =========================================================
        Payment? payment = null;

        if (hasValidGuid)
        {
            // Nếu may mắn bóc tách được Guid chuẩn, tìm theo Id như cũ
            payment = await _paymentRepository.GetByIdAsync(paymentId, cancellationToken);
        }
        else
        {
            // 💡 CƠ CHẾ CỨU CÁNH: Dò tìm đơn hàng dựa vào Số tiền (Amount) và Trạng thái đang chờ (Status = 0)
            decimal txAmount = 0;
            if (decimal.TryParse(ipn.Transaction?.TransactionAmount, System.Globalization.CultureInfo.InvariantCulture, out txAmount))
            {
                Console.WriteLine($"[SEPAY] Dò tìm đơn hàng trùng khớp số tiền: {txAmount} và đang ở trạng thái Pending...");

                // Bạn hãy gọi hàm tìm kiếm của Repository tương ứng với dự án của bạn, ví dụ:
                payment = await _paymentRepository.FindOneAsync(x =>
                    x.Amount == txAmount &&
                    x.Status == 0 && // 0 nghĩa là Pending / Chưa thanh toán
                    (x.Method == "sepay" || x.Method == "Wallet"),
                    cancellationToken);
            }
        }

        if (payment == null)
        {
            return new SepayProcessIpnResponse(
                false,
                $"Payment not found for amount: {ipn.Transaction?.TransactionAmount} or invalid invoice number.",
                Guid.Empty);
        }

        Console.WriteLine($"✅ [SEPAY] Khớp đơn hàng thành công qua cơ chế dò tìm! PaymentId={payment.Id}");


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

        if (string.IsNullOrWhiteSpace(invoiceNumber))
            return false;

        // Trường hợp 1: Nếu chuỗi nhận được là mã PAY... bóc tách từ SePay
        if (invoiceNumber.StartsWith("PAY", StringComparison.OrdinalIgnoreCase) && invoiceNumber.Length >= 20)
        {
            try
            {
                // Quy đổi chuỗi Hex của SePay ngược về lại định dạng mã Guid gốc của hệ thống bạn
                string hexPart = invoiceNumber[3..];
                if (hexPart.Length > 8)
                {
                    hexPart = hexPart.Remove(8, 1); // Loại bỏ ký tự phân tách của SePay
                }
                return Guid.TryParseExact(hexPart, "N", out paymentId);
            }
            catch
            {
                return false;
            }
        }

        // Trường hợp 2: Dự phòng cho luồng thanh toán TOPUP_ cũ
        const string prefix = "TOPUP_";
        if (invoiceNumber.StartsWith(prefix, StringComparison.OrdinalIgnoreCase))
        {
            return Guid.TryParseExact(
                invoiceNumber[prefix.Length..],
                "N",
                out paymentId);
        }

        return false;
    }


}