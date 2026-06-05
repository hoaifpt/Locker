using Locker.Backend.Application.Interfaces;
using Locker.Backend.Domain.Entities;
using MediatR;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Locker.Backend.Application.Models;

namespace Locker.Backend.Application.Features.Auth.Commands.Register;

public record RegisterCommand(string Username, string Email, string Password, string? FullName, string? PhoneNumber) : IRequest<(bool Success, string? Error)>;

public class RegisterCommandHandler : IRequestHandler<RegisterCommand, (bool Success, string? Error)>
{
    private readonly IIdentityService _identityService;
    private readonly IEmailService _emailService;
    private readonly ILogger<RegisterCommandHandler> _logger;
    private readonly string _baseUrl;

    public RegisterCommandHandler(
        IIdentityService identityService,
        IEmailService emailService,
        IOptions<AppSettings> appSettings,
        ILogger<RegisterCommandHandler> logger)
    {
        _identityService = identityService;
        _emailService = emailService;
        _baseUrl = appSettings.Value.BaseUrl.TrimEnd('/');
        _logger = logger;
    }

    public async Task<(bool Success, string? Error)> Handle(RegisterCommand request, CancellationToken cancellationToken)
    {
        var existing = await _identityService.FindByNameAsync(request.Username);
        if (existing != null)
            return (false, "Tên người dùng đã tồn tại.");

        var existingEmail = await _identityService.FindByEmailAsync(request.Email);
        if (existingEmail != null)
            return (false, "Email đã được sử dụng.");

        if (!string.IsNullOrWhiteSpace(request.PhoneNumber))
        {
            var existingPhone = await _identityService.FindByPhoneNumberAsync(request.PhoneNumber);
            if (existingPhone != null)
                return (false, "Số điện thoại đã được sử dụng.");
        }

        var verificationToken = Guid.NewGuid().ToString("N");

        var user = new User
        {
            UserName = request.Username,
            Email = request.Email,
            FullName = request.FullName,
            PhoneNumber = request.PhoneNumber,
            IsActive = false,
            EmailVerificationToken = verificationToken
        };

        var result = await _identityService.CreateUserAsync(user, request.Password);
        if (!result.Success)
        {
            return (false, string.Join(", ", result.Errors));
        }

        await _identityService.AddToRoleAsync(user, "User");

        try
        {
            var verificationLink = $"{_baseUrl}/api/auth/verify-email?token={verificationToken}";
            await _emailService.SendVerificationEmailAsync(user.Email, user.FullName ?? user.UserName, verificationLink, cancellationToken);
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Failed to send verification email to {Email}.", user.Email);
        }

        return (true, null);
    }
}
