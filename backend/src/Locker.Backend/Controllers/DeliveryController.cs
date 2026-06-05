using System;
using System.Security.Claims;
using System.Threading;
using System.Threading.Tasks;
using Locker.Backend.Application.Features.DeliveryRequests.Commands.CreateDeliveryRequest;
using Locker.Backend.Application.Features.DeliveryRequests.Queries.GetMyDeliveryRequests;
using Locker.Backend.Application.Features.DeliveryRequests.Queries.TrackDeliveryRequest;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Locker.Backend.Controllers;

[ApiController]
[Route("api/delivery")]
public class DeliveryController : ControllerBase
{
    private readonly ISender _sender;

    public DeliveryController(ISender sender)
    {
        _sender = sender;
    }

    [HttpGet("package-sizes")]
    public IActionResult GetPackageSizes()
    {
        return Ok(new[] { "Small", "Medium", "Large" });
    }

    [HttpPost("requests")]
    [Authorize]
    public async Task<IActionResult> CreateRequest([FromBody] CreateDeliveryRequest dto, CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        if (userId == Guid.Empty) return Unauthorized();

        var result = await _sender.Send(new CreateDeliveryRequestCommand(
            userId, dto.SenderName, dto.ReceiverPhone, dto.LockerId, dto.SlotIndex, dto.PackageSize), cancellationToken);

        if (result == null) return BadRequest();
        return Ok(result);
    }

    [HttpGet("requests/my")]
    [Authorize]
    public async Task<IActionResult> GetMyRequests(CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        if (userId == Guid.Empty) return Unauthorized();

        var result = await _sender.Send(new GetMyDeliveryRequestsQuery(userId), cancellationToken);
        return Ok(result);
    }

    [HttpGet("requests/track/{trackingCode}")]
    public async Task<IActionResult> TrackRequest(string trackingCode, CancellationToken cancellationToken)
    {
        var result = await _sender.Send(new TrackDeliveryRequestQuery(trackingCode), cancellationToken);
        if (result == null) return NotFound();
        return Ok(result);
    }

    private Guid GetUserId()
    {
        var idStr = User.FindFirstValue(ClaimTypes.NameIdentifier) ?? User.FindFirstValue("sub");
        return Guid.TryParse(idStr, out var id) ? id : Guid.Empty;
    }
}

public class CreateDeliveryRequest
{
    public string SenderName { get; set; } = string.Empty;
    public string ReceiverPhone { get; set; } = string.Empty;
    public Guid LockerId { get; set; }
    public int SlotIndex { get; set; }
    public string PackageSize { get; set; } = string.Empty;
}
