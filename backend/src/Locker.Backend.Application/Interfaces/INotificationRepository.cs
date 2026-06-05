using Locker.Backend.Domain.Entities;

namespace Locker.Backend.Application.Interfaces;

public interface INotificationRepository : IGenericRepository<Notification>
{
    Task<List<Notification>> GetByUserIdAsync(Guid userId, CancellationToken cancellationToken);
    Task<bool> MarkAsReadAsync(Guid notificationId, Guid userId, CancellationToken cancellationToken);
    Task<int> MarkAllAsReadAsync(Guid userId, CancellationToken cancellationToken);
}
