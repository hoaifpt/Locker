using Locker.Backend.Application.Interfaces;
using Locker.Backend.Domain.Entities;
using Locker.Backend.Infrastructure.Mongo;
using MongoDB.Driver;

namespace Locker.Backend.Infrastructure.Repositories;

public class LockerSlotRepository : GenericRepository<LockerSlot>, ILockerSlotRepository
{
    public LockerSlotRepository(MongoContext context)
        : base(context.Database.GetCollection<LockerSlot>(context.Settings.LockerSlotsCollection))
    {
    }

    public async Task<List<LockerSlot>> GetByLockerIdAsync(string lockerId, CancellationToken cancellationToken)
    {
        return await _collection.Find(x => x.LockerId == lockerId).ToListAsync(cancellationToken);
    }
}