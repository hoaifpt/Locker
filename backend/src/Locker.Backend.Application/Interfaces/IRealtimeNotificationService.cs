using Locker.Backend.Application.Models;

namespace Locker.Backend.Application.Interfaces;

public interface IRealtimeNotificationService
{
    Task<NotificationDto> NotifyUserAsync(
        Guid userId,
        string title,
        string message,
        CancellationToken cancellationToken);

    Task<IReadOnlyList<NotificationDto>> NotifyAdminsAsync(
        string title,
        string message,
        CancellationToken cancellationToken);
}
