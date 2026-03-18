using Locker.Backend.Domain.Entities;
using Locker.Backend.Domain.Enums;

namespace Locker.Backend.Application.Interfaces;

public interface IOrderRepository : IGenericRepository<Order>
{
    Task<List<Order>> GetByUserIdAsync(string userId, CancellationToken cancellationToken);
    Task<List<Order>> GetByUserIdAndStatusAsync(string userId, OrderStatus status, CancellationToken cancellationToken);
    Task<List<Order>> GetByStatusAsync(OrderStatus status, CancellationToken cancellationToken);
    Task<Order?> GetActiveBySlotAsync(string lockerId, int slotIndex, CancellationToken cancellationToken);
    Task<List<Order>> GetConflictingOrdersAsync(string lockerId, int slotIndex, DateTime checkInTime, DateTime checkOutTime, CancellationToken cancellationToken);
    Task<List<Order>> GetByLockerIdAsync(string lockerId, CancellationToken cancellationToken);
    Task<List<Order>> GetExpiredOrdersAsync(CancellationToken cancellationToken);
}
