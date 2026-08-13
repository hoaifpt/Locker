namespace Locker.Backend.Application.Models;

public class SepaySettings
{
    public string PaymentUrl { get; set; } = string.Empty; // Đổi tên từ BaseUrl cho rõ ràng
    public string HashSecret { get; set; } = string.Empty;
    public string TmnCode { get; set; } = string.Empty;

    // Các URL trả về cụ thể từ cấu hình của bạn
    public string SuccessUrl { get; set; } = string.Empty;
    public string ErrorUrl { get; set; } = string.Empty;
    public string CancelUrl { get; set; } = string.Empty;

    // Các trường khác từ cấu hình của bạn (chưa dùng trong SepayService hiện tại nhưng nên có)
    public string ApiKey { get; set; } = string.Empty;
    public string ApiSecret { get; set; } = string.Empty;
    public string HmacSecret { get; set; } = string.Empty;
    public string WebhookApiKey { get; set; } = string.Empty;
    public string WebhookUrl { get; set; } = string.Empty;
    public string Environment { get; set; } = string.Empty;
    public string ExpectedTransferType { get; set; } = string.Empty;
    public string BankId { get; set; } = string.Empty;
    public string AccountNo { get; set; } = string.Empty;
    public string AccountName { get; set; } = string.Empty;
}
