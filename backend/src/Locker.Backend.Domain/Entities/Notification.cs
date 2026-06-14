namespace Locker.Backend.Domain.Entities;

public class Notification : BaseEntity
{
    public Guid UserId { get; set; }

    private string _title = string.Empty;
    public string Title
    {
        get => _title;
        set => _title = value?.Length > 100 ? value.Substring(0, 100) : (value ?? string.Empty);
    }

    private string _message = string.Empty;
    public string Message
    {
        get => _message;
        set => _message = value?.Length > 500 ? value.Substring(0, 500) : (value ?? string.Empty);
    }

    public bool IsRead { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
