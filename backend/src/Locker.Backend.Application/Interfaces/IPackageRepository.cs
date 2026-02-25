using Locker.Backend.Domain.Entities;

namespace Locker.Backend.Application.Interfaces;

public interface IPackageRepository
{
    Task<List<Package>> GetAllAsync(CancellationToken cancellationToken);
    Task<List<Package>> GetActiveAsync(CancellationToken cancellationToken);
    Task<Package?> GetByIdAsync(string id, CancellationToken cancellationToken);
    Task CreateAsync(Package package, CancellationToken cancellationToken);
    Task UpdateAsync(Package package, CancellationToken cancellationToken);
    Task DeleteAsync(string id, CancellationToken cancellationToken);
}
