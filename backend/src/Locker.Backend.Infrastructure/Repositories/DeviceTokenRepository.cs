using Locker.Backend.Application.Interfaces;
using Locker.Backend.Domain.Entities;
using Locker.Backend.Infrastructure.Mongo;
using MongoDB.Driver;
using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Infrastructure.Repositories;

public class DeviceTokenRepository : GenericRepository<DeviceToken>, IDeviceTokenRepository
{
    public DeviceTokenRepository(MongoContext context)
        : base(context.Database.GetCollection<DeviceToken>(context.Settings.DeviceTokensCollection))
    {
    }

    public async Task<DeviceToken?> GetByUserAndTokenAsync(Guid userId, string token, CancellationToken cancellationToken)
    {
        var cursor = await _collection.FindAsync(
            t => t.UserId == userId && t.Token == token,
            cancellationToken: cancellationToken);
        return await cursor.FirstOrDefaultAsync(cancellationToken);
    }

    public async Task UpsertAsync(DeviceToken token, CancellationToken cancellationToken)
    {
        var filter = Builders<DeviceToken>.Filter.Where(t => t.UserId == token.UserId && t.Token == token.Token);
        var update = Builders<DeviceToken>.Update
            .Set(t => t.Platform, token.Platform)
            .Set(t => t.UpdatedAt, token.UpdatedAt)
            .SetOnInsert(t => t.CreatedAt, token.CreatedAt);

        await _collection.UpdateOneAsync(
            filter,
            update,
            new UpdateOptions { IsUpsert = true },
            cancellationToken);
    }

    public async Task<List<DeviceToken>> GetByUserIdAsync(Guid userId, CancellationToken cancellationToken = default)
    {
        return await _collection.Find(x => x.UserId == userId).ToListAsync(cancellationToken);
    }
}
