namespace Locker.Backend.Application.Interfaces;

public interface IGenericRepository<T> where T : class
{
    Task<List<T>> GetAllAsync(CancellationToken cancellationToken);
    Task<T?> GetByIdAsync(string id, CancellationToken cancellationToken);
    Task CreateAsync(T entity, CancellationToken cancellationToken);
    Task UpdateAsync(T entity, CancellationToken cancellationToken);
    Task DeleteAsync(string id, CancellationToken cancellationToken);
}
