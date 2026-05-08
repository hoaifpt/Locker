using Locker.Backend.Domain.Entities;

namespace Locker.Backend.Application.Interfaces;

public interface IFoodOrderRepository : IGenericRepository<FoodOrder>
{
    Task<FoodOrder?> GetByTransactionIdAsync(string transactionId, CancellationToken cancellationToken);
}