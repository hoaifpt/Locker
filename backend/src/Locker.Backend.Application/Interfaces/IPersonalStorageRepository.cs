using Locker.Backend.Domain.Entities;

namespace Locker.Backend.Application.Interfaces;

public interface IPersonalStorageRepository : IGenericRepository<PersonalStorage>
{
    Task<PersonalStorage?> GetByTransactionIdAsync(string transactionId, CancellationToken cancellationToken);
}