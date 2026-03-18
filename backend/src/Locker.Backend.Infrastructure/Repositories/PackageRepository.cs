using Locker.Backend.Application.Interfaces;
using Locker.Backend.Domain.Entities;
using Locker.Backend.Infrastructure.Mongo;
using MongoDB.Driver;

namespace Locker.Backend.Infrastructure.Repositories;

public class PackageRepository : GenericRepository<Package>, IPackageRepository
{
    public PackageRepository(MongoContext context)
        : base(context.Database.GetCollection<Package>(context.Settings.PackagesCollection))
    {
    }

    public override async Task<List<Package>> GetAllAsync(CancellationToken cancellationToken)
    {
        var cursor = await _collection.FindAsync(p => !p.IsDeleted, cancellationToken: cancellationToken);
        return await cursor.ToListAsync(cancellationToken);
    }

    public override async Task<Package?> GetByIdAsync(string id, CancellationToken cancellationToken)
    {
        var cursor = await _collection.FindAsync(p => p.Id == id && !p.IsDeleted, cancellationToken: cancellationToken);
        return await cursor.FirstOrDefaultAsync(cancellationToken);
    }

    public async Task<List<Package>> GetActiveAsync(CancellationToken cancellationToken)
    {
        var cursor = await _collection.FindAsync(p => p.IsActive && !p.IsDeleted, cancellationToken: cancellationToken);
        return await cursor.ToListAsync(cancellationToken);
    }

    public async Task<bool> SoftDeleteAsync(string id, CancellationToken cancellationToken)
    {
        var package = await GetByIdAsync(id, cancellationToken);
        if (package == null) return false;

        package.IsDeleted = true;
        await UpdateAsync(package, cancellationToken);
        return true;
    }
}
