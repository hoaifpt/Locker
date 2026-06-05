using Locker.Backend.Application.Interfaces;
using Locker.Backend.Domain.Entities;
using Locker.Backend.Infrastructure.Mongo;

namespace Locker.Backend.Infrastructure.Repositories;

public class RestaurantRepository : GenericRepository<Restaurant>, IRestaurantRepository
{
    public RestaurantRepository(MongoContext context)
        : base(context.Database.GetCollection<Restaurant>(context.Settings.RestaurantsCollection))
    {
    }
}
