using Locker.Backend.Domain.Entities;

namespace Locker.Backend.Application.Interfaces;

public interface IOtpRepository
{
    Task CreateAsync(OtpCode otpCode, CancellationToken cancellationToken);
    Task<OtpCode?> GetLatestValidAsync(string userId, string target, CancellationToken cancellationToken);
    Task MarkUsedAsync(string id, CancellationToken cancellationToken);
    Task DeleteExpiredAsync(CancellationToken cancellationToken);
}
