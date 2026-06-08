using Locker.Backend.Application.Interfaces;
using MediatR;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.Auth.Commands.ResetPassword;

public record ResetPasswordCommand(string Email, string Otp, string NewPassword) : IRequest<(bool Success, string? Error)>;

public class ResetPasswordCommandHandler : IRequestHandler<ResetPasswordCommand, (bool Success, string? Error)>
{
    private readonly IIdentityService _identityService;
    private readonly IOtpRepository _otpRepository;

    public ResetPasswordCommandHandler(
        IIdentityService identityService,
        IOtpRepository otpRepository)
    {
        _identityService = identityService;
        _otpRepository = otpRepository;
    }

    public async Task<(bool Success, string? Error)> Handle(ResetPasswordCommand request, CancellationToken cancellationToken)
    {
        var email = request.Email.Trim();
        var user = await _identityService.FindByEmailAsync(email);

        if (user == null)
            return (false, "Email hoặc số điện thoại không hợp lệ.");

        var storedOtp = await _otpRepository.GetLatestValidAsync(user.Id, email, cancellationToken);

        if (storedOtp == null || storedOtp.Code != request.Otp)
            return (false, "Mã OTP không hợp lệ hoặc đã hết hạn.");

        var resetToken = await _identityService.GeneratePasswordResetTokenAsync(user);
        var result = await _identityService.ResetPasswordAsync(user, resetToken, request.NewPassword);

        if (!result.Success)
            return (false, string.Join(", ", result.Errors));

        await _otpRepository.MarkUsedAsync(storedOtp.Id, cancellationToken);
        return (true, null);
    }
}
