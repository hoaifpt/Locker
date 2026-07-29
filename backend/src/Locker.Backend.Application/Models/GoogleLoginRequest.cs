namespace Locker.Backend.Application.Features.Auth.Commands.GoogleLogin;

public class GoogleLoginRequest
{
    public string IdToken { get; set; } = string.Empty;
}