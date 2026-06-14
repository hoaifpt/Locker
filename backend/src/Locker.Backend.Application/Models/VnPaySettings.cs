namespace Locker.Backend.Application.Models;

public class VnPaySettings
{
    public string TmnCode { get; set; } = string.Empty;
    public string HashSecret { get; set; } = string.Empty;
    public string BaseUrl { get; set; } = "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html";
    public string ReturnUrl { get; set; } = string.Empty;
    public string Command { get; set; } = "pay";
    public string CurrCode { get; set; } = "VND";
    public string Locale { get; set; } = "vn";
    public string Version { get; set; } = "2.1.0";
    public int PaymentTimeoutMinutes { get; set; } = 15;
    public decimal MinAmount { get; set; } = 10000;
    public decimal MaxAmount { get; set; } = 50000000;
}
