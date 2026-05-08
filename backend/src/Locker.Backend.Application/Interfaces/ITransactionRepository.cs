using Locker.Backend.Domain.Entities;
using Locker.Backend.Domain.Enums;

namespace Locker.Backend.Application.Interfaces;

public interface ITransactionRepository : IGenericRepository<Transaction>
{
    Task<List<Transaction>> GetByUserIdAsync(string userId, CancellationToken cancellationToken);
    Task<List<Transaction>> GetByStatusAsync(TransactionStatus status, CancellationToken cancellationToken);
}