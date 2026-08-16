using Locker.Backend.Application.Features.Admin.Commands.ActivateUser;
using Locker.Backend.Application.Features.Admin.Commands.CreateUser;
using Locker.Backend.Application.Features.Admin.Commands.DeactivateUser;
using Locker.Backend.Application.Features.Admin.Commands.UpdateUserRole;
using Locker.Backend.Application.Features.Admin.Queries.GetAllBookings;
using Locker.Backend.Application.Features.Admin.Queries.GetAllPayments;
using Locker.Backend.Application.Features.Admin.Queries.GetAllUsers;
using Locker.Backend.Application.Features.Admin.Queries.GetAllWalletTopUps;
using Locker.Backend.Application.Features.Admin.Queries.GetWalletTopUpSummary;
using Locker.Backend.Application.Interfaces;
using Locker.Backend.Domain.Enums;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Locker.Backend.Controllers;

[ApiController]
[Route("api/admin")]
[Authorize(Roles = "Admin")]
public class AdminController : ControllerBase
{
    private readonly ISender _sender;
    private readonly IIdentityService _identityService;

    public AdminController(ISender sender, IIdentityService identityService)
    {
        _sender = sender;
        _identityService = identityService;
    }

    [HttpPost("users")]
    public async Task<IActionResult> CreateUser([FromBody] CreateUserRequest request, CancellationToken cancellationToken)
    {
        var (user, error) = await _sender.Send(new CreateUserCommand(
            request.Username,
            request.Email,
            request.Password,
            request.Role,
            request.FullName,
            request.PhoneNumber
        ), cancellationToken);

        if (user == null) return BadRequest(new { error });

        var roles = await _identityService.GetRolesAsync(user);
        var role = roles.FirstOrDefault() ?? request.Role;

        return CreatedAtAction(nameof(GetAllUsers), new { id = user.Id }, new
        {
            user.Id,
            user.UserName,
            user.Email,
            user.FullName,
            user.PhoneNumber,
            Role = role,
            user.IsActive,
            user.CreatedAt
        });
    }

    // ── Users ──────────────────────────────────────────────

    [HttpGet("users")]
    public async Task<IActionResult> GetAllUsers(CancellationToken cancellationToken)
    {
        var users = await _sender.Send(new GetAllUsersQuery(), cancellationToken);
        return Ok(users);
    }

    [HttpPut("users/{id}/role")]
    public async Task<IActionResult> UpdateUserRole(Guid id, [FromBody] UpdateUserRoleRequest request, CancellationToken cancellationToken)
    {
        var success = await _sender.Send(new UpdateUserRoleCommand(id, request.Role), cancellationToken);
        if (!success) return NotFound();
        return NoContent();
    }

    [HttpPut("users/{id}/deactivate")]
    public async Task<IActionResult> DeactivateUser(Guid id, CancellationToken cancellationToken)
    {
        var success = await _sender.Send(new DeactivateUserCommand(id), cancellationToken);
        if (!success) return NotFound();
        return NoContent();
    }

    [HttpPut("users/{id}/activate")]
    public async Task<IActionResult> ActivateUser(Guid id, CancellationToken cancellationToken)
    {
        var success = await _sender.Send(new ActivateUserCommand(id), cancellationToken);
        if (!success) return NotFound();
        return NoContent();
    }

    // ── Bookings ───────────────────────────────────────────

    [HttpGet("bookings")]
    public async Task<IActionResult> GetAllBookings([FromQuery] BookingStatus? status, CancellationToken cancellationToken)
    {
        var bookings = await _sender.Send(new GetAllBookingsQuery(status), cancellationToken);
        return Ok(bookings);
    }

    // ── Payments ───────────────────────────────────────────

    [HttpGet("payments")]
    public async Task<IActionResult> GetAllPayments(
        [FromQuery] int pageNumber = 1,
        [FromQuery] int pageSize = 50,
        [FromQuery] DateTime? dateFrom = null,
        [FromQuery] DateTime? dateTo = null,
        CancellationToken cancellationToken = default)
    {
        var payments = await _sender.Send(new GetAllPaymentsQuery(pageNumber, pageSize, dateFrom, dateTo), cancellationToken);
        return Ok(payments);
    }

    // ── Wallet ────────────────────────────────────────────

    /// <summary>Tổng tiền user đã nạp vào hệ thống (Wallet TopUp Completed).
    /// Truyền query <c>date</c> (YYYY-MM-DD) để xem stats của ngày cụ thể
    /// trong quá khứ (hôm qua, hôm kia…). Nếu không truyền, mặc định là
    /// hôm nay (UTC).</summary>
    [HttpGet("wallet/summary")]
    public async Task<IActionResult> GetWalletSummary(
        [FromQuery] DateTime? date = null,
        CancellationToken cancellationToken = default)
    {
        DateTime? selectedUtc = null;
        if (date.HasValue)
        {
            // Chỉ lấy phần ngày (00:00:00 UTC) — tránh client gửi kèm giờ làm lệch.
            selectedUtc = DateTime.SpecifyKind(date.Value.Date, DateTimeKind.Utc);
        }

        var summary = await _sender.Send(new GetWalletTopUpSummaryQuery(selectedUtc), cancellationToken);
        return Ok(summary);
    }

    /// <summary>Danh sách các giao dịch TopUp Completed trong khoảng thời gian.</summary>
    [HttpGet("wallet/top-ups")]
    public async Task<IActionResult> GetWalletTopUps(
        [FromQuery] DateTime? dateFrom = null,
        [FromQuery] DateTime? dateTo = null,
        CancellationToken cancellationToken = default)
    {
        var topUps = await _sender.Send(new GetAllWalletTopUpsQuery(dateFrom, dateTo), cancellationToken);
        return Ok(topUps);
    }
}

public class UpdateUserRoleRequest
{
    public string Role { get; set; } = string.Empty;
}

public class CreateUserRequest
{
    public string Username { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
    public string Role { get; set; } = "User";
    public string? FullName { get; set; }
    public string? PhoneNumber { get; set; }
}
