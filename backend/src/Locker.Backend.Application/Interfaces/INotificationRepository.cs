using Locker.Backend.Domain.Entities;

namespace Locker.Backend.Application.Interfaces;

public interface INotificationRepository : IGenericRepository<Notification>
{
    Task<List<Notification>> GetByUserIdAsync(string userId, CancellationToken cancellationToken);
    Task<bool> MarkAsReadAsync(string notificationId, string userId, CancellationToken cancellationToken);
    Task<int> MarkAllAsReadAsync(string userId, CancellationToken cancellationToken);
}
