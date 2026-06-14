using System;
using System.Security.Claims;
using System.Threading;
using System.Threading.Tasks;
using Locker.Backend.Application.Features.Orders.Commands.ActivateOrder;
using Locker.Backend.Application.Features.Orders.Commands.CancelOrder;
using Locker.Backend.Application.Features.Orders.Commands.CompleteOrder;
using Locker.Backend.Application.Features.Orders.Commands.ConfirmOrder;
using Locker.Backend.Application.Features.Orders.Commands.CreateOrder;
using Locker.Backend.Application.Features.Orders.Commands.ExtendOrder;
using Locker.Backend.Application.Features.Orders.Commands.LinkPayment;
using Locker.Backend.Application.Features.Orders.Commands.SetOrderPin;
using Locker.Backend.Application.Features.Orders.Queries.GetAllOrders;
using Locker.Backend.Application.Features.Orders.Queries.GetAvailableSlotsByLocker;
using Locker.Backend.Application.Features.Orders.Queries.GetMyOrders;
using Locker.Backend.Application.Features.Orders.Queries.GetOrderById;
using Locker.Backend.Application.Models;
using Locker.Backend.Domain.Enums;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Locker.Backend.Controllers;

[ApiController]
[Route("api/orders")]
[Authorize]
public class OrdersController : ControllerBase
{
    private readonly ISender _sender;

    public OrdersController(ISender sender)
    {
        _sender = sender;
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(Guid id, CancellationToken cancellationToken)
    {
        var order = await _sender.Send(new GetOrderByIdQuery(id), cancellationToken);
        if (order == null)
            return NotFound(new { message = "Order not found" });
        return Ok(order);
    }

    [HttpGet("my")]
    public async Task<IActionResult> GetMyOrders(
        [FromQuery] OrderStatus? status,
        CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        if (userId == Guid.Empty)
            return Unauthorized();

        var orders = await _sender.Send(new GetMyOrdersQuery(userId, status), cancellationToken);
        return Ok(orders);
    }

    [HttpPost("reserve")]
    public async Task<IActionResult> Reserve(
        [FromBody] CreateOrderRequest request,
        CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        if (userId == Guid.Empty)
            return Unauthorized();

        var confirmation = await _sender.Send(new CreateOrderCommand(
            userId,
            request.LockerId,
            request.SlotIndex,
            request.PackageId,
            request.CheckInTime,
            request.DurationHours,
            request.MobileNumber,
            request.Notes), cancellationToken);

        if (confirmation == null)
            return BadRequest(new { message = "Cannot create order. Slot not available or invalid parameters" });

        return CreatedAtAction(nameof(GetById), new { id = confirmation.OrderId }, confirmation);
    }

    [HttpPatch("{id}/confirm")]
    public async Task<IActionResult> Confirm(
        Guid id,
        [FromBody] ConfirmOrderRequest request,
        CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        if (userId == Guid.Empty)
            return Unauthorized();

        var order = await _sender.Send(new ConfirmOrderCommand(id, userId, request.Notes), cancellationToken);
        if (order == null)
            return BadRequest(new { message = "Cannot confirm order. Payment may not be completed" });

        return Ok(order);
    }

    [HttpPost("{id}/set-pin")]
    public async Task<IActionResult> SetPin(
        Guid id,
        [FromBody] SetOrderPinRequest request,
        CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        if (userId == Guid.Empty)
            return Unauthorized();

        var success = await _sender.Send(new SetOrderPinCommand(id, userId, request.Pin), cancellationToken);
        if (!success)
            return BadRequest(new { message = "Cannot set PIN. Order may not be in Paid status" });

        return NoContent();
    }

    [HttpPatch("{id}/activate")]
    public async Task<IActionResult> Activate(
        Guid id,
        CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        if (userId == Guid.Empty)
            return Unauthorized();

        var order = await _sender.Send(new ActivateOrderCommand(id, userId), cancellationToken);
        if (order == null)
            return BadRequest(new { message = "Cannot activate order. Check-in time is invalid" });

        return Ok(order);
    }

    [HttpPatch("{id}/complete")]
    public async Task<IActionResult> Complete(
        Guid id,
        [FromBody] CompleteOrderRequest request,
        CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        if (userId == Guid.Empty)
            return Unauthorized();

        var order = await _sender.Send(new CompleteOrderCommand(id, userId, request.Notes), cancellationToken);
        if (order == null)
            return BadRequest(new { message = "Cannot complete order. Order may not be Active" });

        return Ok(order);
    }

    [HttpPatch("{id}/cancel")]
    public async Task<IActionResult> Cancel(
        Guid id,
        [FromBody] CancelOrderRequest request,
        CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        if (userId == Guid.Empty)
            return Unauthorized();

        var order = await _sender.Send(new CancelOrderCommand(id, userId, request.CancellationReason ?? string.Empty), cancellationToken);
        if (order == null)
            return BadRequest(new { message = "Cannot cancel order. Order may be Completed or already Cancelled" });

        return Ok(order);
    }

    [HttpPost("{id}/extend")]
    public async Task<IActionResult> Extend(
        Guid id,
        [FromBody] ExtendOrderRequest request,
        CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        if (userId == Guid.Empty)
            return Unauthorized();

        var order = await _sender.Send(new ExtendOrderCommand(id, userId, request.AdditionalHours), cancellationToken);
        if (order == null)
            return BadRequest(new { message = "Cannot extend order. Order may not be Active or Reserved" });

        return Ok(order);
    }

    [HttpGet("availability/slots")]
    [AllowAnonymous]
    public async Task<IActionResult> GetAvailableSlots(
        [FromQuery] Guid lockerId,
        [FromQuery] DateTime fromTime,
        [FromQuery] DateTime toTime,
        CancellationToken cancellationToken)
    {
        if (lockerId == Guid.Empty)
            return BadRequest(new { message = "lockerId is required" });

        if (fromTime >= toTime)
            return BadRequest(new { message = "fromTime must be before toTime" });

        var slots = await _sender.Send(new GetAvailableSlotsByLockerQuery(lockerId, fromTime, toTime), cancellationToken);

        return Ok(slots);
    }

    [HttpPost("{id}/payment")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> LinkPayment(
        Guid id,
        [FromBody] LinkPaymentRequest request,
        CancellationToken cancellationToken)
    {
        var updated = await _sender.Send(new LinkPaymentCommand(id, request.PaymentId), cancellationToken);
        if (!updated) return NotFound();
        return NoContent();
    }

    private Guid GetUserId()
    {
        var idStr = User.FindFirstValue(ClaimTypes.NameIdentifier) ?? User.FindFirstValue("sub");
        return Guid.TryParse(idStr, out var id) ? id : Guid.Empty;
    }
}

public class LinkPaymentRequest
{
    public Guid PaymentId { get; set; }
}
