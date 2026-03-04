using Locker.Backend.Application.Services;
using Locker.Backend.Domain.Enums;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Locker.Backend.Controllers;

[ApiController]
[Route("api/admin")]
[Authorize(Roles = "Admin")]
public class AdminController : ControllerBase
{
    private readonly AdminService _adminService;

    public AdminController(AdminService adminService)
    {
        _adminService = adminService;
    }

    // ── Users ──────────────────────────────────────────────

    [HttpGet("users")]
    public async Task<IActionResult> GetAllUsers(CancellationToken cancellationToken)
    {
        var users = await _adminService.GetAllUsersAsync(cancellationToken);
        return Ok(users);
    }

    [HttpPut("users/{id}/role")]
    public async Task<IActionResult> UpdateUserRole(string id, [FromBody] UpdateUserRoleRequest request, CancellationToken cancellationToken)
    {
        var success = await _adminService.UpdateUserRoleAsync(id, request.Role, cancellationToken);
        if (!success) return NotFound();
        return NoContent();
    }

    [HttpPut("users/{id}/deactivate")]
    public async Task<IActionResult> DeactivateUser(string id, CancellationToken cancellationToken)
    {
        var success = await _adminService.DeactivateUserAsync(id, cancellationToken);
        if (!success) return NotFound();
        return NoContent();
    }

    [HttpPut("users/{id}/activate")]
    public async Task<IActionResult> ActivateUser(string id, CancellationToken cancellationToken)
    {
        var success = await _adminService.ActivateUserAsync(id, cancellationToken);
        if (!success) return NotFound();
        return NoContent();
    }

    // ── Bookings ───────────────────────────────────────────

    [HttpGet("bookings")]
    public async Task<IActionResult> GetAllBookings([FromQuery] BookingStatus? status, CancellationToken cancellationToken)
    {
        var bookings = await _adminService.GetAllBookingsAsync(status, cancellationToken);
        return Ok(bookings);
    }

    // ── Payments ───────────────────────────────────────────

    [HttpGet("payments")]
    public async Task<IActionResult> GetAllPayments(CancellationToken cancellationToken)
    {
        var payments = await _adminService.GetAllPaymentsAsync(cancellationToken);
        return Ok(payments);
    }
}

public class UpdateUserRoleRequest
{
    public string Role { get; set; } = string.Empty;
}
