using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Models;
using Locker.Backend.Domain.Entities;
using Microsoft.AspNetCore.SignalR;
using Microsoft.Extensions.Logging;

namespace Locker.Backend.Infrastructure.Notifications;

public class RealtimeNotificationService : IRealtimeNotificationService
{
    private const string AdminRole = "Admin";
    private const string NotificationReceivedEvent = "NotificationReceived";

    private readonly INotificationRepository _notificationRepository;
    private readonly IIdentityService _identityService;
    private readonly IHubContext<NotificationHub> _hubContext;
    private readonly ILogger<RealtimeNotificationService> _logger;

    public RealtimeNotificationService(
        INotificationRepository notificationRepository,
        IIdentityService identityService,
        IHubContext<NotificationHub> hubContext,
        ILogger<RealtimeNotificationService> logger)
    {
        _notificationRepository = notificationRepository;
        _identityService = identityService;
        _hubContext = hubContext;
        _logger = logger;
    }

    public async Task<NotificationDto> NotifyUserAsync(
        Guid userId,
        string title,
        string message,
        CancellationToken cancellationToken)
    {
        var notification = new Notification
        {
            Id = Guid.CreateVersion7(),
            UserId = userId,
            Title = title,
            Message = message,
            IsRead = false,
            CreatedAt = DateTime.UtcNow
        };

        await _notificationRepository.CreateAsync(notification, cancellationToken);

        var dto = MapToDto(notification);

        await PublishAsync(userId, dto, cancellationToken);

        return dto;
    }

    public async Task<IReadOnlyList<NotificationDto>> NotifyAdminsAsync(
        string title,
        string message,
        CancellationToken cancellationToken)
    {
        var users = await _identityService.GetAllUsersAsync();
        var adminDtos = new List<NotificationDto>();

        foreach (var user in users)
        {
            if (!user.IsActive)
            {
                continue;
            }

            var roles = await _identityService.GetRolesAsync(user);
            var isAdmin = roles.Any(r => string.Equals(r, AdminRole, StringComparison.OrdinalIgnoreCase));
            if (!isAdmin)
            {
                continue;
            }

            var dto = await NotifyUserAsync(user.Id, title, message, cancellationToken);
            adminDtos.Add(dto);
        }

        return adminDtos;
    }

    private async Task PublishAsync(Guid userId, NotificationDto dto, CancellationToken cancellationToken)
    {
        try
        {
            await _hubContext.Clients
                .Group($"user:{userId:D}")
                .SendAsync(NotificationReceivedEvent, dto, cancellationToken);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to publish SignalR notification {NotificationId} to user {UserId}", dto.Id, userId);
        }
    }

    private static NotificationDto MapToDto(Notification entity) => new()
    {
        Id = entity.Id,
        Title = entity.Title,
        Message = entity.Message,
        IsRead = entity.IsRead,
        CreatedAt = entity.CreatedAt
    };
}
