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

                await ProcessExpiredPaymentsAsync(orders, lockers, stoppingToken);
                await ProcessOverdueActiveOrdersAsync(orders, lockers, stoppingToken);
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Failed to process overdue/expired orders.");
            }

            await Task.Delay(TimeSpan.FromMinutes(1), stoppingToken);
        }
    }

    private async Task ProcessExpiredPaymentsAsync(
        IOrderRepository orders, ILockerRepository lockers, CancellationToken stoppingToken)
    {
        var expired = await orders.GetExpiredOrdersAsync(stoppingToken);

        foreach (var order in expired)
        {
            order.Status = OrderStatus.Cancelled;
            order.CancelledAt = DateTime.UtcNow;
            order.CancellationReason = "Payment expired";
            await orders.UpdateAsync(order, stoppingToken);

            await ReleaseSlotAsync(lockers, order, stoppingToken);

            _logger.LogInformation("Cancelled expired order {OrderId} (payment timeout).", order.Id);
        }
    }

    private async Task ProcessOverdueActiveOrdersAsync(
        IOrderRepository orders, ILockerRepository lockers, CancellationToken stoppingToken)
    {
        var overdueOrders = await orders.GetOverdueActiveOrdersAsync(stoppingToken);

        foreach (var order in overdueOrders)
        {
            order.Status = OrderStatus.Completed;
            order.CompletedAt = DateTime.UtcNow;
            order.Notes = (order.Notes ?? "") + " | Auto-completed: overdue checkout";
            await orders.UpdateAsync(order, stoppingToken);

            await ReleaseSlotAsync(lockers, order, stoppingToken);

            _logger.LogInformation("Auto-completed overdue order {OrderId} (checkout time was {CheckOutTime}).",
                order.Id, order.CheckOutTime);
        }
    }

    private async Task ReleaseSlotAsync(
        ILockerRepository lockers, Domain.Entities.Order order, CancellationToken stoppingToken)
    {
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

