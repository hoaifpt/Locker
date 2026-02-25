using Locker.Backend.Domain.Entities;

namespace Locker.Backend.Application.Interfaces;

public interface IRefreshTokenRepository
{
    Task<RefreshToken?> GetByTokenAsync(string token, CancellationToken cancellationToken);
    Task CreateAsync(RefreshToken refreshToken, CancellationToken cancellationToken);
    Task RevokeAsync(string token, CancellationToken cancellationToken);
    Task RevokeAllByUserIdAsync(string userId, CancellationToken cancellationToken);
}
