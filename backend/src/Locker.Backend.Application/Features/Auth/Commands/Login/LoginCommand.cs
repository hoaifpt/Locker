using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Models;
using Locker.Backend.Domain.Entities;
using MediatR;
using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.Auth.Commands.Login;

public record LoginCommand(string Identifier, string Password) : IRequest<(AuthResponse? Response, string? Error)>;

public class LoginCommandHandler : IRequestHandler<LoginCommand, (AuthResponse? Response, string? Error)>
{
    private readonly IIdentityService _identityService;
    private readonly IJwtTokenService _jwtTokenService;
    private readonly IRefreshTokenRepository _refreshTokenRepository;

    public LoginCommandHandler(
        IIdentityService identityService,
        IJwtTokenService jwtTokenService,
        IRefreshTokenRepository refreshTokenRepository)
    {
        _identityService = identityService;
        _jwtTokenService = jwtTokenService;
        _refreshTokenRepository = refreshTokenRepository;
    }

    public async Task<(AuthResponse? Response, string? Error)> Handle(LoginCommand request, CancellationToken cancellationToken)
    {
        User? user = null;
        var identifier = request.Identifier.Trim();

        if (identifier.Contains("@"))
        {
            user = await _identityService.FindByEmailAsync(identifier);
        }
        else
        {
            user = await _identityService.FindByPhoneNumberAsync(identifier);
            user ??= await _identityService.FindByNameAsync(identifier);
        }

        if (user == null)
            return (null, "Email/số điện thoại hoặc mật khẩu không đúng.");

        if (!await _identityService.IsEmailConfirmedAsync(user))
            return (null, "Tài khoản chưa được xác thực email. Vui lòng kiểm tra hộp thư của bạn.");

        if (!user.IsActive)
            return (null, "Tài khoản đã bị vô hiệu hóa.");

        if (await _identityService.IsLockedOutAsync(user))
        {
            var remaining = (int)Math.Ceiling(((user.LockoutEnd ?? DateTimeOffset.UtcNow) - DateTimeOffset.UtcNow).TotalMinutes);
            return (null, $"Tài khoản tạm thời bị khóa do đăng nhập sai quá nhiều lần. Vui lòng thử lại sau {remaining} phút.");
        }

        if (!await _identityService.CheckPasswordAsync(user, request.Password))
        {
            await _identityService.AccessFailedAsync(user);
            if (await _identityService.IsLockedOutAsync(user))
            {
                return (null, "Tài khoản bị khóa do đăng nhập sai nhiều lần liên tiếp.");
            }
            return (null, "Email/số điện thoại hoặc mật khẩu không đúng.");
        }

        await _identityService.ResetAccessFailedCountAsync(user);

        var response = await GenerateAuthResponseAsync(user, cancellationToken);
        return (response, null);
    }

    private async Task<AuthResponse> GenerateAuthResponseAsync(User user, CancellationToken cancellationToken)
    {
        var roles = await _identityService.GetRolesAsync(user);
        var role = roles.FirstOrDefault() ?? "User";

        var tokenSubject = new TokenSubject(user.Id, user.UserName, user.Email, role);
        var accessToken = _jwtTokenService.CreateToken(tokenSubject);
        var refreshTokenValue = _jwtTokenService.CreateRefreshToken();

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
