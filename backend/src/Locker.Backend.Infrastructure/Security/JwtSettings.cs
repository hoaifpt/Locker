namespace Locker.Backend.Infrastructure.Security;

public class JwtSettings
{
    public string Issuer { get; set; } = "locker";
    public string Audience { get; set; } = "locker";
    public string Secret { get; set; } = "CHANGE_ME";
    public int ExpiryMinutes { get; set; } = 120;
    public int RefreshTokenExpiryDays { get; set; } = 7;
}
