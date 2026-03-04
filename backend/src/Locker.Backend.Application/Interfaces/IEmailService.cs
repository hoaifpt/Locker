namespace Locker.Backend.Application.Interfaces;

public interface IEmailService
{
    Task SendOtpAsync(string toEmail, string otpCode, CancellationToken cancellationToken);
    Task SendVerificationEmailAsync(string toEmail, string fullName, string verificationLink, CancellationToken cancellationToken);
}
