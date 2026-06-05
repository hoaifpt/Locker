using System;
using System.Security.Claims;
using System.Threading;
using System.Threading.Tasks;
using Locker.Backend.Application.Features.Notifications.Commands.MarkAllNotificationsAsRead;
using Locker.Backend.Application.Features.Notifications.Commands.MarkNotificationAsRead;
using Locker.Backend.Application.Features.Notifications.Commands.RegisterDevice;
using Locker.Backend.Application.Features.Notifications.Queries.GetMyNotifications;
using Locker.Backend.Application.Models;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Locker.Backend.Controllers;

[ApiController]
[Route("api/notifications")]
[Authorize]
public class NotificationsController : ControllerBase
{
    private readonly ISender _sender;

    public NotificationsController(ISender sender)
    {
        _sender = sender;
    }

    [HttpGet("my")]
    public async Task<IActionResult> GetMy(CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        if (userId == Guid.Empty) return Unauthorized();

        var items = await _sender.Send(new GetMyNotificationsQuery(userId), cancellationToken);
        return Ok(items);
    }

    [HttpPost("{id}/mark-as-read")]
    public async Task<IActionResult> MarkAsRead(Guid id, CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        if (userId == Guid.Empty) return Unauthorized();

        var updated = await _sender.Send(new MarkNotificationAsReadCommand(id, userId), cancellationToken);
        if (!updated) return NotFound();
        return NoContent();
    }

    [HttpPost("mark-all-as-read")]
    public async Task<IActionResult> MarkAllAsRead(CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        if (userId == Guid.Empty) return Unauthorized();

        await _sender.Send(new MarkAllNotificationsAsReadCommand(userId), cancellationToken);
        return NoContent();
    }

    [HttpPost("register-device")]
    public async Task<IActionResult> RegisterDevice([FromBody] RegisterDeviceRequest request, CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        if (userId == Guid.Empty) return Unauthorized();

        await _sender.Send(new RegisterDeviceCommand(userId, request.DeviceToken, request.Platform), cancellationToken);
        return NoContent();
    }

    private Guid GetUserId()
    {
        var idStr = User.FindFirstValue(ClaimTypes.NameIdentifier) ?? User.FindFirstValue("sub");
        return Guid.TryParse(idStr, out var id) ? id : Guid.Empty;
    }
}
