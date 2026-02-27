namespace Locker.Backend.Domain.Entities;

public class OtpCode : BaseEntity
{
    public string UserId { get; set; } = string.Empty;
    /// <summary>Email or Phone used as the OTP target</summary>
    public string Target { get; set; } = string.Empty;
    public string Code { get; set; } = string.Empty;
    public DateTime ExpiresAt { get; set; }
    public bool IsUsed { get; set; } = false;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
