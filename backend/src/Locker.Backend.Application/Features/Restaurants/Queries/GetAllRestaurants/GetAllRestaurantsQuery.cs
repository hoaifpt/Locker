using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Models;
using MediatR;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.Restaurants.Queries.GetAllRestaurants;

public record GetAllRestaurantsQuery() : IRequest<List<RestaurantDto>>;

public class GetAllRestaurantsQueryHandler : IRequestHandler<GetAllRestaurantsQuery, List<RestaurantDto>>
{
    private readonly IRestaurantRepository _repository;

    public GetAllRestaurantsQueryHandler(IRestaurantRepository repository)
    {
        _repository = repository;
    }

    public async Task<List<RestaurantDto>> Handle(GetAllRestaurantsQuery request, CancellationToken cancellationToken)
    {
        var items = await _repository.GetAllAsync(cancellationToken);
        return items.Select(x => new RestaurantDto
        {
            Id = x.Id,
            Name = x.Name,
            Description = x.Description,
            Address = x.Address,
            ImageUrl = x.ImageUrl,
            Rating = x.Rating,
            Longitude = x.Location?.Coordinates?.Count >= 2 ? x.Location.Coordinates[0] : 0.0,
            Latitude = x.Location?.Coordinates?.Count >= 2 ? x.Location.Coordinates[1] : 0.0
        }).ToList();
    }
}
