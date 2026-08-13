using System.Globalization;
using System.Security.Cryptography;
using System.Text;
using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Models;
using Microsoft.Extensions.Options;

namespace Locker.Backend.Infrastructure.Services;

public class SepayService : ISepayService
{
    private static readonly string[] SignedFields =
    [
        "order_amount",
        "merchant",
        "currency",
        "operation",
        "order_description",
        "order_invoice_number",
        "customer_id",
        "payment_method",
        "success_url",
        "error_url",
        "cancel_url"
    ];

    private readonly SepaySettings _settings;

    public SepayService(IOptions<SepaySettings> settings)
    {
        _settings = settings.Value;
    }

    public SepayCheckoutData CreateTopUpCheckout(Guid paymentId, Guid userId, decimal amount, string? paymentMethod = null)
    {
        var checkoutUrl = GetCheckoutUrl();
        var merchantId = GetMerchantId();
        var secretKey = GetSecretKey();

        if (string.IsNullOrWhiteSpace(checkoutUrl))
        {
            throw new InvalidOperationException("Sepay checkout URL is not configured.");
        }

        if (string.IsNullOrWhiteSpace(merchantId))
        {
            throw new InvalidOperationException("Sepay merchant ID is not configured.");
        }

        if (string.IsNullOrWhiteSpace(secretKey))
        {
            throw new InvalidOperationException("Sepay secret key is not configured.");
        }

        var fields = new Dictionary<string, string>
        {
            ["order_amount"] = decimal.Truncate(amount).ToString("0", CultureInfo.InvariantCulture),
            ["merchant"] = merchantId,
            ["currency"] = "VND",
            ["operation"] = "PURCHASE",
            ["order_description"] = $"Nap tien vi Locker {paymentId:N}",
            ["order_invoice_number"] = CreateTopUpInvoiceNumber(paymentId),
            ["customer_id"] = userId.ToString("N"),
            ["success_url"] = _settings.SuccessUrl,
            ["error_url"] = _settings.ErrorUrl,
            ["cancel_url"] = _settings.CancelUrl
        };

        if (!string.IsNullOrWhiteSpace(paymentMethod))
        {
            fields["payment_method"] = paymentMethod;
        }

        var signedString = BuildSignedString(fields);
        var signature = Sign(signedString, secretKey);
        fields["signature"] = signature;

        return new SepayCheckoutData(checkoutUrl, fields, signedString, signature);
    }

    public bool IsValidIpnSecret(string? providedSecret)
    {
        var webhookSecret = _settings.WebhookApiKey;

        return !string.IsNullOrWhiteSpace(webhookSecret)
            && !string.IsNullOrWhiteSpace(providedSecret)
            && CryptographicOperations.FixedTimeEquals(
                Encoding.UTF8.GetBytes(providedSecret),
                Encoding.UTF8.GetBytes(webhookSecret));
    }

    public static string CreateTopUpInvoiceNumber(Guid paymentId)
    {
        return $"TOPUP_{paymentId:N}";
    }

    public static bool TryParseTopUpPaymentId(string? invoiceNumber, out Guid paymentId)
    {
        paymentId = Guid.Empty;
        const string prefix = "TOPUP_";

        if (string.IsNullOrWhiteSpace(invoiceNumber) ||
            !invoiceNumber.StartsWith(prefix, StringComparison.OrdinalIgnoreCase))
        {
            return false;
        }

        return Guid.TryParseExact(invoiceNumber[prefix.Length..], "N", out paymentId);
    }

    private string GetCheckoutUrl()
    {
        if (!string.IsNullOrWhiteSpace(_settings.CheckoutUrl))
        {
            return _settings.CheckoutUrl;
        }

        if (!string.IsNullOrWhiteSpace(_settings.PaymentUrl))
        {
            return _settings.PaymentUrl;
        }

        return string.Equals(_settings.Environment, "production", StringComparison.OrdinalIgnoreCase)
            ? "https://pay.sepay.vn/v1/checkout/init"
            : "https://pay-sandbox.sepay.vn/v1/checkout/init";
    }

    private string GetMerchantId()
    {
        return !string.IsNullOrWhiteSpace(_settings.MerchantId)
            ? _settings.MerchantId
            : _settings.TmnCode;
    }

    private string GetSecretKey()
    {
        return !string.IsNullOrWhiteSpace(_settings.SecretKey)
            ? _settings.SecretKey
            : _settings.HashSecret;
    }

    private static string BuildSignedString(IReadOnlyDictionary<string, string> fields)
    {
        return string.Join(",", SignedFields
            .Where(fields.ContainsKey)
            .Select(field => $"{field}={fields[field]}"));
    }

    private static string Sign(string signedString, string secretKey)
    {
        using var hmac = new HMACSHA256(Encoding.UTF8.GetBytes(secretKey));
        var hashBytes = hmac.ComputeHash(Encoding.UTF8.GetBytes(signedString));
        return Convert.ToBase64String(hashBytes);
    }

    public bool IsValidIpnApiKey(string? providedApiKey)
    {
        var apiKey = _settings.WebhookApiKey;

        return !string.IsNullOrWhiteSpace(apiKey)
            && !string.IsNullOrWhiteSpace(providedApiKey)
            && CryptographicOperations.FixedTimeEquals(
                Encoding.UTF8.GetBytes(providedApiKey),
                Encoding.UTF8.GetBytes(apiKey));
    }
}
