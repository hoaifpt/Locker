using Locker.Backend.Application.Models;

namespace Locker.Backend.Application.Interfaces;

public interface IPaymentRealtimeNotifier
{
    Task NotifyStatusChangedAsync(
        Guid userId,
        PaymentStatusChangedEvent payload,
        CancellationToken cancellationToken);
}
