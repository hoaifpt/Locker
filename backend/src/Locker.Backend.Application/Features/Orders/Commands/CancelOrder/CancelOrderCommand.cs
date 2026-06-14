using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Mapping;
using Locker.Backend.Application.Models;
using Locker.Backend.Domain.Enums;
using MediatR;
using Microsoft.Extensions.Logging;
using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.Orders.Commands.CancelOrder;

public record CancelOrderCommand(Guid OrderId, Guid UserId, string CancellationReason) : IRequest<OrderDto?>;

public class CancelOrderCommandHandler : IRequestHandler<CancelOrderCommand, OrderDto?>
{
    private readonly IOrderRepository _orderRepository;
    private readonly ILockerRepository _lockerRepository;
    private readonly OrderMapper _orderMapper;
    private readonly ILogger<CancelOrderCommandHandler> _logger;

    public CancelOrderCommandHandler(
        IOrderRepository orderRepository,
        ILockerRepository lockerRepository,
        OrderMapper orderMapper,
        ILogger<CancelOrderCommandHandler> logger)
    {
        _orderRepository = orderRepository;
        _lockerRepository = lockerRepository;
        _orderMapper = orderMapper;
        _logger = logger;
    }

    public async Task<OrderDto?> Handle(CancelOrderCommand request, CancellationToken cancellationToken)
    {
        var order = await _orderRepository.GetByIdAsync(request.OrderId, cancellationToken);
        if (order == null || order.UserId != request.UserId)
            return null;

        if (order.Status == OrderStatus.Completed || order.Status == OrderStatus.Cancelled)
            return null;

        var reason = request.CancellationReason;

        if (order.Status == OrderStatus.Active)
        {
            var startedAt = order.StartedAt ?? order.CheckInTime;
            var actualHours = (int)Math.Ceiling((DateTime.UtcNow - startedAt).TotalHours);
            if (actualHours < 1) actualHours = 1;

            var usageCost = actualHours * order.BaseRate;
            var taxes = usageCost * 0.1m;
            var totalUsageCost = usageCost + taxes;
            var refundAmount = order.TotalAmount - totalUsageCost;
            if (refundAmount < 0) refundAmount = 0;

            reason = $"{request.CancellationReason} | Sử dụng {actualHours}h, phí: {totalUsageCost:N0}đ, hoàn trả: {refundAmount:N0}đ";
        }

        order.Status = OrderStatus.Cancelled;
        order.CancelledAt = DateTime.UtcNow;
        order.CancellationReason = reason;

        var locker = await _lockerRepository.GetByIdAsync(order.LockerId, cancellationToken);
        if (locker != null)
        {
            var slot = locker.Slots.FirstOrDefault(s => s.Index == order.SlotIndex);
            if (slot != null)
            {
                slot.Status = LockerSlotStatus.Available;
                slot.BookingId = null;
                await _lockerRepository.UpdateAsync(locker, cancellationToken);
            }
        }

        await _orderRepository.UpdateAsync(order, cancellationToken);

        _logger.LogInformation(
            "[AUDIT] Order {OrderId} cancelled by User {UserId}. PreviousStatus={PreviousStatus}, Reason={Reason}",
            order.Id, request.UserId, order.Status, reason);

        return _orderMapper.Map(order);
    }
}

