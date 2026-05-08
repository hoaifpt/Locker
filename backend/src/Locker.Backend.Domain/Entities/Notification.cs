namespace Locker.Backend.Domain.Entities;

public class Notification : BaseEntity
{
    public string UserId { get; set; } = string.Empty;
    public string Title { get; set; } = string.Empty;
    public string Message { get; set; } = string.Empty;
    public string Type { get; set; } = "Info"; // Info, Reminder, Alert
    public bool IsRead { get; set; } = false;
    public string? RelatedTransactionId { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}