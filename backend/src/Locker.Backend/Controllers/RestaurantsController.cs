using System;
using System.Threading;
using System.Threading.Tasks;
using Locker.Backend.Application.Features.Restaurants.Queries.GetAllRestaurants;
using Locker.Backend.Application.Features.Restaurants.Queries.GetRestaurantById;
using Locker.Backend.Application.Features.Restaurants.Queries.GetRestaurantMenu;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Locker.Backend.Controllers;

[ApiController]
[Route("api/restaurants")]
[Authorize]
public class RestaurantsController : ControllerBase
{
    private readonly ISender _sender;

    public RestaurantsController(ISender sender)
    {
        _sender = sender;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll(CancellationToken cancellationToken)
    {
        var restaurants = await _sender.Send(new GetAllRestaurantsQuery(), cancellationToken);
        return Ok(restaurants);
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(Guid id, CancellationToken cancellationToken)
    {
        var restaurant = await _sender.Send(new GetRestaurantByIdQuery(id), cancellationToken);
        if (restaurant == null) return NotFound();
        return Ok(restaurant);
    }

    [HttpGet("{id}/menu")]
    public async Task<IActionResult> GetMenu(Guid id, CancellationToken cancellationToken)
    {
        var menu = await _sender.Send(new GetRestaurantMenuQuery(id), cancellationToken);
        return Ok(menu);
    }
}
