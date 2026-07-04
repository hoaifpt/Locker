using System.Security.Cryptography;
using System.Text;
using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Models;
using Locker.Backend.Application.Features.Wallet.Commands.VnPayInitTopUp;
using Microsoft.Extensions.Options;

namespace Locker.Backend.Infrastructure.Services;

public class VnPayService : IVnPayService
{
    private readonly VnPaySettings _settings;

    public VnPayService(IOptions<VnPaySettings> settings)
    {
        _settings = settings.Value;
    }

    public string CreatePaymentUrl(VnPayInitTopUpResponse payment, string ipAddress)
    {
        var now = DateTime.UtcNow;
        var createDate = now.ToString("yyyyMMddHHmmss");
        var expireDate = now.AddMinutes(_settings.PaymentTimeoutMinutes).ToString("yyyyMMddHHmmss");

        var parameters = new SortedList<string, string>
        {
            ["vnp_Version"] = _settings.Version,
            ["vnp_Command"] = _settings.Command,
            ["vnp_TmnCode"] = _settings.TmnCode,
            ["vnp_CurrCode"] = _settings.CurrCode,
            ["vnp_Locale"] = _settings.Locale,
            ["vnp_ReturnUrl"] = _settings.ReturnUrl,
            ["vnp_Amount"] = ((long)(payment.Amount * 100)).ToString(),
            ["vnp_TxnRef"] = payment.PaymentId.ToString(),
            ["vnp_OrderInfo"] = $"Nap tien vi Locker {payment.Amount:N0} VND",
            ["vnp_CreateDate"] = createDate,
            ["vnp_ExpireDate"] = expireDate,
            ["vnp_IpAddr"] = ipAddress
        };

        // Tính hash TRƯỚC khi thêm vào parameters
        var hashData = BuildHashData(parameters);
        parameters["vnp_SecureHash"] = hashData;

        // Xây dựng query string với URL encoding
        var queryBuilder = new StringBuilder();
        foreach (var param in parameters)
        {
            if (queryBuilder.Length > 0)
                queryBuilder.Append('&');
            queryBuilder.Append($"{param.Key}={Uri.EscapeDataString(param.Value)}");
        }

        return $"{_settings.BaseUrl}?{queryBuilder}";
    }

    public bool VerifyReturnUrl(IDictionary<string, string> parameters, out string? errorMessage)
    {
        errorMessage = null;

        if (!parameters.TryGetValue("vnp_SecureHash", out var providedHash))
        {
            errorMessage = "Missing vnp_SecureHash";
            return false;
        }

        var sortedParams = parameters
            .Where(kvp => kvp.Key != "vnp_SecureHash" && !string.IsNullOrEmpty(kvp.Value))
            .OrderBy(kvp => kvp.Key, StringComparer.Ordinal)
            .ToList();

        // Tính hash từ các tham số đã sắp xếp
        var signData = new StringBuilder();
        foreach (var (key, value) in sortedParams)
        {
            if (signData.Length > 0)
                signData.Append('&');
            signData.Append($"{key}={Uri.EscapeDataString(value)}");
        }

        // Tính HMACSHA512
        var computedHash = ComputeHash(signData.ToString());

        if (!string.Equals(providedHash, computedHash, StringComparison.OrdinalIgnoreCase))
        {
            errorMessage = "Invalid secure hash";
            return false;
        }

        return true;
    }

    private string BuildHashData(SortedList<string, string> parameters)
    {
        var hashData = new StringBuilder();
        foreach (var param in parameters)
        {
            if (hashData.Length > 0)
                hashData.Append('&');
            // ✅ URL encode giá trị khi tính hash
            hashData.Append($"{param.Key}={Uri.EscapeDataString(param.Value)}");
        }

        return ComputeHash(hashData.ToString());
    }

    private string ComputeHash(string data)
    {
        // ✅ Sử dụng HMACSHA512 thay vì SHA256
        using var hmac = new HMACSHA512(Encoding.UTF8.GetBytes(_settings.HashSecret));
        var hash = hmac.ComputeHash(Encoding.UTF8.GetBytes(data));
        return Convert.ToHexString(hash).ToLowerInvariant();
    }
}