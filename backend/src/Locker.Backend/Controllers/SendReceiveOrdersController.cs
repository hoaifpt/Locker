using System;
using System.Security.Claims;
using System.Threading;
using System.Threading.Tasks;
using Locker.Backend.Application.Features.SendReceiveOrders.Commands.CreateSendReceiveOrder;
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

    // Stub for GET {id}
    [HttpGet("{id}")]
    public IActionResult GetById(Guid id) => Ok();

    // Stub for PATCH {id}/confirm
    [HttpPatch("{id}/confirm")]
    public IActionResult Confirm(Guid id) => Ok();

    // Stub for PATCH {id}/complete
    [HttpPatch("{id}/complete")]
    public IActionResult Complete(Guid id) => Ok();

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
