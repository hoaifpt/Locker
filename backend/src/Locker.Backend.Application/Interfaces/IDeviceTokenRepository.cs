using Locker.Backend.Domain.Entities;

namespace Locker.Backend.Application.Interfaces;

public interface IDeviceTokenRepository : IGenericRepository<DeviceToken>
{
    Task<DeviceToken?> GetByUserAndTokenAsync(string userId, string token, CancellationToken cancellationToken);
    Task UpsertAsync(DeviceToken token, CancellationToken cancellationToken);
}
