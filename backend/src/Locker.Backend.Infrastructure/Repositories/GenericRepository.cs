using Locker.Backend.Application.Interfaces;
using MongoDB.Driver;

namespace Locker.Backend.Infrastructure.Repositories;

public abstract class GenericRepository<T> : IGenericRepository<T> where T : class
{
    protected readonly IMongoCollection<T> _collection;

    protected GenericRepository(IMongoCollection<T> collection)
    {
        _collection = collection;
    }

    public virtual async Task<List<T>> GetAllAsync(CancellationToken cancellationToken)
    {
        var cursor = await _collection.FindAsync(_ => true, cancellationToken: cancellationToken);
        return await cursor.ToListAsync(cancellationToken);
    }

    public virtual async Task<T?> GetByIdAsync(string id, CancellationToken cancellationToken)
    {
        // This is a placeholder. Subclasses should override if they have a specific ID field.
        throw new NotImplementedException("GetByIdAsync must be implemented by derived classes.");
    }

    public virtual async Task CreateAsync(T entity, CancellationToken cancellationToken)
    {
        await _collection.InsertOneAsync(entity, cancellationToken: cancellationToken);
    }

    public virtual async Task UpdateAsync(T entity, CancellationToken cancellationToken)
    {
        // This is a placeholder. Subclasses should override with proper update logic.
        throw new NotImplementedException("UpdateAsync must be implemented by derived classes.");
    }

    public virtual async Task DeleteAsync(string id, CancellationToken cancellationToken)
    {
        // This is a placeholder. Subclasses should override with proper delete logic.
        throw new NotImplementedException("DeleteAsync must be implemented by derived classes.");
    }
}
