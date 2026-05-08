using Locker.Backend.Application.Interfaces;
using Locker.Backend.Domain.Entities;
using Locker.Backend.Domain.Enums;
using Locker.Backend.Infrastructure.Mongo;
using MongoDB.Driver;

namespace Locker.Backend.Infrastructure.Repositories;

public class TransactionRepository : GenericRepository<Transaction>, ITransactionRepository
{
    public TransactionRepository(MongoContext context)
        : base(context.Database.GetCollection<Transaction>(context.Settings.TransactionsCollection))
    {
    }

    public async Task<List<Transaction>> GetByUserIdAsync(string userId, CancellationToken cancellationToken)
    {
        return await _collection.Find(x => x.UserId == userId)
                                .SortByDescending(x => x.CreatedAt)
                                .ToListAsync(cancellationToken);
    }

    public async Task<List<Transaction>> GetByStatusAsync(TransactionStatus status, CancellationToken cancellationToken)
    {
        return await _collection.Find(x => x.Status == status)
                                .SortByDescending(x => x.CreatedAt)
                                .ToListAsync(cancellationToken);
    }
}