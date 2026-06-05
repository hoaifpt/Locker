using Locker.Backend.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Interfaces;

public interface ISendReceiveOrderRepository : IGenericRepository<SendReceiveOrder>
{
    Task<List<SendReceiveOrder>> GetBySenderIdAsync(Guid senderId, CancellationToken cancellationToken = default);
    Task<List<SendReceiveOrder>> GetByReceiverPhoneAsync(string phone, CancellationToken cancellationToken = default);
}
