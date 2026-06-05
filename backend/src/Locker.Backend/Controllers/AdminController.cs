using Locker.Backend.Application.Features.Admin.Commands.ActivateUser;
using Locker.Backend.Application.Features.Admin.Commands.DeactivateUser;
using Locker.Backend.Application.Features.Admin.Commands.UpdateUserRole;
using Locker.Backend.Application.Features.Admin.Queries.GetAllBookings;
using Locker.Backend.Application.Features.Admin.Queries.GetAllPayments;
using Locker.Backend.Application.Features.Admin.Queries.GetAllUsers;
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

    public AdminController(ISender sender)
    {
        _sender = sender;
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
    public async Task<IActionResult> GetAllPayments(CancellationToken cancellationToken)
    {
        var payments = await _sender.Send(new GetAllPaymentsQuery(), cancellationToken);
        return Ok(payments);
    }
}

public class UpdateUserRoleRequest
{
    public string Role { get; set; } = string.Empty;
}
