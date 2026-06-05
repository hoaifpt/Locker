using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Models;
using MediatR;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.FoodOrders.Queries.GetMyFoodOrders;

public record GetMyFoodOrdersQuery(Guid UserId) : IRequest<List<FoodOrderDto>>;

public class GetMyFoodOrdersQueryHandler : IRequestHandler<GetMyFoodOrdersQuery, List<FoodOrderDto>>
{
    private readonly IFoodOrderRepository _repository;

    public GetMyFoodOrdersQueryHandler(IFoodOrderRepository repository)
    {
        _repository = repository;
    }

    public async Task<List<FoodOrderDto>> Handle(GetMyFoodOrdersQuery request, CancellationToken cancellationToken)
    {
        var orders = await _repository.GetByUserIdAsync(request.UserId, cancellationToken);
        return orders.Select(o => new FoodOrderDto
        {
            Id = o.Id,
            RestaurantId = o.RestaurantId,
            LockerId = o.LockerId,
            SlotIndex = o.SlotIndex,
            TotalAmount = o.TotalAmount,
            Status = o.Status,
            DeliveryNotes = o.DeliveryNotes,
            CreatedAt = o.CreatedAt,
            Items = o.Items.Select(i => new FoodOrderItemDto
            {
                MenuItemId = i.MenuItemId,
                Name = i.Name,
                Quantity = i.Quantity,
                UnitPrice = i.UnitPrice,
                Notes = i.Notes
            }).ToList()
        }).ToList();
    }
}
