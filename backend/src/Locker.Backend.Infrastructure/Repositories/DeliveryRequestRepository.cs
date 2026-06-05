using Locker.Backend.Application.Interfaces;
using Locker.Backend.Domain.Entities;
using Locker.Backend.Infrastructure.Mongo;
using MongoDB.Driver;
using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Infrastructure.Repositories;

public class DeliveryRequestRepository : GenericRepository<DeliveryRequest>, IDeliveryRequestRepository
{
    public DeliveryRequestRepository(MongoContext context)
        : base(context.Database.GetCollection<DeliveryRequest>(context.Settings.DeliveryRequestsCollection))
    {
    }

    public async Task<List<DeliveryRequest>> GetByUserIdAsync(Guid userId, CancellationToken cancellationToken = default)
    {
        return await _collection.Find(x => x.UserId == userId)
            .SortByDescending(x => x.CreatedAt)
            .ToListAsync(cancellationToken);
    }

    public async Task<DeliveryRequest?> GetByTrackingCodeAsync(string trackingCode, CancellationToken cancellationToken = default)
    {
        return await _collection.Find(x => x.TrackingCode == trackingCode).FirstOrDefaultAsync(cancellationToken);
    }
}
