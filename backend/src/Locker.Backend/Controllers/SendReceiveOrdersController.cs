using System;
using System.Security.Claims;
using System.Threading;
using System.Threading.Tasks;
using Locker.Backend.Application.Features.SendReceiveOrders.Commands.CompleteOrder;
using Locker.Backend.Application.Features.SendReceiveOrders.Commands.ConfirmOrder;
using Locker.Backend.Application.Features.SendReceiveOrders.Commands.CreateSendReceiveOrder;
using Locker.Backend.Application.Features.SendReceiveOrders.Queries.GetById;
using Locker.Backend.Application.Features.SendReceiveOrders.Queries.GetMySendReceiveOrders;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Locker.Backend.Controllers;

[ApiController]
[Route("api/send-receive/orders")]
[Authorize]
public class SendReceiveOrdersController : ControllerBase
{
    private readonly ISender _sender;

    public SendReceiveOrdersController(ISender sender)
    {
        _sender = sender;
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateSendReceiveOrderRequest dto, CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        if (userId == Guid.Empty) return Unauthorized();

        var result = await _sender.Send(new CreateSendReceiveOrderCommand(
            userId, dto.ReceiverPhone, dto.LockerId, dto.SlotIndex, dto.PinCode, dto.Notes), cancellationToken);

        if (result == null) return BadRequest();
        return Ok(result);
    }

    [HttpGet("my")]
    public async Task<IActionResult> GetMy(CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        if (userId == Guid.Empty) return Unauthorized();

        var result = await _sender.Send(new GetMySendReceiveOrdersQuery(userId), cancellationToken);
        return Ok(result);
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(Guid id, CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        if (userId == Guid.Empty) return Unauthorized();

        var result = await _sender.Send(new GetByIdQuery(id, userId), cancellationToken);
        if (result == null) return NotFound();

        return Ok(result);
    }

    [HttpPatch("{id}/confirm")]
    public async Task<IActionResult> Confirm(Guid id, CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        if (userId == Guid.Empty) return Unauthorized();

        var updated = await _sender.Send(new ConfirmOrderCommand(id, userId), cancellationToken);
        if (!updated) return NotFound();

        return Ok();
    }

    [HttpPatch("{id}/complete")]
    public async Task<IActionResult> Complete(Guid id, CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        if (userId == Guid.Empty) return Unauthorized();

        var updated = await _sender.Send(new CompleteOrderCommand(id, userId), cancellationToken);
        if (!updated) return NotFound();

        return Ok();
    }

    private Guid GetUserId()
    {
        var idStr = User.FindFirstValue(ClaimTypes.NameIdentifier) ?? User.FindFirstValue("sub");
        return Guid.TryParse(idStr, out var id) ? id : Guid.Empty;
    }
}

public class CreateSendReceiveOrderRequest
{
    public string ReceiverPhone { get; set; } = string.Empty;
    public Guid LockerId { get; set; }
    public int SlotIndex { get; set; }
    public string PinCode { get; set; } = string.Empty;
    public string? Notes { get; set; }
}
