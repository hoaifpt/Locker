using LockerEntity = Locker.Backend.Domain.Entities.Locker;

namespace Locker.Backend.Application.Interfaces;

public interface ILockerRepository : IGenericRepository<LockerEntity>
{
    Task<bool> SoftDeleteAsync(Guid id, CancellationToken cancellationToken);
    Task<bool> TryReserveSlotAsync(Guid lockerId, int slotIndex, Guid bookingId, CancellationToken cancellationToken);
}
