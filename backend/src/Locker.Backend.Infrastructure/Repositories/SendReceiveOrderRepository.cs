using Locker.Backend.Application.Interfaces;
using Locker.Backend.Domain.Entities;
using Locker.Backend.Infrastructure.Mongo;
using MongoDB.Driver;
using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Infrastructure.Repositories;

public class SendReceiveOrderRepository : GenericRepository<SendReceiveOrder>, ISendReceiveOrderRepository
{
    public SendReceiveOrderRepository(MongoContext context)
        : base(context.Database.GetCollection<SendReceiveOrder>(context.Settings.SendReceiveOrdersCollection))
    {
    }

    public async Task<List<SendReceiveOrder>> GetBySenderIdAsync(Guid senderId, CancellationToken cancellationToken = default)
    {
        return await _collection.Find(x => x.SenderId == senderId)
            .SortByDescending(x => x.CreatedAt)
            .ToListAsync(cancellationToken);
    }

    public async Task<List<SendReceiveOrder>> GetByReceiverPhoneAsync(string phone, CancellationToken cancellationToken = default)
    {
        return await _collection.Find(x => x.ReceiverPhone == phone)
            .SortByDescending(x => x.CreatedAt)
            .ToListAsync(cancellationToken);
    }
}
