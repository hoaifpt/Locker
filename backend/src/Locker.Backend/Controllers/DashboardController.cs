using System;
using System.Security.Claims;
using System.Threading;
using System.Threading.Tasks;
using Locker.Backend.Application.Features.DeliveryRequests.Queries.GetShipperDashboard;
using Locker.Backend.Application.Features.Users.Queries.GetUserDashboard;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Locker.Backend.Controllers;

[ApiController]
[Route("api/dashboard")]
[Authorize]
public class DashboardController : ControllerBase
{
    private readonly ISender _sender;

    public DashboardController(ISender sender)
    {
        _sender = sender;
    }

    [HttpGet("shipper")]
    [Authorize(Roles = "Shipper")] // Assuming Shipper role is used based on your existing code
    public async Task<IActionResult> GetShipperDashboard(CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        if (userId == Guid.Empty) return Unauthorized();

        var dashboard = await _sender.Send(new GetShipperDashboardQuery(userId), cancellationToken);
        return Ok(dashboard);
    }

    [HttpGet("user")]
    public async Task<IActionResult> GetUserDashboard(CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        if (userId == Guid.Empty) return Unauthorized();

        var dashboard = await _sender.Send(new GetUserDashboardQuery(userId), cancellationToken);
        return Ok(dashboard);
    }

    private Guid GetUserId()
    {
        var idStr = User.FindFirstValue(ClaimTypes.NameIdentifier) ?? User.FindFirstValue("sub");
        return Guid.TryParse(idStr, out var id) ? id : Guid.Empty;
    }
}
