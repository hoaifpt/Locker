using Locker.Backend.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Interfaces;

public interface IDeliveryRequestRepository : IGenericRepository<DeliveryRequest>
{
    Task<List<DeliveryRequest>> GetByUserIdAsync(Guid userId, CancellationToken cancellationToken = default);
    Task<DeliveryRequest?> GetByTrackingCodeAsync(string trackingCode, CancellationToken cancellationToken = default);
}
