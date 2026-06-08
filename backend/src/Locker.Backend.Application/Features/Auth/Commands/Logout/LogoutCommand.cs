using Locker.Backend.Application.Interfaces;
using MediatR;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.Auth.Commands.Logout;

public record LogoutCommand(string RefreshToken, Guid? UserId = null, string? AccessTokenJti = null, DateTime? AccessTokenExpiresAt = null) : IRequest<bool>;

public class LogoutCommandHandler : IRequestHandler<LogoutCommand, bool>
{
    private readonly IRefreshTokenRepository _refreshTokenRepository;

    public LogoutCommandHandler(IRefreshTokenRepository refreshTokenRepository)
    {
        _refreshTokenRepository = refreshTokenRepository;
    }

    public async Task<bool> Handle(LogoutCommand request, CancellationToken cancellationToken)
    {
        var storedToken = await _refreshTokenRepository.GetByTokenAsync(request.RefreshToken, cancellationToken);
        if (storedToken != null)
        {
            storedToken.IsRevoked = true;
            await _refreshTokenRepository.UpdateAsync(storedToken, cancellationToken);
        }

        if (request.UserId.HasValue &&
            !string.IsNullOrWhiteSpace(request.AccessTokenJti) &&
            request.AccessTokenExpiresAt.HasValue &&
            request.AccessTokenExpiresAt.Value > DateTime.UtcNow)
        {
            await _refreshTokenRepository.RevokeAccessTokenAsync(
                request.UserId.Value,
                request.AccessTokenJti,
                request.AccessTokenExpiresAt.Value,
                cancellationToken);
        }

        return storedToken != null;
    }
}
