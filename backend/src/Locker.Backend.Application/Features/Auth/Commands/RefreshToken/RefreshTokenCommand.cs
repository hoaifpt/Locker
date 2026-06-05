using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Models;
using MediatR;
using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.Auth.Commands.RefreshToken;

public record RefreshTokenCommand(string Token) : IRequest<AuthResponse?>;

public class RefreshTokenCommandHandler : IRequestHandler<RefreshTokenCommand, AuthResponse?>
{
    private readonly IIdentityService _identityService;
    private readonly IJwtTokenService _jwtTokenService;
    private readonly IRefreshTokenRepository _refreshTokenRepository;

    public RefreshTokenCommandHandler(
        IIdentityService identityService,
        IJwtTokenService jwtTokenService,
        IRefreshTokenRepository refreshTokenRepository)
    {
        _identityService = identityService;
        _jwtTokenService = jwtTokenService;
        _refreshTokenRepository = refreshTokenRepository;
    }

    public async Task<AuthResponse?> Handle(RefreshTokenCommand request, CancellationToken cancellationToken)
    {
        var storedToken = await _refreshTokenRepository.GetByTokenAsync(request.Token, cancellationToken);

        if (storedToken == null || storedToken.IsRevoked || storedToken.ExpiresAt <= DateTime.UtcNow)
        {
            return null;
        }

        var user = await _identityService.FindByIdAsync(storedToken.UserId.ToString());
        if (user == null || !user.IsActive)
        {
            return null;
        }

        var roles = await _identityService.GetRolesAsync(user);
        var role = roles.FirstOrDefault() ?? "User";

        var tokenSubject = new TokenSubject(user.Id, user.UserName, user.Email, role);
        var accessToken = _jwtTokenService.CreateToken(tokenSubject);
        var newRefreshTokenValue = _jwtTokenService.CreateRefreshToken();

        storedToken.IsRevoked = true;
        await _refreshTokenRepository.UpdateAsync(storedToken, cancellationToken);

        var newRefreshToken = new Domain.Entities.RefreshToken
        {
            UserId = user.Id,
            Token = newRefreshTokenValue,
            ExpiresAt = _jwtTokenService.GetRefreshTokenExpiry(),
            CreatedAt = DateTime.UtcNow,
            IsRevoked = false
        };
        await _refreshTokenRepository.CreateAsync(newRefreshToken, cancellationToken);

        return new AuthResponse
        {
            Token = accessToken,
            RefreshToken = newRefreshTokenValue,
            Username = user.UserName ?? string.Empty,
            Role = role,
            ExpiresAt = _jwtTokenService.GetAccessTokenExpiry()
        };
    }
}
