using LockerEntity = Locker.Backend.Domain.Entities.Locker;

namespace Locker.Backend.Application.Interfaces;

public interface ILockerRepository
{
    Task<List<LockerEntity>> GetAllAsync(CancellationToken cancellationToken);
    Task<LockerEntity?> GetByIdAsync(string id, CancellationToken cancellationToken);
    Task CreateAsync(LockerEntity locker, CancellationToken cancellationToken);
    Task UpdateAsync(LockerEntity locker, CancellationToken cancellationToken);
    Task DeleteAsync(string id, CancellationToken cancellationToken);
}
