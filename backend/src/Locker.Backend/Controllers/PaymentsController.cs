using System;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using Locker.Backend.Application.Features.Payments.Commands.CompletePayment;
using Locker.Backend.Application.Features.Payments.Commands.CreatePayment;
using Locker.Backend.Application.Features.Payments.Commands.ProcessPaymentWebhook;
using Locker.Backend.Application.Features.Payments.Queries.GetMyPayments;
using Locker.Backend.Application.Features.Payments.Queries.GetPaymentByBookingId;
using Locker.Backend.Application.Features.Payments.Queries.GetPaymentById;
using Locker.Backend.Application.Models;
using Locker.Backend.Infrastructure.Notifications;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Options;

namespace Locker.Backend.Controllers;

[ApiController]
[Route("api/payments")]
[Authorize]
public class PaymentsController : ControllerBase
{
    private readonly ISender _sender;
    private readonly PaymentWebhookSettings _webhookSettings;

    public PaymentsController(ISender sender, IOptions<PaymentWebhookSettings> webhookSettings)
    {
        _sender = sender;
        _webhookSettings = webhookSettings.Value;
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
        if (!Request.Headers.TryGetValue("X-Signature", out var providedSignature) ||
            string.IsNullOrWhiteSpace(providedSignature) ||
            !IsValidWebhookSignature(request, providedSignature!))
        {
            return Unauthorized(new { message = "Invalid webhook signature" });
        }

        var result = await _sender.Send(new ProcessPaymentWebhookCommand(request.PaymentId, request.TransactionId, request.IsSuccess), cancellationToken);
        return result switch
        {
            PaymentWebhookResult.Updated => Ok(new { message = "Payment updated" }),
            PaymentWebhookResult.Ignored => Ok(new { message = "Payment already completed" }),
            _ => NotFound()
        };
    }

    private bool IsValidWebhookSignature(PaymentWebhookRequest request, string providedSignature)
    {
        if (string.IsNullOrWhiteSpace(_webhookSettings.Secret))
        {
            return false;
        }

        var payload = $"{request.PaymentId}:{request.TransactionId}:{request.IsSuccess}";
        using var hmac = new HMACSHA256(Encoding.UTF8.GetBytes(_webhookSettings.Secret));
        var hash = hmac.ComputeHash(Encoding.UTF8.GetBytes(payload));
        var expectedSignature = Convert.ToHexString(hash).ToLowerInvariant();
        var providedBytes = Encoding.UTF8.GetBytes(providedSignature.Trim().ToLowerInvariant());
        var expectedBytes = Encoding.UTF8.GetBytes(expectedSignature);

        return CryptographicOperations.FixedTimeEquals(providedBytes, expectedBytes);
    }

    private Guid GetUserId()
    {
        var idStr = User.FindFirstValue(ClaimTypes.NameIdentifier) ?? User.FindFirstValue("sub");
        return Guid.TryParse(idStr, out var id) ? id : Guid.Empty;
    }
}
