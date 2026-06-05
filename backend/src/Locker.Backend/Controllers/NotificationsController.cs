using System.Security.Claims;
using Locker.Backend.Application.Models;
using Locker.Backend.Application.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Locker.Backend.Controllers;

[ApiController]
[Route("api/notifications")]
[Authorize]
public class NotificationsController : ControllerBase
{
    private readonly NotificationService _notificationService;

    public NotificationsController(NotificationService notificationService)
    {
        _notificationService = notificationService;
    }

    [HttpGet("my")]
    public async Task<IActionResult> GetMy(CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        if (userId == null) return Unauthorized();

        var items = await _notificationService.GetMyAsync(userId, cancellationToken);
        return Ok(items);
    }

    [HttpPost("{id}/mark-as-read")]
    public async Task<IActionResult> MarkAsRead(Guid id, CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        if (userId == null) return Unauthorized();

        var updated = await _notificationService.MarkAsReadAsync(id, userId, cancellationToken);
        if (!updated) return NotFound();
        return NoContent();
    }

    [HttpPost("mark-all-as-read")]
    public async Task<IActionResult> MarkAllAsRead(CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        if (userId == null) return Unauthorized();

        await _notificationService.MarkAllAsReadAsync(userId, cancellationToken);
        return NoContent();
    }

    [HttpPost("register-device")]
    public async Task<IActionResult> RegisterDevice([FromBody] RegisterDeviceRequest request, CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        if (userId == null) return Unauthorized();

        await _notificationService.RegisterDeviceAsync(userId, request, cancellationToken);
        return NoContent();
    }

    private Guid GetUserId()
    {
        var idStr = User.FindFirstValue(ClaimTypes.NameIdentifier) ?? User.FindFirstValue("sub");
        return Guid.TryParse(idStr, out var id) ? id : Guid.Empty;
    }
}
