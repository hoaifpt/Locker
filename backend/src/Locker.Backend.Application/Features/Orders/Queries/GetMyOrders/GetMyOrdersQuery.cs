using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Mapping;
using Locker.Backend.Application.Models;
using Locker.Backend.Domain.Entities;
using Locker.Backend.Domain.Enums;
using MediatR;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.Orders.Queries.GetMyOrders;

public record GetMyOrdersQuery(Guid UserId, OrderStatus? Status) : IRequest<List<OrderSummaryDto>>;

public class GetMyOrdersQueryHandler : IRequestHandler<GetMyOrdersQuery, List<OrderSummaryDto>>
{
    private readonly IOrderRepository _orderRepository;
    private readonly OrderMapper _orderMapper;

    public GetMyOrdersQueryHandler(IOrderRepository orderRepository, OrderMapper orderMapper)
    {
        _orderRepository = orderRepository;
        _orderMapper = orderMapper;
    }

    public async Task<List<OrderSummaryDto>> Handle(GetMyOrdersQuery request, CancellationToken cancellationToken)
    {
        List<Order> orders;

        if (request.Status.HasValue)
        {
            orders = await _orderRepository.GetByUserIdAndStatusAsync(request.UserId, request.Status.Value, cancellationToken);
        }
        else
        {
            orders = await _orderRepository.GetByUserIdAsync(request.UserId, cancellationToken);
        }

        return orders.Select(_orderMapper.MapToSummary).ToList();
    }
}
