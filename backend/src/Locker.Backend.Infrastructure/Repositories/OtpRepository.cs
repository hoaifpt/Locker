using Locker.Backend.Application.Interfaces;
using Locker.Backend.Domain.Entities;
using Locker.Backend.Infrastructure.Mongo;
using MongoDB.Driver;

namespace Locker.Backend.Infrastructure.Repositories;

public class OtpRepository : IOtpRepository
{
    private readonly IMongoCollection<OtpCode> _collection;

    public OtpRepository(MongoContext context)
    {
        _collection = context.Database.GetCollection<OtpCode>(context.Settings.OtpCodesCollection);
    }

    public Task CreateAsync(OtpCode otpCode, CancellationToken cancellationToken)
        => _collection.InsertOneAsync(otpCode, cancellationToken: cancellationToken);

    public async Task<OtpCode?> GetLatestValidAsync(string userId, string target, CancellationToken cancellationToken)
    {
        var filter = Builders<OtpCode>.Filter.And(
            Builders<OtpCode>.Filter.Eq(o => o.UserId, userId),
            Builders<OtpCode>.Filter.Eq(o => o.Target, target),
            Builders<OtpCode>.Filter.Eq(o => o.IsUsed, false),
            Builders<OtpCode>.Filter.Gt(o => o.ExpiresAt, DateTime.UtcNow)
        );
        var sort = Builders<OtpCode>.Sort.Descending(o => o.CreatedAt);
        var cursor = await _collection.FindAsync(filter, new FindOptions<OtpCode> { Sort = sort, Limit = 1 }, cancellationToken);
        return await cursor.FirstOrDefaultAsync(cancellationToken);
    }

    public async Task MarkUsedAsync(string id, CancellationToken cancellationToken)
    {
        var update = Builders<OtpCode>.Update.Set(o => o.IsUsed, true);
        await _collection.UpdateOneAsync(o => o.Id == id, update, cancellationToken: cancellationToken);
    }

    public async Task DeleteExpiredAsync(CancellationToken cancellationToken)
    {
        await _collection.DeleteManyAsync(
            Builders<OtpCode>.Filter.Lt(o => o.ExpiresAt, DateTime.UtcNow),
            cancellationToken);
    }
}
