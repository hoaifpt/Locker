using Locker.Backend.Domain.Entities;

namespace Locker.Backend.Application.Interfaces;

public interface ILockerSlotRepository : IGenericRepository<LockerSlot>
{
    Task<List<LockerSlot>> GetByLockerIdAsync(string lockerId, CancellationToken cancellationToken);
}