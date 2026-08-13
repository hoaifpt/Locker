using Locker.Backend.Domain.Enums;

namespace Locker.Backend.Domain.Entities;

public class Feedback : BaseEntity
{
    public Guid UserId { get; set; }
    public string Username { get; set; } = string.Empty;
    public int Rating { get; set; }
    public FeedbackTopic Topic { get; set; }
    public string Content { get; set; } = string.Empty;
    public string PageUrl { get; set; } = string.Empty;
    public bool IsVisible { get; set; } = true;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
}
