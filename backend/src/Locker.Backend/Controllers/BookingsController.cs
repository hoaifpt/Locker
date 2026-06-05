using System;
using System.Security.Claims;
using System.Threading;
using System.Threading.Tasks;
using Locker.Backend.Application.Features.Bookings.Commands.CancelBooking;
using Locker.Backend.Application.Features.Bookings.Commands.CompleteBooking;
using Locker.Backend.Application.Features.Bookings.Commands.CreateBooking;
using Locker.Backend.Application.Features.Bookings.Commands.SetPin;
using Locker.Backend.Application.Features.Bookings.Commands.VerifyPin;
using Locker.Backend.Application.Features.Bookings.Queries.GetBookingById;
using Locker.Backend.Application.Features.Bookings.Queries.GetMyBookings;
using Locker.Backend.Application.Models;
using Locker.Backend.Domain.Enums;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Locker.Backend.Controllers;

[ApiController]
[Route("api/bookings")]
[Authorize]
public class BookingsController : ControllerBase
{
    private readonly ISender _sender;

    public BookingsController(ISender sender)
    {
        _sender = sender;
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(Guid id, CancellationToken cancellationToken)
    {
        var item = await _sender.Send(new GetBookingByIdQuery(id), cancellationToken);
        if (item == null) return NotFound();
        return Ok(item);
    }

    [HttpGet("my")]
    public async Task<IActionResult> GetMy([FromQuery] BookingStatus? status, CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        if (userId == Guid.Empty) return Unauthorized();
        var items = await _sender.Send(new GetMyBookingsQuery(userId, status), cancellationToken);
        return Ok(items);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateBookingRequest request, CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        if (userId == Guid.Empty) return Unauthorized();

        var item = await _sender.Send(new CreateBookingCommand(userId, request.LockerId, request.SlotIndex, request.PackageId, request.MobileNumber), cancellationToken);
        if (item == null) return BadRequest(new { message = "Locker slot not available or package not found" });

        return CreatedAtAction(nameof(GetById), new { id = item.Id }, item);
    }

    [HttpPost("{id}/set-pin")]
    public async Task<IActionResult> SetPin(Guid id, [FromBody] SetPinRequest request, CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        if (userId == Guid.Empty) return Unauthorized();

        var success = await _sender.Send(new SetPinCommand(id, userId, request.Pin), cancellationToken);
        if (!success) return BadRequest(new { message = "Cannot set PIN for this booking" });
        return NoContent();
    }

    [HttpPost("{id}/verify-pin")]
    public async Task<IActionResult> VerifyPin(Guid id, [FromBody] VerifyPinRequest request, CancellationToken cancellationToken)
    {
        var valid = await _sender.Send(new VerifyPinCommand(id, request.Pin), cancellationToken);
        if (!valid) return BadRequest(new { message = "Incorrect PIN" });
        return Ok(new { message = "PIN verified" });
    }

    [HttpPost("{id}/complete")]
    public async Task<IActionResult> Complete(Guid id, CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        if (userId == Guid.Empty) return Unauthorized();

        var success = await _sender.Send(new CompleteBookingCommand(id, userId), cancellationToken);
        if (!success) return BadRequest(new { message = "Cannot complete this booking" });
        return NoContent();
    }

    [HttpPost("{id}/cancel")]
    public async Task<IActionResult> Cancel(Guid id, CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        if (userId == Guid.Empty) return Unauthorized();

        var success = await _sender.Send(new CancelBookingCommand(id, userId), cancellationToken);
        if (!success) return BadRequest(new { message = "Cannot cancel this booking" });
        return NoContent();
    }

    private Guid GetUserId()
    {
        var idStr = User.FindFirstValue(ClaimTypes.NameIdentifier) ?? User.FindFirstValue("sub");
        return Guid.TryParse(idStr, out var id) ? id : Guid.Empty;
    }
}
