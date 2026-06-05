using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Mapping;
using Locker.Backend.Application.Models;
using Locker.Backend.Domain.Enums;
using MediatR;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.Orders.Commands.ExtendOrder;

public record ExtendOrderCommand(Guid OrderId, Guid UserId, int AdditionalHours) : IRequest<OrderDto?>;

public class ExtendOrderCommandHandler : IRequestHandler<ExtendOrderCommand, OrderDto?>
{
    private readonly IOrderRepository _orderRepository;
    private readonly OrderMapper _orderMapper;

    public ExtendOrderCommandHandler(IOrderRepository orderRepository, OrderMapper orderMapper)
    {
        _orderRepository = orderRepository;
        _orderMapper = orderMapper;
    }

    public async Task<OrderDto?> Handle(ExtendOrderCommand request, CancellationToken cancellationToken)
    {
        var order = await _orderRepository.GetByIdAsync(request.OrderId, cancellationToken);
        if (order == null || order.UserId != request.UserId)
            return null;

        if (order.Status != OrderStatus.Active && order.Status != OrderStatus.Reserved)
            return null;

        var additionalFee = order.BaseRate * request.AdditionalHours;

        order.CheckOutTime = order.CheckOutTime.AddHours(request.AdditionalHours);
        order.DurationHours += request.AdditionalHours;
        order.TotalAmount += additionalFee;

        await _orderRepository.UpdateAsync(order, cancellationToken);

        return _orderMapper.Map(order);
    }
}
