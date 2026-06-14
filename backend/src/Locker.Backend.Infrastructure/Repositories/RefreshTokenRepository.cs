using Locker.Backend.Application.Interfaces;
using Locker.Backend.Domain.Entities;
using Locker.Backend.Infrastructure.Mongo;
using MongoDB.Driver;

namespace Locker.Backend.Infrastructure.Repositories;

public class RefreshTokenRepository : GenericRepository<RefreshToken>, IRefreshTokenRepository
{
    public RefreshTokenRepository(MongoContext context)
        : base(context.Database.GetCollection<RefreshToken>(context.Settings.RefreshTokensCollection))
    {
    }

    public async Task<RefreshToken?> GetByTokenAsync(string token, CancellationToken cancellationToken)
    {
        var cursor = await _collection.FindAsync(rt => rt.Token == token, cancellationToken: cancellationToken);
        return await cursor.FirstOrDefaultAsync(cancellationToken);
    }

    public Task RevokeAsync(string token, CancellationToken cancellationToken)
    {
        var update = Builders<RefreshToken>.Update.Set(rt => rt.IsRevoked, true);
        return _collection.UpdateOneAsync(rt => rt.Token == token, update, cancellationToken: cancellationToken);
    }

    public Task RevokeAllByUserIdAsync(Guid userId, CancellationToken cancellationToken)
    {
        var update = Builders<RefreshToken>.Update.Set(rt => rt.IsRevoked, true);
        return _collection.UpdateManyAsync(rt => rt.UserId == userId && !rt.IsRevoked, update, cancellationToken: cancellationToken);
    }

    public async Task<bool> IsAccessTokenRevokedAsync(string jti, CancellationToken cancellationToken)
    {
        var cursor = await _collection.FindAsync(
            rt => rt.RevokedAccessTokenJti == jti && rt.ExpiresAt > DateTime.UtcNow,
            cancellationToken: cancellationToken);
        return await cursor.AnyAsync(cancellationToken);
    }

    public Task RevokeAccessTokenAsync(Guid userId, string jti, DateTime expiresAt, CancellationToken cancellationToken)
    {
        var revokedToken = new RefreshToken
        {
            UserId = userId,
            Token = $"revoked-access:{jti}",
            ExpiresAt = expiresAt,
            CreatedAt = DateTime.UtcNow,
            IsRevoked = true,
            RevokedAccessTokenJti = jti
        };

        return _collection.InsertOneAsync(revokedToken, cancellationToken: cancellationToken);
    }
}
