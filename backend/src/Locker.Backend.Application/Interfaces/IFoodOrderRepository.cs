using Locker.Backend.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Interfaces;

public interface IFoodOrderRepository : IGenericRepository<FoodOrder>
{
    Task<List<FoodOrder>> GetByUserIdAsync(Guid userId, CancellationToken cancellationToken = default);
}
