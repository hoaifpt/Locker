using System;
using System.Security.Claims;
using System.Threading;
using System.Threading.Tasks;
using Locker.Backend.Application.Features.DeviceTokens.Commands.DeleteDeviceToken;
using Locker.Backend.Application.Features.DeviceTokens.Queries.GetMyDeviceTokens;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Locker.Backend.Controllers;

[ApiController]
[Route("api/device-tokens")]
[Authorize]
public class DeviceTokensController : ControllerBase
{
    private readonly ISender _sender;

    public DeviceTokensController(ISender sender)
    {
        _sender = sender;
    }

    [HttpGet("my")]
    public async Task<IActionResult> GetMy(CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        if (userId == Guid.Empty) return Unauthorized();

        var tokens = await _sender.Send(new GetMyDeviceTokensQuery(userId), cancellationToken);
        return Ok(tokens);
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(Guid id, CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        if (userId == Guid.Empty) return Unauthorized();

        var success = await _sender.Send(new DeleteDeviceTokenCommand(id, userId), cancellationToken);
        if (!success) return NotFound();
        return Ok();
    }

    private Guid GetUserId()
    {
        var idStr = User.FindFirstValue(ClaimTypes.NameIdentifier) ?? User.FindFirstValue("sub");
        return Guid.TryParse(idStr, out var id) ? id : Guid.Empty;
    }
}
