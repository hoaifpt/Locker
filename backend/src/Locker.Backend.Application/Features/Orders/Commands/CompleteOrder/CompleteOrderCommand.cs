using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Mapping;
using Locker.Backend.Application.Models;
using Locker.Backend.Domain.Enums;
using MediatR;
using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.Orders.Commands.CompleteOrder;

public record CompleteOrderCommand(Guid OrderId, Guid UserId, string? Notes) : IRequest<OrderDto?>;

public class CompleteOrderCommandHandler : IRequestHandler<CompleteOrderCommand, OrderDto?>
{
    private readonly IOrderRepository _orderRepository;
    private readonly ILockerRepository _lockerRepository;
    private readonly OrderMapper _orderMapper;

    public CompleteOrderCommandHandler(
        IOrderRepository orderRepository,
        ILockerRepository lockerRepository,
        OrderMapper orderMapper)
    {
        _orderRepository = orderRepository;
        _lockerRepository = lockerRepository;
        _orderMapper = orderMapper;
    }

    public async Task<OrderDto?> Handle(CompleteOrderCommand request, CancellationToken cancellationToken)
    {
        var order = await _orderRepository.GetByIdAsync(request.OrderId, cancellationToken);
        if (order == null || order.UserId != request.UserId)
            return null;

        if (order.Status != OrderStatus.Active)
            return null;

        order.Status = OrderStatus.Completed;
        order.CompletedAt = DateTime.UtcNow;
        order.Notes = request.Notes ?? order.Notes;

        var locker = await _lockerRepository.GetByIdAsync(order.LockerId, cancellationToken);
        if (locker == null)
            return null;

        var slot = locker.Slots.FirstOrDefault(s => s.Index == order.SlotIndex);
        if (slot == null)
            return null;

        slot.Status = LockerSlotStatus.Available;
        slot.BookingId = null;

        await _orderRepository.UpdateAsync(order, cancellationToken);
        await _lockerRepository.UpdateAsync(locker, cancellationToken);

        return _orderMapper.Map(order);
    }
}
