using Locker.Backend.Application.Interfaces;
using Locker.Backend.Domain.Entities;
using Locker.Backend.Infrastructure.Mongo;
using MongoDB.Driver;

namespace Locker.Backend.Infrastructure.Repositories;

public class PackageRepository : IPackageRepository
{
    private readonly IMongoCollection<Package> _collection;

    public PackageRepository(MongoContext context)
    {
        _collection = context.Database.GetCollection<Package>(context.Settings.PackagesCollection);
    }

    public async Task<List<Package>> GetAllAsync(CancellationToken cancellationToken)
    {
        var cursor = await _collection.FindAsync(_ => true, cancellationToken: cancellationToken);
        return await cursor.ToListAsync(cancellationToken);
    }

    public async Task<List<Package>> GetActiveAsync(CancellationToken cancellationToken)
    {
        var cursor = await _collection.FindAsync(p => p.IsActive, cancellationToken: cancellationToken);
        return await cursor.ToListAsync(cancellationToken);
    }

    public async Task<Package?> GetByIdAsync(string id, CancellationToken cancellationToken)
    {
        var cursor = await _collection.FindAsync(p => p.Id == id, cancellationToken: cancellationToken);
        return await cursor.FirstOrDefaultAsync(cancellationToken);
    }

    public Task CreateAsync(Package package, CancellationToken cancellationToken)
        => _collection.InsertOneAsync(package, cancellationToken: cancellationToken);

    public Task UpdateAsync(Package package, CancellationToken cancellationToken)
        => _collection.ReplaceOneAsync(p => p.Id == package.Id, package, cancellationToken: cancellationToken);

    public Task DeleteAsync(string id, CancellationToken cancellationToken)
        => _collection.DeleteOneAsync(p => p.Id == id, cancellationToken);
}
