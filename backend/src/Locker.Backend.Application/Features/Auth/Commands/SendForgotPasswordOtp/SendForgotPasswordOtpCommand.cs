using Locker.Backend.Application.Interfaces;
using Locker.Backend.Domain.Entities;
using Locker.Backend.Domain.Enums;
using MediatR;
using Microsoft.Extensions.Logging;
using System;
using System.Security.Cryptography;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.Auth.Commands.SendForgotPasswordOtp;

public record SendForgotPasswordOtpCommand(string Email) : IRequest<(bool Success, string? Error)>;

public class SendForgotPasswordOtpCommandHandler : IRequestHandler<SendForgotPasswordOtpCommand, (bool Success, string? Error)>
{
    private static readonly TimeSpan OtpLifetime = TimeSpan.FromMinutes(5);
    private static readonly TimeSpan OtpWindow = TimeSpan.FromMinutes(10);
    private const int MaxOtpRequestsPerWindow = 3;

    private readonly IIdentityService _identityService;
    private readonly IOtpRepository _otpRepository;
    private readonly IEmailService _emailService;
    private readonly ILogger<SendForgotPasswordOtpCommandHandler> _logger;

    public SendForgotPasswordOtpCommandHandler(
        IIdentityService identityService,
        IOtpRepository otpRepository,
        IEmailService emailService,
        ILogger<SendForgotPasswordOtpCommandHandler> logger)
    {
        _identityService = identityService;
        _otpRepository = otpRepository;
        _emailService = emailService;
        _logger = logger;
    }

    public async Task<(bool Success, string? Error)> Handle(SendForgotPasswordOtpCommand request, CancellationToken cancellationToken)
    {
        var email = request.Email.Trim();
        var user = await _identityService.FindByEmailAsync(email);
        if (user == null)
        {
            return (true, null);
        }

        var recentRequests = await _otpRepository.FindAsync(
            x => x.UserId == user.Id && x.Target == email && x.CreatedAt >= DateTime.UtcNow.Subtract(OtpWindow),
            cancellationToken);

        if (recentRequests.Count >= MaxOtpRequestsPerWindow)
        {
            return (true, null);
        }

        var otpCode = RandomNumberGenerator.GetInt32(100000, 1000000).ToString();
        var otpCodeObj = new OtpCode
        {
            UserId = user.Id,
            Target = email,
            Code = otpCode,
            ExpiresAt = DateTime.UtcNow.Add(OtpLifetime),
        };

        await _otpRepository.CreateAsync(otpCodeObj, cancellationToken);

        try
        {
            await _emailService.SendOtpAsync(user.Email, otpCode, cancellationToken);
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Failed to send OTP email to {Email}", user.Email);
        }

        return (true, null);
    }
}
