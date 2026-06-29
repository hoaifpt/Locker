using System.Security.Claims;
using Locker.Backend.Application.Models;
using Locker.Backend.Application.Features.Users.Commands.ChangePassword;
using Locker.Backend.Application.Features.Users.Commands.UpdateProfile;
using Locker.Backend.Application.Features.Users.Queries.GetProfile;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Threading;
using System.Threading.Tasks;
using System;

namespace Locker.Backend.Controllers;

[ApiController]
[Route("api/users")]
[Authorize]
public class UsersController : ControllerBase
{
    private readonly ISender _sender;

    public UsersController(ISender sender)
    {
        _sender = sender;
    }

    [HttpGet("me")]
    public async Task<IActionResult> GetCurrentUser(CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        if (userId == Guid.Empty)
            return Unauthorized();

        var user = await _sender.Send(new GetProfileQuery(userId), cancellationToken);
        if (user == null)
            return NotFound();

        return Ok(user);
    }

    [HttpPut("me")]
    public async Task<IActionResult> UpdateProfile([FromBody] UpdateProfileRequest request, CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        if (userId == Guid.Empty)
            return Unauthorized();

        var user = await _sender.Send(new UpdateProfileCommand(userId, request.Email, request.FullName, request.PhoneNumber), cancellationToken);
        if (user == null)
            return NotFound();

        return Ok(user);
    }

    [HttpPost("me/change-password")]
    public async Task<IActionResult> ChangePassword([FromBody] ChangePasswordRequest request, CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        if (userId == Guid.Empty)
            return Unauthorized();

        var success = await _sender.Send(new ChangePasswordCommand(userId, request.CurrentPassword, request.NewPassword), cancellationToken);
        if (!success)
            return BadRequest(new { message = "Current password is incorrect" });

        return NoContent();
    }

    private Guid GetUserId()
    {
        var idStr = User.FindFirstValue(ClaimTypes.NameIdentifier) ?? User.FindFirstValue("sub");
        return Guid.TryParse(idStr, out var id) ? id : Guid.Empty;
    }
}
