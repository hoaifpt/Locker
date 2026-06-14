using Locker.Backend.Domain.Entities;

namespace Locker.Backend.Application.Interfaces;

public interface IRefreshTokenRepository : IGenericRepository<RefreshToken>
{
    Task<RefreshToken?> GetByTokenAsync(string token, CancellationToken cancellationToken);
    Task RevokeAsync(string token, CancellationToken cancellationToken);
    Task RevokeAllByUserIdAsync(Guid userId, CancellationToken cancellationToken);
    Task<bool> IsAccessTokenRevokedAsync(string jti, CancellationToken cancellationToken);
    Task RevokeAccessTokenAsync(Guid userId, string jti, DateTime expiresAt, CancellationToken cancellationToken);
}
