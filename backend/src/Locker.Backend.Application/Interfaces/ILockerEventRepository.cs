using Locker.Backend.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Interfaces;

public interface ILockerEventRepository : IGenericRepository<LockerEvent>
{
    Task<List<LockerEvent>> GetByLockerIdAsync(Guid lockerId, CancellationToken cancellationToken = default);
    Task<List<LockerEvent>> GetByLockerAndSlotAsync(Guid lockerId, int slotIndex, CancellationToken cancellationToken = default);
}
