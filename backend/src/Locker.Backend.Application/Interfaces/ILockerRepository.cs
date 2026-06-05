using LockerEntity = Locker.Backend.Domain.Entities.Locker;

namespace Locker.Backend.Application.Interfaces;

public interface ILockerRepository : IGenericRepository<LockerEntity>
{
    Task<bool> SoftDeleteAsync(Guid id, CancellationToken cancellationToken);
}
