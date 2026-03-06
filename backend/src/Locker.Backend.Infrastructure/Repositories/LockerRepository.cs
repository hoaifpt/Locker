using Locker.Backend.Application.Interfaces;
using Locker.Backend.Domain.Entities;
using LockerEntity = Locker.Backend.Domain.Entities.Locker;
using Locker.Backend.Infrastructure.Mongo;
using MongoDB.Driver;

namespace Locker.Backend.Infrastructure.Repositories;

public class LockerRepository : ILockerRepository
{
    private readonly IMongoCollection<LockerEntity> _collection;

    public LockerRepository(MongoContext context)
    {
        _collection = context.Database.GetCollection<LockerEntity>(context.Settings.LockersCollection);
    }

    public async Task<List<LockerEntity>> GetAllAsync(CancellationToken cancellationToken)
    {
        return await _collection.Find(l => !l.IsDeleted).ToListAsync(cancellationToken);
    }

    public async Task<LockerEntity?> GetByIdAsync(string id, CancellationToken cancellationToken)
    {
        var cursor = await _collection.FindAsync(l => l.Id == id && !l.IsDeleted, cancellationToken: cancellationToken);
        return await cursor.FirstOrDefaultAsync(cancellationToken);
    }

    public Task CreateAsync(LockerEntity locker, CancellationToken cancellationToken)
    {
        return _collection.InsertOneAsync(locker, cancellationToken: cancellationToken);
    }

    public Task UpdateAsync(LockerEntity locker, CancellationToken cancellationToken)
    {
        return _collection.ReplaceOneAsync(l => l.Id == locker.Id, locker, cancellationToken: cancellationToken);
    }

    public async Task<bool> SoftDeleteAsync(string id, CancellationToken cancellationToken)
    {
        var locker = await GetByIdAsync(id, cancellationToken);
        if (locker == null) return false;

        locker.IsDeleted = true;
        await UpdateAsync(locker, cancellationToken);
        return true;
    }
}
