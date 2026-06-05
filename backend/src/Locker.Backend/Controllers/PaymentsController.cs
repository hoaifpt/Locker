using System;
using System.Security.Claims;
using System.Threading;
using System.Threading.Tasks;
using Locker.Backend.Application.Features.Payments.Commands.CompletePayment;
using Locker.Backend.Application.Features.Payments.Commands.CreatePayment;
using Locker.Backend.Application.Features.Payments.Commands.ProcessPaymentWebhook;
using Locker.Backend.Application.Features.Payments.Queries.GetMyPayments;
using Locker.Backend.Application.Features.Payments.Queries.GetPaymentByBookingId;
using Locker.Backend.Application.Features.Payments.Queries.GetPaymentById;
using Locker.Backend.Application.Models;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Locker.Backend.Controllers;

[ApiController]
[Route("api/payments")]
[Authorize]
public class PaymentsController : ControllerBase
{
    private readonly ISender _sender;

    public PaymentsController(ISender sender)
    {
        _sender = sender;
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(Guid id, CancellationToken cancellationToken)
    {
        var item = await _sender.Send(new GetPaymentByIdQuery(id), cancellationToken);
        if (item == null) return NotFound();
        return Ok(item);
    }

    [HttpGet("booking/{bookingId}")]
    public async Task<IActionResult> GetByBookingId(Guid bookingId, CancellationToken cancellationToken)
    {
        var item = await _sender.Send(new GetPaymentByBookingIdQuery(bookingId), cancellationToken);
        if (item == null) return NotFound();
        return Ok(item);
    }

    [HttpGet("my")]
    public async Task<IActionResult> GetMy(CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        if (userId == Guid.Empty) return Unauthorized();
        var items = await _sender.Send(new GetMyPaymentsQuery(userId), cancellationToken);
        return Ok(items);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreatePaymentRequest request, CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        if (userId == Guid.Empty) return Unauthorized();

        var item = await _sender.Send(new CreatePaymentCommand(userId, request.BookingId, request.Method), cancellationToken);
        if (item == null) return BadRequest(new { message = "Booking not found or not owned by you" });

        return CreatedAtAction(nameof(GetById), new { id = item.Id }, item);
    }

    [HttpPost("{id}/complete")]
    public async Task<IActionResult> Complete(Guid id, [FromBody] CompletePaymentRequest request, CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        if (userId == Guid.Empty) return Unauthorized();

        var success = await _sender.Send(new CompletePaymentCommand(id, userId, request.TransactionId), cancellationToken);
        if (!success) return BadRequest(new { message = "Cannot complete this payment" });
        return NoContent();
    }

    [HttpPost("webhook")]
    [AllowAnonymous]
    public async Task<IActionResult> Webhook([FromBody] PaymentWebhookRequest request, CancellationToken cancellationToken)
    {
        var result = await _sender.Send(new ProcessPaymentWebhookCommand(request.PaymentId, request.TransactionId, request.IsSuccess), cancellationToken);
        return result switch
        {
            PaymentWebhookResult.Updated => Ok(new { message = "Payment updated" }),
            PaymentWebhookResult.Ignored => Ok(new { message = "Payment already completed" }),
            _ => NotFound()
        };
    }

    private Guid GetUserId()
    {
        var idStr = User.FindFirstValue(ClaimTypes.NameIdentifier) ?? User.FindFirstValue("sub");
        return Guid.TryParse(idStr, out var id) ? id : Guid.Empty;
    }
}
