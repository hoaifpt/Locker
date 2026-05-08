namespace Locker.Backend.Domain.Entities;

public class QrCode : BaseEntity
{
    public string TransactionId { get; set; } = string.Empty;
    public string Type { get; set; } = "Unlock"; // Unlock, Receive, Send
    public string Code { get; set; } = string.Empty; // Random secure string for QR content
    public DateTime ExpiresAt { get; set; }
    public bool IsUsed { get; set; } = false;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}