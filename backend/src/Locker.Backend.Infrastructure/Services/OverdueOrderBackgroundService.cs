using Locker.Backend.Application.Interfaces;
using Locker.Backend.Domain.Enums;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

namespace Locker.Backend.Infrastructure.Services;

public class OverdueOrderBackgroundService : BackgroundService
{
    private readonly IServiceScopeFactory _scopeFactory;
    private readonly ILogger<OverdueOrderBackgroundService> _logger;

    public OverdueOrderBackgroundService(IServiceScopeFactory scopeFactory, ILogger<OverdueOrderBackgroundService> logger)
    {
        _scopeFactory = scopeFactory;
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                using var scope = _scopeFactory.CreateScope();
                var orders = scope.ServiceProvider.GetRequiredService<IOrderRepository>();
                var lockers = scope.ServiceProvider.GetRequiredService<ILockerRepository>();
                var expired = await orders.GetExpiredOrdersAsync(stoppingToken);

                foreach (var order in expired)
                {
                    order.Status = OrderStatus.Cancelled;
                    order.CancelledAt = DateTime.UtcNow;
                    order.CancellationReason = "Payment expired";
                    await orders.UpdateAsync(order, stoppingToken);

                    var locker = await lockers.GetByIdAsync(order.LockerId, stoppingToken);
                    var slot = locker?.Slots.FirstOrDefault(s => s.Index == order.SlotIndex && s.BookingId == order.Id);
                    if (slot != null && locker != null)
                    {
                        slot.Status = LockerSlotStatus.Available;
                        slot.BookingId = null;
                        await lockers.UpdateAsync(locker, stoppingToken);
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Failed to process overdue orders.");
            }

            await Task.Delay(TimeSpan.FromMinutes(1), stoppingToken);
        }
    }
}
