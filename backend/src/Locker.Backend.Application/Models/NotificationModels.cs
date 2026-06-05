namespace Locker.Backend.Application.Models;

public class NotificationDto
{
    public Guid Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Message { get; set; } = string.Empty;
    public bool IsRead { get; set; }
    public DateTime CreatedAt { get; set; }
}

public class RegisterDeviceRequest
{
    public string DeviceToken { get; set; } = string.Empty;
    public string Platform { get; set; } = string.Empty;
}
