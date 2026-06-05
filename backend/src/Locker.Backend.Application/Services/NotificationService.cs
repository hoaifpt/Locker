using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Models;
using Locker.Backend.Domain.Entities;

namespace Locker.Backend.Application.Services;

public class NotificationService
{
    private readonly INotificationRepository _notificationRepository;
    private readonly IDeviceTokenRepository _deviceTokenRepository;

    public NotificationService(
        INotificationRepository notificationRepository,
        IDeviceTokenRepository deviceTokenRepository)
    {
        _notificationRepository = notificationRepository;
        _deviceTokenRepository = deviceTokenRepository;
    }

    public async Task<List<NotificationDto>> GetMyAsync(Guid userId, CancellationToken cancellationToken)
    {
        var notifications = await _notificationRepository.GetByUserIdAsync(userId, cancellationToken);
        return notifications
            .OrderByDescending(n => n.CreatedAt)
            .Select(n => new NotificationDto
            {
                Id = n.Id,
                Title = n.Title,
                Message = n.Message,
                IsRead = n.IsRead,
                CreatedAt = n.CreatedAt
            })
            .ToList();
    }

    public Task<bool> MarkAsReadAsync(Guid notificationId, Guid userId, CancellationToken cancellationToken)
    {
        return _notificationRepository.MarkAsReadAsync(notificationId, userId, cancellationToken);
    }

    public Task<int> MarkAllAsReadAsync(Guid userId, CancellationToken cancellationToken)
    {
        return _notificationRepository.MarkAllAsReadAsync(userId, cancellationToken);
    }

    public async Task RegisterDeviceAsync(Guid userId, RegisterDeviceRequest request, CancellationToken cancellationToken)
    {
        var token = new DeviceToken
        {
            UserId = userId,
            Token = request.DeviceToken,
            Platform = request.Platform,
            UpdatedAt = DateTime.UtcNow,
            CreatedAt = DateTime.UtcNow
        };

        await _deviceTokenRepository.UpsertAsync(token, cancellationToken);
    }
}
