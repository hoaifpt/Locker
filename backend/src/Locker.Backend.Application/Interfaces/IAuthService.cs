using Locker.Backend.Application.Models;

namespace Locker.Backend.Application.Interfaces;

public interface IAuthService
{
    Task<(AuthResponse? Response, string? Error)> LoginAsync(AuthRequest request, CancellationToken cancellationToken);
    Task<(bool Success, string? Error)> RegisterAsync(RegisterRequest request, CancellationToken cancellationToken);
    Task<(bool Success, string? Error)> ResendVerificationEmailAsync(ResendVerificationRequest request, CancellationToken cancellationToken);
    Task<(bool Success, string? Error)> VerifyEmailAsync(string token, CancellationToken cancellationToken);
    Task<AuthResponse?> RefreshTokenAsync(string refreshToken, CancellationToken cancellationToken);
    Task<bool> LogoutAsync(string refreshToken, CancellationToken cancellationToken);
    Task LogoutAllAsync(string userId, CancellationToken cancellationToken);
    Task<(bool Success, string? Error)> SendForgotPasswordOtpAsync(ForgotPasswordRequest request, CancellationToken cancellationToken);
    Task<(bool Success, string? Error)> ResetPasswordAsync(ResetPasswordRequest request, CancellationToken cancellationToken);
}
