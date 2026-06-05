using Locker.Backend.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Interfaces;

public interface IMenuItemRepository : IGenericRepository<MenuItem>
{
    Task<List<MenuItem>> GetByRestaurantIdAsync(Guid restaurantId, CancellationToken cancellationToken = default);
}
