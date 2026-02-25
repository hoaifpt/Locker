using System.Security.Claims;
using Locker.Backend.Application.Models;
using Locker.Backend.Application.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Locker.Backend.Controllers;

[ApiController]
[Route("api/payments")]
[Authorize]
public class PaymentsController : ControllerBase
{
    private readonly PaymentService _paymentService;

    public PaymentsController(PaymentService paymentService)
    {
        _paymentService = paymentService;
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(string id, CancellationToken cancellationToken)
    {
        var item = await _paymentService.GetByIdAsync(id, cancellationToken);
        if (item == null) return NotFound();
        return Ok(item);
    }

    [HttpGet("booking/{bookingId}")]
    public async Task<IActionResult> GetByBookingId(string bookingId, CancellationToken cancellationToken)
    {
        var item = await _paymentService.GetByBookingIdAsync(bookingId, cancellationToken);
        if (item == null) return NotFound();
        return Ok(item);
    }

    [HttpGet("my")]
    public async Task<IActionResult> GetMy(CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        if (userId == null) return Unauthorized();
        var items = await _paymentService.GetMyPaymentsAsync(userId, cancellationToken);
        return Ok(items);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreatePaymentRequest request, CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        if (userId == null) return Unauthorized();

        var item = await _paymentService.CreateAsync(userId, request, cancellationToken);
        if (item == null) return BadRequest(new { message = "Booking not found or not owned by you" });

        return CreatedAtAction(nameof(GetById), new { id = item.Id }, item);
    }

    [HttpPost("{id}/complete")]
    public async Task<IActionResult> Complete(string id, [FromBody] CompletePaymentRequest request, CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        if (userId == null) return Unauthorized();

        var success = await _paymentService.CompleteAsync(id, userId, request, cancellationToken);
        if (!success) return BadRequest(new { message = "Cannot complete this payment" });
        return NoContent();
    }

    private string? GetUserId()
        => User.FindFirstValue(ClaimTypes.NameIdentifier) ?? User.FindFirstValue("sub");
}
