using Locker.Backend.Application.Interfaces;
using MediatR;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Threading;
using System.Threading.Tasks;
using Locker.Backend.Application.Models;

namespace Locker.Backend.Application.Features.Auth.Commands.ResendVerificationEmail;

public record ResendVerificationEmailCommand(string Email) : IRequest<(bool Success, string? Error)>;

public class ResendVerificationEmailCommandHandler : IRequestHandler<ResendVerificationEmailCommand, (bool Success, string? Error)>
{
    private readonly IIdentityService _identityService;
    private readonly IEmailService _emailService;
    private readonly ILogger<ResendVerificationEmailCommandHandler> _logger;
    private readonly string _baseUrl;

    public ResendVerificationEmailCommandHandler(
        IIdentityService identityService,
        IEmailService emailService,
        IOptions<AppSettings> appSettings,
        ILogger<ResendVerificationEmailCommandHandler> logger)
    {
        _identityService = identityService;
        _emailService = emailService;
        _baseUrl = appSettings.Value.BaseUrl.TrimEnd('/');
        _logger = logger;
    }

    public async Task<(bool Success, string? Error)> Handle(ResendVerificationEmailCommand request, CancellationToken cancellationToken)
    {
        var user = await _identityService.FindByEmailAsync(request.Email.Trim());

        if (user == null || await _identityService.IsEmailConfirmedAsync(user))
            return (true, null);

        user.EmailVerificationToken = Guid.NewGuid().ToString("N");
        await _identityService.UpdateUserAsync(user);

        try
        {
            var verificationLink = $"{_baseUrl}/api/auth/verify-email?token={user.EmailVerificationToken}";
            await _emailService.SendVerificationEmailAsync(user.Email, user.FullName ?? user.UserName, verificationLink, cancellationToken);
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Failed to send verification email to {Email}.", user.Email);
        }

        return (true, null);
    }
}
