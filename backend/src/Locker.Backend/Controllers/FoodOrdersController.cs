using System;
using System.Collections.Generic;
using System.Security.Claims;
using System.Threading;
using System.Threading.Tasks;
using Locker.Backend.Application.Features.FoodOrders.Commands.CreateFoodOrder;
using Locker.Backend.Application.Features.FoodOrders.Queries.GetFoodOrderById;
using Locker.Backend.Application.Features.FoodOrders.Queries.GetMyFoodOrders;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Locker.Backend.Controllers;

[ApiController]
[Route("api/food-orders")]
[Authorize]
public class FoodOrdersController : ControllerBase
{
    private readonly ISender _sender;

    public FoodOrdersController(ISender sender)
    {
        _sender = sender;
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateFoodOrderRequest request, CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        if (userId == Guid.Empty) return Unauthorized();

        var command = new CreateFoodOrderCommand(
            userId,
            request.RestaurantId,
            request.LockerId,
            request.SlotIndex,
            request.Items,
            request.DeliveryNotes
        );

        var order = await _sender.Send(command, cancellationToken);
        if (order == null) return BadRequest(new { message = "Cannot create food order" });

        return Ok(order);
    }

    [HttpGet("my")]
    public async Task<IActionResult> GetMy(CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        if (userId == Guid.Empty) return Unauthorized();

        var orders = await _sender.Send(new GetMyFoodOrdersQuery(userId), cancellationToken);
        return Ok(orders);
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(Guid id, CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        if (userId == Guid.Empty) return Unauthorized();

        var order = await _sender.Send(new GetFoodOrderByIdQuery(id, userId), cancellationToken);
        if (order == null) return NotFound();
        
        return Ok(order);
    }

    private Guid GetUserId()
    {
        var idStr = User.FindFirstValue(ClaimTypes.NameIdentifier) ?? User.FindFirstValue("sub");
        return Guid.TryParse(idStr, out var id) ? id : Guid.Empty;
    }
}

public class CreateFoodOrderRequest
{
    public Guid RestaurantId { get; set; }
    public Guid LockerId { get; set; }
    public int SlotIndex { get; set; }
    public List<CreateFoodOrderItemRequest> Items { get; set; } = new();
    public string? DeliveryNotes { get; set; }
}
