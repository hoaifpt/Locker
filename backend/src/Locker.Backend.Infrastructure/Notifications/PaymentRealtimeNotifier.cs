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
        try
        {
            await _hubContext.Clients
                .Group($"user:{userId:D}")
                .SendAsync(PaymentStatusChangedEvent, payload, cancellationToken);
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
