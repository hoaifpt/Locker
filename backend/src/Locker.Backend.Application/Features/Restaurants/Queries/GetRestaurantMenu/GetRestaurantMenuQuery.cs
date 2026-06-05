using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Models;
using MediatR;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.Restaurants.Queries.GetRestaurantMenu;

public record GetRestaurantMenuQuery(Guid RestaurantId) : IRequest<List<MenuItemDto>>;

public class GetRestaurantMenuQueryHandler : IRequestHandler<GetRestaurantMenuQuery, List<MenuItemDto>>
{
    private readonly IMenuItemRepository _repository;

    public GetRestaurantMenuQueryHandler(IMenuItemRepository repository)
    {
        _repository = repository;
    }

    public async Task<List<MenuItemDto>> Handle(GetRestaurantMenuQuery request, CancellationToken cancellationToken)
    {
        var items = await _repository.GetByRestaurantIdAsync(request.RestaurantId, cancellationToken);
        return items.Select(x => new MenuItemDto
        {
            Id = x.Id,
            RestaurantId = x.RestaurantId,
            Name = x.Name,
            Description = x.Description,
            Price = x.Price,
            ImageUrl = x.ImageUrl,
            Category = x.Category,
            IsAvailable = x.IsAvailable
        }).ToList();
    }
}
