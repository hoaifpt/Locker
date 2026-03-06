using System.Linq.Expressions;
using Locker.Backend.Domain.Entities;

namespace Locker.Backend.Application.Interfaces;

public interface IGenericRepository<T> where T : BaseEntity
{
    Task<T?> GetByIdAsync(string id, CancellationToken cancellationToken);
    Task<List<T>> GetAllAsync(CancellationToken cancellationToken);
    Task<List<T>> FindAsync(Expression<Func<T, bool>> filter, CancellationToken cancellationToken);
    Task<T?> FindOneAsync(Expression<Func<T, bool>> filter, CancellationToken cancellationToken);
    Task CreateAsync(T entity, CancellationToken cancellationToken);
    Task UpdateAsync(T entity, CancellationToken cancellationToken);
    Task DeleteAsync(string id, CancellationToken cancellationToken);
}
