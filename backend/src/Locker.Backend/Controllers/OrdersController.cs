using System.Security.Claims;
using Locker.Backend.Application.Models;
using Locker.Backend.Application.Services;
using Locker.Backend.Domain.Enums;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Locker.Backend.Controllers;

[ApiController]
[Route("api/orders")]
[Authorize]
public class OrdersController : ControllerBase
{
    private readonly OrderService _orderService;

    public OrdersController(OrderService orderService)
    {
        _orderService = orderService;
    }

    /// <summary>
    /// Lấy chi tiết đơn hàng theo ID
    /// </summary>
    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(Guid id, CancellationToken cancellationToken)
    {
        var order = await _orderService.GetByIdAsync(id, cancellationToken);
        if (order == null)
            return NotFound(new { message = "Order not found" });
        return Ok(order);
    }

    /// <summary>
    /// Danh sách đơn hàng của người dùng hiện tại
    /// </summary>
    [HttpGet("my")]
    public async Task<IActionResult> GetMyOrders(
        [FromQuery] OrderStatus? status,
        CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        if (userId == Guid.Empty)
            return Unauthorized();

        var orders = await _orderService.GetMyOrdersAsync(userId, status, cancellationToken);
        return Ok(orders);
    }

    /// <summary>
    /// Bước 1: Khởi tạo đơn hàng mới (Initiated)
    /// </summary>
    [HttpPost("reserve")]
    public async Task<IActionResult> Reserve(
        [FromBody] CreateOrderRequest request,
        CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        if (userId == Guid.Empty)
            return Unauthorized();

        var confirmation = await _orderService.CreateAsync(userId, request, cancellationToken);
        if (confirmation == null)
            return BadRequest(new { message = "Cannot create order. Slot not available or invalid parameters" });

        return CreatedAtAction(nameof(GetById), new { id = confirmation.OrderId }, confirmation);
    }

    /// <summary>
    /// Bước 2: Xác nhận đơn hàng sau khi thanh toán (Reserved)
    /// </summary>
    [HttpPatch("{id}/confirm")]
    public async Task<IActionResult> Confirm(
        Guid id,
        [FromBody] ConfirmOrderRequest request,
        CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        if (userId == Guid.Empty)
            return Unauthorized();

        var order = await _orderService.ConfirmAsync(id, userId, request, cancellationToken);
        if (order == null)
            return BadRequest(new { message = "Cannot confirm order. Payment may not be completed" });

        return Ok(order);
    }

    /// <summary>
    /// Bước 3: Đặt mã PIN để mở khoang (sau khi thanh toán)
    /// </summary>
    [HttpPost("{id}/set-pin")]
    public async Task<IActionResult> SetPin(
        Guid id,
        [FromBody] SetOrderPinRequest request,
        CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        if (userId == Guid.Empty)
            return Unauthorized();

        var success = await _orderService.SetPinAsync(id, userId, request, cancellationToken);
        if (!success)
            return BadRequest(new { message = "Cannot set PIN. Order may not be in Paid status" });

        return NoContent();
    }

    /// <summary>
    /// Bước 4: Kích hoạt đơn hàng (bắt đầu sử dụng) (Active)
    /// </summary>
    [HttpPatch("{id}/activate")]
    public async Task<IActionResult> Activate(
        Guid id,
        CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        if (userId == Guid.Empty)
            return Unauthorized();

        var order = await _orderService.ActivateAsync(id, userId, cancellationToken);
        if (order == null)
            return BadRequest(new { message = "Cannot activate order. Check-in time is invalid" });

        return Ok(order);
    }

    /// <summary>
    /// Bước 5: Hoàn thành đơn hàng (Completed)
    /// </summary>
    [HttpPatch("{id}/complete")]
    public async Task<IActionResult> Complete(
        Guid id,
        [FromBody] CompleteOrderRequest request,
        CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        if (userId == Guid.Empty)
            return Unauthorized();

        var order = await _orderService.CompleteAsync(id, userId, request, cancellationToken);
        if (order == null)
            return BadRequest(new { message = "Cannot complete order. Order may not be Active" });

        return Ok(order);
    }

    /// <summary>
    /// Hủy đơn hàng với chính sách hoàn tiền
    /// </summary>
    [HttpPatch("{id}/cancel")]
    public async Task<IActionResult> Cancel(
        Guid id,
        [FromBody] CancelOrderRequest request,
        CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        if (userId == Guid.Empty)
            return Unauthorized();

        var order = await _orderService.CancelAsync(id, userId, request, cancellationToken);
        if (order == null)
            return BadRequest(new { message = "Cannot cancel order. Order may be Completed or already Cancelled" });

        return Ok(order);
    }

    /// <summary>
    /// Gia hạn thêm thời gian cho đơn hàng
    /// </summary>
    [HttpPost("{id}/extend")]
    public async Task<IActionResult> Extend(
        Guid id,
        [FromBody] ExtendOrderRequest request,
        CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        if (userId == Guid.Empty)
            return Unauthorized();

        var order = await _orderService.ExtendAsync(id, userId, request, cancellationToken);
        if (order == null)
            return BadRequest(new { message = "Cannot extend order. Order may not be Active or Reserved" });

        return Ok(order);
    }

    /// <summary>
    /// Kiểm tra khoang còn trống
    /// </summary>
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

        var slots = await _orderService.GetAvailableSlotsByLockerAsync(
            lockerId,
            fromTime,
            toTime,
            cancellationToken);

        return Ok(slots);
    }

    /// <summary>
    /// Liên kết Payment với Order (Admin)
    /// </summary>
    [HttpPost("{id}/payment")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> LinkPayment(
        Guid id,
        [FromBody] LinkPaymentRequest request,
        CancellationToken cancellationToken)
    {
        var updated = await _orderService.LinkPaymentAsync(id, request.PaymentId, cancellationToken);
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
