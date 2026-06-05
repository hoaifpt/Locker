using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Models;
using MediatR;
using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.FoodOrders.Queries.GetFoodOrderById;

public record GetFoodOrderByIdQuery(Guid Id, Guid UserId) : IRequest<FoodOrderDto?>;

public class GetFoodOrderByIdQueryHandler : IRequestHandler<GetFoodOrderByIdQuery, FoodOrderDto?>
{
    private readonly IFoodOrderRepository _repository;

    public GetFoodOrderByIdQueryHandler(IFoodOrderRepository repository)
    {
        _repository = repository;
    }

    public async Task<FoodOrderDto?> Handle(GetFoodOrderByIdQuery request, CancellationToken cancellationToken)
    {
        var order = await _repository.GetByIdAsync(request.Id, cancellationToken);
        if (order == null || order.UserId != request.UserId)
            return null;

        return new FoodOrderDto
        {
            Id = order.Id,
            RestaurantId = order.RestaurantId,
            LockerId = order.LockerId,
            SlotIndex = order.SlotIndex,
            TotalAmount = order.TotalAmount,
            Status = order.Status,
            DeliveryNotes = order.DeliveryNotes,
            CreatedAt = order.CreatedAt,
            Items = order.Items.Select(i => new FoodOrderItemDto
            {
                MenuItemId = i.MenuItemId,
                Name = i.Name,
                Quantity = i.Quantity,
                UnitPrice = i.UnitPrice,
                Notes = i.Notes
            }).ToList()
        };
    }
}
