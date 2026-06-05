using Locker.Backend.Application.Interfaces;
using Locker.Backend.Domain.Entities;
using Locker.Backend.Infrastructure.Mongo;
using MongoDB.Driver;
using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Infrastructure.Repositories;

public class LockerEventRepository : GenericRepository<LockerEvent>, ILockerEventRepository
{
    public LockerEventRepository(MongoContext context)
        : base(context.Database.GetCollection<LockerEvent>(context.Settings.LockerEventsCollection ?? "locker_events"))
    {
    }

    public async Task<List<LockerEvent>> GetByLockerIdAsync(Guid lockerId, CancellationToken cancellationToken = default)
    {
        return await _collection.Find(x => x.LockerId == lockerId)
            .SortByDescending(x => x.CreatedAt)
            .ToListAsync(cancellationToken);
    }

    public async Task<List<LockerEvent>> GetByLockerAndSlotAsync(Guid lockerId, int slotIndex, CancellationToken cancellationToken = default)
    {
        return await _collection.Find(x => x.LockerId == lockerId && x.SlotIndex == slotIndex)
            .SortByDescending(x => x.CreatedAt)
            .ToListAsync(cancellationToken);
    }
}
