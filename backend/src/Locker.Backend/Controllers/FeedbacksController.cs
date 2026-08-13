using System.Security.Claims;
using Locker.Backend.Application.Features.Feedback.Commands.UpsertMyFeedback;
using Locker.Backend.Application.Features.Feedback.Queries.GetMyFeedback;
using Locker.Backend.Application.Features.Feedback.Queries.GetPublicFeedback;
using Locker.Backend.Application.Models;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Locker.Backend.Controllers;

[ApiController]
[Route("api/feedbacks")]
public sealed class FeedbacksController : ControllerBase
{
    private readonly ISender _sender;

    public FeedbacksController(ISender sender)
    {
        _sender = sender;
    }

    [Authorize]
    [HttpGet("me")]
    public async Task<IActionResult> GetMine(CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        if (userId == Guid.Empty)
            return Unauthorized();

        var feedback = await _sender.Send(new GetMyFeedbackQuery(userId), cancellationToken);
        return feedback is null ? NoContent() : Ok(feedback);
    }

    [Authorize]
    [HttpPut("me")]
    public async Task<IActionResult> Upsert(
        [FromBody] UpsertFeedbackRequest request,
        CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        if (userId == Guid.Empty)
            return Unauthorized();

        var feedback = await _sender.Send(new UpsertMyFeedbackCommand(
            userId,
            request.Rating,
            request.Topic,
            request.Content,
            request.PageUrl), cancellationToken);

        return feedback is null ? NotFound() : Ok(feedback);
    }

    [AllowAnonymous]
    [HttpGet("public")]
    public async Task<IActionResult> GetPublic(
        [FromQuery] int limit = 6,
        CancellationToken cancellationToken = default)
        => Ok(await _sender.Send(new GetPublicFeedbackQuery(limit), cancellationToken));

    private Guid GetUserId()
    {
        var value = User.FindFirstValue(ClaimTypes.NameIdentifier) ?? User.FindFirstValue("sub");
        return Guid.TryParse(value, out var userId) ? userId : Guid.Empty;
    }
}
