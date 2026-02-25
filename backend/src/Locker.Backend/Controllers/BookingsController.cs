using System.Security.Claims;
using Locker.Backend.Application.Models;
using Locker.Backend.Application.Services;
using Locker.Backend.Domain.Enums;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Locker.Backend.Controllers;

[ApiController]
[Route("api/bookings")]
[Authorize]
public class BookingsController : ControllerBase
{
    private readonly BookingService _bookingService;

    public BookingsController(BookingService bookingService)
    {
        _bookingService = bookingService;
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(string id, CancellationToken cancellationToken)
    {
        var item = await _bookingService.GetByIdAsync(id, cancellationToken);
        if (item == null) return NotFound();
        return Ok(item);
    }

    [HttpGet("my")]
    public async Task<IActionResult> GetMy([FromQuery] BookingStatus? status, CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        if (userId == null) return Unauthorized();
        var items = await _bookingService.GetMyBookingsAsync(userId, status, cancellationToken);
        return Ok(items);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateBookingRequest request, CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        if (userId == null) return Unauthorized();

        var item = await _bookingService.CreateAsync(userId, request, cancellationToken);
        if (item == null) return BadRequest(new { message = "Locker slot not available or package not found" });

        return CreatedAtAction(nameof(GetById), new { id = item.Id }, item);
    }

    [HttpPost("{id}/set-pin")]
    public async Task<IActionResult> SetPin(string id, [FromBody] SetPinRequest request, CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        if (userId == null) return Unauthorized();

        var success = await _bookingService.SetPinAsync(id, userId, request, cancellationToken);
        if (!success) return BadRequest(new { message = "Cannot set PIN for this booking" });
        return NoContent();
    }

    [HttpPost("{id}/verify-pin")]
    public async Task<IActionResult> VerifyPin(string id, [FromBody] VerifyPinRequest request, CancellationToken cancellationToken)
    {
        var valid = await _bookingService.VerifyPinAsync(id, request, cancellationToken);
        if (!valid) return BadRequest(new { message = "Incorrect PIN" });
        return Ok(new { message = "PIN verified" });
    }

    [HttpPost("{id}/complete")]
    public async Task<IActionResult> Complete(string id, CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        if (userId == null) return Unauthorized();

        var success = await _bookingService.CompleteAsync(id, userId, cancellationToken);
        if (!success) return BadRequest(new { message = "Cannot complete this booking" });
        return NoContent();
    }

    [HttpPost("{id}/cancel")]
    public async Task<IActionResult> Cancel(string id, CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        if (userId == null) return Unauthorized();

        var success = await _bookingService.CancelAsync(id, userId, cancellationToken);
        if (!success) return BadRequest(new { message = "Cannot cancel this booking" });
        return NoContent();
    }

    private string? GetUserId()
        => User.FindFirstValue(ClaimTypes.NameIdentifier) ?? User.FindFirstValue("sub");
}
