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

    public Task<List<LockerEntity>> GetAllAsync(CancellationToken cancellationToken)
    {
        return _collection.Find(_ => true).ToListAsync(cancellationToken);
    }

    public async Task<LockerEntity?> GetByIdAsync(string id, CancellationToken cancellationToken)
    {
        var cursor = await _collection.FindAsync(l => l.Id == id, cancellationToken: cancellationToken);
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

    public Task DeleteAsync(string id, CancellationToken cancellationToken)
    {
        return _collection.DeleteOneAsync(l => l.Id == id, cancellationToken);
    }
}
