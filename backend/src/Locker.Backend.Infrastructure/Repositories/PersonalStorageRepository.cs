using Locker.Backend.Application.Interfaces;
using Locker.Backend.Domain.Entities;
using Locker.Backend.Infrastructure.Mongo;
using MongoDB.Driver;

namespace Locker.Backend.Infrastructure.Repositories;

public class PersonalStorageRepository : GenericRepository<PersonalStorage>, IPersonalStorageRepository
{
    public PersonalStorageRepository(MongoContext context)
        : base(context.Database.GetCollection<PersonalStorage>(context.Settings.PersonalStorageCollection))
    {
    }

    public async Task<PersonalStorage?> GetByTransactionIdAsync(string transactionId, CancellationToken cancellationToken)
    {
        return await _collection.Find(x => x.TransactionId == transactionId).FirstOrDefaultAsync(cancellationToken);
    }
}