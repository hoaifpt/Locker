using System.Linq.Expressions;
using Locker.Backend.Application.Interfaces;
using Locker.Backend.Domain.Entities;
using MongoDB.Driver;

namespace Locker.Backend.Infrastructure.Repositories;

public class GenericRepository<T> : IGenericRepository<T> where T : BaseEntity
{
    protected readonly IMongoCollection<T> _collection;

    public GenericRepository(IMongoCollection<T> collection)
    {
        _collection = collection;
    }

    public virtual async Task<T?> GetByIdAsync(Guid id, CancellationToken cancellationToken)
    {
        var cursor = await _collection.FindAsync(e => e.Id == id, cancellationToken: cancellationToken);
        return await cursor.FirstOrDefaultAsync(cancellationToken);
    }

    public virtual async Task<List<T>> GetAllAsync(CancellationToken cancellationToken)
    {
        var cursor = await _collection.FindAsync(_ => true, cancellationToken: cancellationToken);
        return await cursor.ToListAsync(cancellationToken);
    }

    public async Task<List<T>> FindAsync(Expression<Func<T, bool>> filter, CancellationToken cancellationToken)
    {
        var cursor = await _collection.FindAsync(filter, cancellationToken: cancellationToken);
        return await cursor.ToListAsync(cancellationToken);
    }

    public async Task<T?> FindOneAsync(Expression<Func<T, bool>> filter, CancellationToken cancellationToken)
    {
        var cursor = await _collection.FindAsync(filter, cancellationToken: cancellationToken);
        return await cursor.FirstOrDefaultAsync(cancellationToken);
    }

    public Task CreateAsync(T entity, CancellationToken cancellationToken)
    {
        return _collection.InsertOneAsync(entity, cancellationToken: cancellationToken);
    }

    public Task UpdateAsync(T entity, CancellationToken cancellationToken)
    {
        if (entity is Order order)
        {
            var currentVersion = order.Version;
            order.Version++;

            return ReplaceWithConcurrencyCheckAsync(
                entity,
                Builders<T>.Filter.And(
                    Builders<T>.Filter.Eq(x => x.Id, entity.Id),
                    Builders<T>.Filter.Eq("version", currentVersion)),
                cancellationToken);
        }

        return _collection.ReplaceOneAsync(e => e.Id == entity.Id, entity, cancellationToken: cancellationToken);
    }

    public Task DeleteAsync(Guid id, CancellationToken cancellationToken)
    {
        return _collection.DeleteOneAsync(e => e.Id == id, cancellationToken: cancellationToken);
    }

    private async Task ReplaceWithConcurrencyCheckAsync(T entity, FilterDefinition<T> filter, CancellationToken cancellationToken)
    {
        var result = await _collection.ReplaceOneAsync(filter, entity, cancellationToken: cancellationToken);
        if (result.ModifiedCount == 0)
        {
            throw new InvalidOperationException("Concurrency conflict detected while updating entity.");
        }
    }
}
