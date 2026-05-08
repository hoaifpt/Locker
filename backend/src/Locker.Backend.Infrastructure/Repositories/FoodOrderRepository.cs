using Locker.Backend.Application.Interfaces;
using Locker.Backend.Domain.Entities;
using Locker.Backend.Infrastructure.Mongo;
using MongoDB.Driver;

namespace Locker.Backend.Infrastructure.Repositories;

public class FoodOrderRepository : GenericRepository<FoodOrder>, IFoodOrderRepository
{
    public FoodOrderRepository(MongoContext context)
        : base(context.Database.GetCollection<FoodOrder>(context.Settings.FoodOrdersCollection))
    {
    }

    public async Task<FoodOrder?> GetByTransactionIdAsync(string transactionId, CancellationToken cancellationToken)
    {
        return await _collection.Find(x => x.TransactionId == transactionId).FirstOrDefaultAsync(cancellationToken);
    }
}