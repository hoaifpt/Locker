using Locker.Backend.Application.Interfaces;
using MediatR;
using Microsoft.Extensions.Logging;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.Auth.Commands.ResetPassword;

public record ResetPasswordCommand(string Email, string Otp, string NewPassword) : IRequest<(bool Success, string? Error)>;

public class ResetPasswordCommandHandler : IRequestHandler<ResetPasswordCommand, (bool Success, string? Error)>
{
    private const int MaxOtpAttempts = 5;
    private static readonly TimeSpan LockoutDuration = TimeSpan.FromMinutes(15);

    private readonly IIdentityService _identityService;
    private readonly IOtpRepository _otpRepository;
    private readonly ILogger<ResetPasswordCommandHandler> _logger;

    public ResetPasswordCommandHandler(
        IIdentityService identityService,
        IOtpRepository otpRepository,
        ILogger<ResetPasswordCommandHandler> logger)
    {
        _identityService = identityService;
        _otpRepository = otpRepository;
        _logger = logger;
    }

    public async Task<(bool Success, string? Error)> Handle(ResetPasswordCommand request, CancellationToken cancellationToken)
    {
        var email = request.Email.Trim();
        var user = await _identityService.FindByEmailAsync(email);

        if (user == null)
            return (false, "Email hoặc số điện thoại không hợp lệ.");

        var storedOtp = await _otpRepository.GetLatestValidAsync(user.Id, email, cancellationToken);

        if (storedOtp == null)
            return (false, "Mã OTP không hợp lệ hoặc đã hết hạn.");

        // Brute-force lockout check
        if (storedOtp.LockedUntil.HasValue && storedOtp.LockedUntil.Value > DateTime.UtcNow)
            return (false, $"Quá nhiều lần thử sai. Vui lòng chờ đến {storedOtp.LockedUntil.Value:HH:mm} và thử lại.");

        if (storedOtp.Code != request.Otp)
        {
            storedOtp.FailedAttempts++;
            if (storedOtp.FailedAttempts >= MaxOtpAttempts)
            {
                storedOtp.LockedUntil = DateTime.UtcNow.Add(LockoutDuration);
                storedOtp.FailedAttempts = 0;
                _logger.LogWarning("[AUDIT] OTP brute-force lockout triggered for Email={Email}", email);
            }
            await _otpRepository.UpdateAsync(storedOtp, cancellationToken);
            return (false, "Mã OTP không hợp lệ.");
        }

        var resetToken = await _identityService.GeneratePasswordResetTokenAsync(user);
        var result = await _identityService.ResetPasswordAsync(user, resetToken, request.NewPassword);

        if (!result.Success)
            return (false, string.Join(", ", result.Errors));

        await _otpRepository.MarkUsedAsync(storedOtp.Id, cancellationToken);
        _logger.LogInformation("[AUDIT] Password reset successful for Email={Email}", email);
        return (true, null);
    }
}
