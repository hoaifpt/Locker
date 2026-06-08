using Locker.Backend.Application.Interfaces;
using Locker.Backend.Domain.Enums;
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

    public override async Task<LockerEntity?> GetByIdAsync(Guid id, CancellationToken cancellationToken)
    {
        var cursor = await _collection.FindAsync(l => l.Id == id && !l.IsDeleted, cancellationToken: cancellationToken);
        return await cursor.FirstOrDefaultAsync(cancellationToken);
    }

    public async Task<bool> SoftDeleteAsync(Guid id, CancellationToken cancellationToken)
    {
        var locker = await GetByIdAsync(id, cancellationToken);
        if (locker == null) return false;

        locker.IsDeleted = true;
        await UpdateAsync(locker, cancellationToken);
        return true;
    }

    public async Task<bool> TryReserveSlotAsync(Guid lockerId, int slotIndex, Guid bookingId, CancellationToken cancellationToken)
    {
        var filter = Builders<LockerEntity>.Filter.And(
            Builders<LockerEntity>.Filter.Eq(l => l.Id, lockerId),
            Builders<LockerEntity>.Filter.Eq(l => l.IsDeleted, false),
            Builders<LockerEntity>.Filter.ElemMatch(l => l.Slots, s => s.Index == slotIndex && s.Status == LockerSlotStatus.Available));

        var update = Builders<LockerEntity>.Update
            .Set("slots.$.status", LockerSlotStatus.Pending)
            .Set("slots.$.bookingId", bookingId);

        var result = await _collection.UpdateOneAsync(filter, update, cancellationToken: cancellationToken);
        return result.ModifiedCount > 0;
    }
}
