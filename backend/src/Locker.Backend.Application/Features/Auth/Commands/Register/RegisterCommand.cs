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

public record RegisterCommand(string Username, string Email, string Password, string? FullName, string? PhoneNumber) : IRequest<(AuthResponse? Response, string? Error)>;

public class RegisterCommandHandler : IRequestHandler<RegisterCommand, (AuthResponse? Response, string? Error)>
{
    private readonly IIdentityService _identityService;
    private readonly IEmailService _emailService;
    private readonly IJwtTokenService _jwtTokenService;
    private readonly IRefreshTokenRepository _refreshTokenRepository;
    private readonly ILogger<RegisterCommandHandler> _logger;
    private readonly string _baseUrl;

    public RegisterCommandHandler(
        IIdentityService identityService,
        IEmailService emailService,
        IJwtTokenService jwtTokenService,
        IRefreshTokenRepository refreshTokenRepository,
        IOptions<AppSettings> appSettings,
        ILogger<RegisterCommandHandler> logger)
    {
        _identityService = identityService;
        _emailService = emailService;
        _jwtTokenService = jwtTokenService;
        _refreshTokenRepository = refreshTokenRepository;
        _baseUrl = appSettings.Value.BaseUrl.TrimEnd('/');
        _logger = logger;
    }

    public async Task<(AuthResponse? Response, string? Error)> Handle(RegisterCommand request, CancellationToken cancellationToken)
    {
        var existing = await _identityService.FindByNameAsync(request.Username);
        if (existing != null)
            return (null, "Tên người dùng đã tồn tại.");

        var existingEmail = await _identityService.FindByEmailAsync(request.Email);
        if (existingEmail != null)
            return (null, "Email đã được sử dụng.");

        if (!string.IsNullOrWhiteSpace(request.PhoneNumber))
        {
            var existingPhone = await _identityService.FindByPhoneNumberAsync(request.PhoneNumber);
            if (existingPhone != null)
                return (null, "Số điện thoại đã được sử dụng.");
        }

        var verificationToken = Guid.NewGuid().ToString("N");

        var user = new User
        {
            UserName = request.Username,
            Email = request.Email,
            FullName = request.FullName,
            PhoneNumber = request.PhoneNumber,
            IsActive = true,
            EmailVerificationToken = verificationToken,
            EmailConfirmed = true
        };

        var result = await _identityService.CreateUserAsync(user, request.Password);
        if (!result.Success)
        {
            return (null, string.Join(", ", result.Errors));
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

        var authResponse = await GenerateAuthResponseAsync(user, cancellationToken);
        return (authResponse, null);
    }

    private async Task<AuthResponse> GenerateAuthResponseAsync(User user, CancellationToken cancellationToken)
    {
        var roles = await _identityService.GetRolesAsync(user);
        var role = roles.FirstOrDefault() ?? "User";

        var tokenSubject = new TokenSubject(user.Id, user.UserName, user.Email, role);
        var accessToken = _jwtTokenService.CreateToken(tokenSubject);
        var refreshTokenValue = _jwtTokenService.CreateRefreshToken(tokenSubject);

        var refreshToken = new Domain.Entities.RefreshToken
        {
            UserId = user.Id,
            Token = refreshTokenValue,
            ExpiresAt = _jwtTokenService.GetRefreshTokenExpiry(),
            CreatedAt = DateTime.UtcNow,
            IsRevoked = false
        };

        await _refreshTokenRepository.CreateAsync(refreshToken, cancellationToken);

        return new AuthResponse
        {
            Token = accessToken,
            RefreshToken = refreshTokenValue,
            Username = user.UserName ?? string.Empty,
            Role = role,
            ExpiresAt = _jwtTokenService.GetAccessTokenExpiry()
        };
    }
}
