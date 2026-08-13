using System.Security.Cryptography;
using System.Text;
using System.Web;
using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Models;
using Microsoft.Extensions.Options;
using System.Globalization;
using System.Linq;

namespace Locker.Backend.Infrastructure.Services;

public class SepayService : ISepayService
{
    private readonly SepaySettings _settings;

    public SepayService(IOptions<SepaySettings> settings)
    {
        _settings = settings.Value;
    }

    public string GenerateSepayPaymentUrl(Guid userId, decimal amount, string ipAddress)
    {
        var orderId = Guid.NewGuid().ToString("N");
        var orderInfo = $"Nap tien cho tai khoan {userId}";

        // Hầu hết các cổng thanh toán của Việt Nam yêu cầu số tiền ở đơn vị nhỏ nhất (ví dụ: VNĐ * 100).
        var amountValue = (long)(amount * 100);

        // Sử dụng giờ Việt Nam (UTC+7) là tiêu chuẩn cho các cổng thanh toán Việt Nam.
        var createDate = DateTime.UtcNow.AddHours(7).ToString("yyyyMMddHHmmss");

        var parameters = new SortedDictionary<string, string>(StringComparer.Ordinal)
        {
            { "sepay_Version", "2.1.0" },
            { "sepay_Command", "pay" },
            { "sepay_TmnCode", _settings.TmnCode },
            { "sepay_Amount", amountValue.ToString() },
            { "sepay_CreateDate", createDate },
            { "sepay_CurrCode", "VND" },
            { "sepay_IpAddr", ipAddress },
            { "sepay_Locale", "vn" },
            { "sepay_OrderInfo", orderInfo },
            { "sepay_OrderType", "topup" },
            { "sepay_ReturnUrl", _settings.SuccessUrl },
            { "sepay_TxnRef", orderId },
            { "sepay_UserId", userId.ToString() }
        };

        var signature = CreateSignature(_settings.HashSecret, parameters);
        parameters.Add("sepay_SecureHash", signature);

        var queryString = string.Join("&", parameters.Select(kvp => $"{HttpUtility.UrlEncode(kvp.Key)}={HttpUtility.UrlEncode(kvp.Value)}"));

        return $"{_settings.PaymentUrl}?{queryString}";
    }

    public bool VerifySepayReturnUrl(IDictionary<string, string> parameters, out string errorMessage)
    {
        errorMessage = string.Empty;
        if (!parameters.TryGetValue("sepay_SecureHash", out var receivedSignature))
        {
            errorMessage = "Lỗi: Không tìm thấy chữ ký trong URL trả về từ Sepay.";
            return false;
        }

        var paramsForVerification = parameters
            .Where(kvp => kvp.Key != "sepay_SecureHash" && !string.IsNullOrEmpty(kvp.Value))
            .ToDictionary(kvp => kvp.Key, kvp => kvp.Value);

        var expectedSignature = CreateSignature(_settings.HashSecret, paramsForVerification);

        if (expectedSignature.Equals(receivedSignature, StringComparison.OrdinalIgnoreCase))
        {
            return true;
        }

        errorMessage = "Lỗi: Chữ ký không hợp lệ. Dữ liệu có thể đã bị thay đổi.";
        return false;
    }

    public PaymentReturnResponse ProcessSepayReturn(IDictionary<string, string> parameters)
    {
        // Cách 1: Sử dụng TryGetValue (Cách chuẩn nhất, không bao giờ bị lỗi type inference)
        parameters.TryGetValue("sepay_ResponseCode", out var responseCode);
        var isSuccess = responseCode == "00";
        var message = GetSepayResponseMessage(responseCode);

        parameters.TryGetValue("sepay_Amount", out var amountStr);
        _ = decimal.TryParse(amountStr, out var amountFromGateway);
        var amountValue = amountFromGateway / 100; // Chuyển đổi lại thành VNĐ

        parameters.TryGetValue("sepay_UserId", out var userIdStr);
        _ = Guid.TryParse(userIdStr, out var userId);

        parameters.TryGetValue("sepay_PayDate", out var payDateStr);
        DateTime payDate = DateTime.UtcNow; // Mặc định là giờ hiện tại nếu parse lỗi
        if (DateTime.TryParseExact(payDateStr, "yyyyMMddHHmmss", CultureInfo.InvariantCulture, DateTimeStyles.None, out var payDateUnspecified))
        {
            // Thời gian từ cổng thanh toán là giờ Việt Nam (UTC+7). Ta cần chuyển đổi về UTC để lưu trữ nhất quán.
            // Cách tiếp cận này tương thích với cả Windows và Linux.
            try
            {
                var vietnamTimeZone = TimeZoneInfo.FindSystemTimeZoneById("SE Asia Standard Time"); // Windows
                payDate = TimeZoneInfo.ConvertTimeToUtc(payDateUnspecified, vietnamTimeZone);
            }
            catch (TimeZoneNotFoundException)
            {
                var vietnamTimeZone = TimeZoneInfo.FindSystemTimeZoneById("Asia/Ho_Chi_Minh"); // Linux/macOS
                payDate = TimeZoneInfo.ConvertTimeToUtc(payDateUnspecified, vietnamTimeZone);
            }
        }

        parameters.TryGetValue("sepay_TxnRef", out var transactionId);
        parameters.TryGetValue("sepay_TransactionNo", out var sepayTransactionNo);

        return new PaymentReturnResponse(
            isSuccess,
            message,
            amountValue,
            userId,
            payDate,
            transactionId ?? string.Empty,
            sepayTransactionNo ?? string.Empty
        );
    }

    private string CreateSignature(string secret, IReadOnlyDictionary<string, string> parameters)
    {
        // Sắp xếp các tham số theo thứ tự alphabet của key để tạo chuỗi ký nhất quán.
        var dataToSign = string.Join("&", parameters
            .OrderBy(kvp => kvp.Key, StringComparer.Ordinal)
            .Select(kvp => $"{kvp.Key}={kvp.Value}"));

        using var hmac = new HMACSHA256(Encoding.UTF8.GetBytes(secret));
        var hashBytes = hmac.ComputeHash(Encoding.UTF8.GetBytes(dataToSign));

        // Convert.ToHexString hiện đại và hiệu quả hơn (.NET 5+)
        return Convert.ToHexString(hashBytes).ToLowerInvariant();
    }

    private static string GetSepayResponseMessage(string? responseCode) => responseCode switch
    {
        "00" => "Giao dịch thành công",
        "07" => "Trừ tiền thành công. Giao dịch bị nghi ngờ (liên hệ Sepay).",
        "09" => "Giao dịch không thành công do: Thẻ/Tài khoản chưa đăng ký dịch vụ.",
        "10" => "Giao dịch không thành công do: Xác thực thông tin không thành công.",
        "11" => "Giao dịch không thành công do: Đã hết hạn chờ thanh toán.",
        "24" => "Giao dịch không thành công do: Hủy giao dịch.",
        "51" => "Giao dịch không thành công do: Số dư không đủ.",
        "65" => "Giao dịch không thành công do: Vượt quá hạn mức giao dịch trong ngày.",
        "75" => "Ngân hàng đang bảo trì.",
        "79" => "Giao dịch không thành công do: Sai mật khẩu xác thực (OTP).",
        "99" => "Các lỗi khác (do Sepay trả về).",
        _ => "Giao dịch không thành công.",
    };
}
