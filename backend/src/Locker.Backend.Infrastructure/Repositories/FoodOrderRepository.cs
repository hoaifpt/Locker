using Locker.Backend.Application.Interfaces;
using Locker.Backend.Domain.Entities;
using Locker.Backend.Infrastructure.Mongo;
using MongoDB.Driver;
using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Infrastructure.Repositories;

public class FoodOrderRepository : GenericRepository<FoodOrder>, IFoodOrderRepository
{
    public FoodOrderRepository(MongoContext context)
        : base(context.Database.GetCollection<FoodOrder>(context.Settings.FoodOrdersCollection))
    {
    }

    public async Task<List<FoodOrder>> GetByUserIdAsync(Guid userId, CancellationToken cancellationToken = default)
    {
        return await _collection.Find(x => x.UserId == userId)
            .SortByDescending(x => x.CreatedAt)
            .ToListAsync(cancellationToken);
    }
}
