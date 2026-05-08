namespace Locker.Backend.Application.Models;

public class QrCodeDto
{
    public string Id { get; set; } = string.Empty;
    public string TransactionId { get; set; } = string.Empty;
    public string Type { get; set; } = string.Empty;
    public string Code { get; set; } = string.Empty;
    public DateTime ExpiresAt { get; set; }
    public bool IsUsed { get; set; }
}

public class ValidationQrCodeRequest
{
    public string Code { get; set; } = string.Empty;
}