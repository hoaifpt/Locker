using Locker.Backend.Application.Interfaces;
using Locker.Backend.Domain.Entities;
using Locker.Backend.Infrastructure.Mongo;
using MongoDB.Driver;
using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Infrastructure.Repositories;

public class MenuItemRepository : GenericRepository<MenuItem>, IMenuItemRepository
{
    public MenuItemRepository(MongoContext context)
        : base(context.Database.GetCollection<MenuItem>(context.Settings.MenuItemsCollection))
    {
    }

    public async Task<List<MenuItem>> GetByRestaurantIdAsync(Guid restaurantId, CancellationToken cancellationToken = default)
    {
        return await _collection.Find(x => x.RestaurantId == restaurantId).ToListAsync(cancellationToken);
    }
}
