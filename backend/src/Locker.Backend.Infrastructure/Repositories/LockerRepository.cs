using Locker.Backend.Application.Interfaces;
using LockerEntity = Locker.Backend.Domain.Entities.Locker;
using Locker.Backend.Infrastructure.Mongo;
using MongoDB.Driver;

namespace Locker.Backend.Infrastructure.Repositories;

public class LockerRepository : GenericRepository<LockerEntity>, ILockerRepository
{
    public LockerRepository(MongoContext context)
        : base(context.Database.GetCollection<LockerEntity>(context.Settings.LockersCollection))
    {
    }

    public override async Task<List<LockerEntity>> GetAllAsync(CancellationToken cancellationToken)
    {
        return await _collection.Find(l => !l.IsDeleted).ToListAsync(cancellationToken);
    }

    public override async Task<LockerEntity?> GetByIdAsync(string id, CancellationToken cancellationToken)
    {
        var cursor = await _collection.FindAsync(l => l.Id == id && !l.IsDeleted, cancellationToken: cancellationToken);
        return await cursor.FirstOrDefaultAsync(cancellationToken);
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
