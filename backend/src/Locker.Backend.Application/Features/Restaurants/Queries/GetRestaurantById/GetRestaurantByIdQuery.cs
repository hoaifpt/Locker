using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Models;
using MediatR;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.Restaurants.Queries.GetRestaurantById;

public record GetRestaurantByIdQuery(Guid Id) : IRequest<RestaurantDto?>;

public class GetRestaurantByIdQueryHandler : IRequestHandler<GetRestaurantByIdQuery, RestaurantDto?>
{
    private readonly IRestaurantRepository _repository;

    public GetRestaurantByIdQueryHandler(IRestaurantRepository repository)
    {
        _repository = repository;
    }

    public async Task<RestaurantDto?> Handle(GetRestaurantByIdQuery request, CancellationToken cancellationToken)
    {
        var item = await _repository.GetByIdAsync(request.Id, cancellationToken);
        if (item == null) return null;

        return new RestaurantDto
        {
            Id = item.Id,
            Name = item.Name,
            Description = item.Description,
            Address = item.Address,
            ImageUrl = item.ImageUrl,
            Rating = item.Rating,
            Longitude = item.Location?.Coordinates?.Count >= 2 ? item.Location.Coordinates[0] : 0.0,
            Latitude = item.Location?.Coordinates?.Count >= 2 ? item.Location.Coordinates[1] : 0.0
        };
    }
}
