using Locker.Backend.Domain.Entities;

namespace Locker.Backend.Application.Interfaces;

public interface IPackageRepository : IGenericRepository<Package>
{
    Task<List<Package>> GetActiveAsync(CancellationToken cancellationToken);
    Task<bool> SoftDeleteAsync(string id, CancellationToken cancellationToken);
}
