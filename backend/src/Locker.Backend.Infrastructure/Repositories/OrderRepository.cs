using Locker.Backend.Application.Interfaces;
using Locker.Backend.Domain.Entities;
using Locker.Backend.Domain.Enums;
using Locker.Backend.Infrastructure.Mongo;
using MongoDB.Driver;

namespace Locker.Backend.Infrastructure.Repositories;

public class OrderRepository : GenericRepository<Order>, IOrderRepository
{
    public OrderRepository(MongoContext context)
        : base(context.Database.GetCollection<Order>(context.Settings.OrdersCollection))
    {
    }

    public async Task<List<Order>> GetByUserIdAsync(Guid userId, CancellationToken cancellationToken)
    {
        var cursor = await _collection.FindAsync(
            o => o.UserId == userId,
            cancellationToken: cancellationToken);
        return await cursor.ToListAsync(cancellationToken);
    }

    public async Task<List<Order>> GetByUserIdAndStatusAsync(
        Guid userId,
        OrderStatus status,
        CancellationToken cancellationToken)
    {
        var cursor = await _collection.FindAsync(
            o => o.UserId == userId && o.Status == status,
            cancellationToken: cancellationToken);
        return await cursor.ToListAsync(cancellationToken);
    }

    public async Task<List<Order>> GetByStatusAsync(OrderStatus status, CancellationToken cancellationToken)
    {
        var cursor = await _collection.FindAsync(
            o => o.Status == status,
            cancellationToken: cancellationToken);
        return await cursor.ToListAsync(cancellationToken);
    }

    public async Task<Order?> GetActiveBySlotAsync(
        Guid lockerId,
        int slotIndex,
        CancellationToken cancellationToken)
    {
        var cursor = await _collection.FindAsync(
            o => o.LockerId == lockerId &&
                 o.SlotIndex == slotIndex &&
                 (o.Status == OrderStatus.Active ||
                  o.Status == OrderStatus.Reserved ||
                  o.Status == OrderStatus.Paid),
            cancellationToken: cancellationToken);
        return await cursor.FirstOrDefaultAsync(cancellationToken);
    }

    public async Task<List<Order>> GetConflictingOrdersAsync(
        Guid lockerId,
        int slotIndex,
        DateTime checkInTime,
        DateTime checkOutTime,
        CancellationToken cancellationToken)
    {
        var cursor = await _collection.FindAsync(
            o => o.LockerId == lockerId &&
                 o.SlotIndex == slotIndex &&
                 (o.Status == OrderStatus.Reserved ||
                  o.Status == OrderStatus.Paid ||
                  o.Status == OrderStatus.Active) &&
                 o.CheckInTime < checkOutTime &&
                 o.CheckOutTime > checkInTime,
            cancellationToken: cancellationToken);
        return await cursor.ToListAsync(cancellationToken);
    }

    public async Task<List<Order>> GetByLockerIdAsync(
        Guid lockerId,
        CancellationToken cancellationToken)
    {
        var cursor = await _collection.FindAsync(
            o => o.LockerId == lockerId,
            cancellationToken: cancellationToken);
        return await cursor.ToListAsync(cancellationToken);
    }

    public async Task<List<Order>> GetExpiredOrdersAsync(CancellationToken cancellationToken)
    {
        var expirationTime = DateTime.UtcNow.AddMinutes(-15); // Orders older than 15 minutes
        var cursor = await _collection.FindAsync(
            o => o.Status == OrderStatus.Initiated &&
                 o.CreatedAt < expirationTime,
            cancellationToken: cancellationToken);
        return await cursor.ToListAsync(cancellationToken);
    }

    public async Task<List<Order>> GetOverdueActiveOrdersAsync(CancellationToken cancellationToken)
    {
        var now = DateTime.UtcNow;
        var cursor = await _collection.FindAsync(
            o => o.Status == OrderStatus.Active &&
                 o.CheckOutTime < now,
            cancellationToken: cancellationToken);
        return await cursor.ToListAsync(cancellationToken);
    }
}
