using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Mapping;
using Locker.Backend.Application.Models;
using Locker.Backend.Domain.Enums;
using MediatR;
using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.Orders.Commands.ActivateOrder;

public record ActivateOrderCommand(Guid OrderId, Guid UserId) : IRequest<OrderDto?>;

public class ActivateOrderCommandHandler : IRequestHandler<ActivateOrderCommand, OrderDto?>
{
    private readonly IOrderRepository _orderRepository;
    private readonly ILockerRepository _lockerRepository;
    private readonly OrderMapper _orderMapper;

    public ActivateOrderCommandHandler(
        IOrderRepository orderRepository,
        ILockerRepository lockerRepository,
        OrderMapper orderMapper)
    {
        _orderRepository = orderRepository;
        _lockerRepository = lockerRepository;
        _orderMapper = orderMapper;
    }

    public async Task<OrderDto?> Handle(ActivateOrderCommand request, CancellationToken cancellationToken)
    {
        var order = await _orderRepository.GetByIdAsync(request.OrderId, cancellationToken);
        if (order == null || order.UserId != request.UserId)
            return null;

        if (order.Status != OrderStatus.Reserved && order.Status != OrderStatus.Paid)
            return null;

        var now = DateTime.UtcNow;
        if (now < order.CheckInTime.AddMinutes(-30))
            return null;

        if (now > order.CheckOutTime)
            return null;

        order.Status = OrderStatus.Active;
        order.StartedAt = now;

        var locker = await _lockerRepository.GetByIdAsync(order.LockerId, cancellationToken);
        if (locker == null)
            return null;

        var slot = locker.Slots.FirstOrDefault(s => s.Index == order.SlotIndex);
        if (slot == null)
            return null;

        slot.Status = LockerSlotStatus.Active;

        await _orderRepository.UpdateAsync(order, cancellationToken);
        await _lockerRepository.UpdateAsync(locker, cancellationToken);

        return _orderMapper.Map(order);
    }
}
