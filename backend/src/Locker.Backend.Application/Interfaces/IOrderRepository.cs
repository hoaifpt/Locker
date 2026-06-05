using Locker.Backend.Domain.Entities;
using Locker.Backend.Domain.Enums;

namespace Locker.Backend.Application.Interfaces;

public interface IOrderRepository : IGenericRepository<Order>
{
    Task<List<Order>> GetByUserIdAsync(Guid userId, CancellationToken cancellationToken);
    Task<List<Order>> GetByUserIdAndStatusAsync(Guid userId, OrderStatus status, CancellationToken cancellationToken);
    Task<List<Order>> GetByStatusAsync(OrderStatus status, CancellationToken cancellationToken);
    Task<Order?> GetActiveBySlotAsync(Guid lockerId, int slotIndex, CancellationToken cancellationToken);
    Task<List<Order>> GetConflictingOrdersAsync(Guid lockerId, int slotIndex, DateTime checkInTime, DateTime checkOutTime, CancellationToken cancellationToken);
    Task<List<Order>> GetByLockerIdAsync(Guid lockerId, CancellationToken cancellationToken);
    Task<List<Order>> GetExpiredOrdersAsync(CancellationToken cancellationToken);
}
