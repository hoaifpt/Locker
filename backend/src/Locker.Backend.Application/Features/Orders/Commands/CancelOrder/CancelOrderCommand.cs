using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Mapping;
using Locker.Backend.Application.Models;
using Locker.Backend.Domain.Enums;
using MediatR;
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

    public CancelOrderCommandHandler(
        IOrderRepository orderRepository,
        ILockerRepository lockerRepository,
        OrderMapper orderMapper)
    {
        _orderRepository = orderRepository;
        _lockerRepository = lockerRepository;
        _orderMapper = orderMapper;
    }

    public async Task<OrderDto?> Handle(CancelOrderCommand request, CancellationToken cancellationToken)
    {
        var order = await _orderRepository.GetByIdAsync(request.OrderId, cancellationToken);
        if (order == null || order.UserId != request.UserId)
            return null;

        if (order.Status == OrderStatus.Completed || order.Status == OrderStatus.Cancelled)
            return null;

        if (order.Status == OrderStatus.Active)
            return null;

        order.Status = OrderStatus.Cancelled;
        order.CancelledAt = DateTime.UtcNow;
        order.CancellationReason = request.CancellationReason;

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

        return _orderMapper.Map(order);
    }
}
