using Locker.Backend.Domain.Entities;

namespace Locker.Backend.Application.Interfaces;

public interface IOtpRepository : IGenericRepository<OtpCode>
{
    Task<OtpCode?> GetLatestValidAsync(Guid userId, string target, CancellationToken cancellationToken);
    Task MarkUsedAsync(Guid id, CancellationToken cancellationToken);
    Task DeleteExpiredAsync(CancellationToken cancellationToken);
}
