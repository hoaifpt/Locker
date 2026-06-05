using System;
using System.Threading;
using System.Threading.Tasks;
using Locker.Backend.Application.Features.LockerEvents.Queries.GetLockerEvents;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Locker.Backend.Controllers;

[ApiController]
[Route("api/lockers/{lockerId}")]
[Authorize(Roles = "Admin")] // Only admins can see hardware events usually
public class LockerEventsController : ControllerBase
{
    private readonly ISender _sender;

    public LockerEventsController(ISender sender)
    {
        _sender = sender;
    }

    [HttpGet("events")]
    public async Task<IActionResult> GetLockerEvents(Guid lockerId, CancellationToken cancellationToken)
    {
        var events = await _sender.Send(new GetLockerEventsQuery(lockerId, null), cancellationToken);
        return Ok(events);
    }

    [HttpGet("slots/{slotIndex}/events")]
    public async Task<IActionResult> GetSlotEvents(Guid lockerId, int slotIndex, CancellationToken cancellationToken)
    {
        var events = await _sender.Send(new GetLockerEventsQuery(lockerId, slotIndex), cancellationToken);
        return Ok(events);
    }
}
