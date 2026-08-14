using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Models;
using Microsoft.AspNetCore.SignalR;
using Microsoft.Extensions.Logging;

namespace Locker.Backend.Infrastructure.Notifications;

public class PaymentRealtimeNotifier : IPaymentRealtimeNotifier
{
    private const string PaymentStatusChangedEvent = "PaymentStatusChanged";

    private readonly IHubContext<NotificationHub> _hubContext;
    private readonly ILogger<PaymentRealtimeNotifier> _logger;

    public PaymentRealtimeNotifier(
        IHubContext<NotificationHub> hubContext,
        ILogger<PaymentRealtimeNotifier> logger)
    {
        _hubContext = hubContext;
        _logger = logger;
    }

    public async Task NotifyStatusChangedAsync(
        Guid userId,
        PaymentStatusChangedEvent payload,
        CancellationToken cancellationToken)
    {
        var groupName = $"user:{userId:D}";
        try
        {
            await _hubContext.Clients
                .Group(groupName)
                .SendAsync(PaymentStatusChangedEvent, payload, cancellationToken);
            _logger.LogInformation(
                "Published PaymentStatusChanged for payment {PaymentId} to group {Group} (user {UserId})",
                payload.PaymentId,
                groupName,
                userId);
        }
        catch (Exception ex)
        {
            _logger.LogError(
                ex,
                "Failed to publish PaymentStatusChanged for payment {PaymentId} to user {UserId}",
                payload.PaymentId,
                userId);
        }
    }
}
