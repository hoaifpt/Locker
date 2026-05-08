using Locker.Backend.Domain.Entities;

namespace Locker.Backend.Application.Interfaces;

public interface INotificationRepository : IGenericRepository<Notification>
{
    Task<List<Notification>> GetByUserIdAsync(string userId, CancellationToken cancellationToken);
    Task<long> CountUnreadAsync(string userId, CancellationToken cancellationToken);
    Task MarkAllAsReadAsync(string userId, CancellationToken cancellationToken);
}