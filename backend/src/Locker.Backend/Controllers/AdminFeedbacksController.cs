using Locker.Backend.Application.Features.Feedback.Commands.SetFeedbackVisibility;
using Locker.Backend.Application.Features.Feedback.Queries.ExportFeedback;
using Locker.Backend.Application.Features.Feedback.Queries.GetAdminFeedback;
using Locker.Backend.Domain.Enums;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Locker.Backend.Controllers;

public sealed record SetFeedbackVisibilityRequest(bool IsVisible);

[ApiController]
[Route("api/admin/feedbacks")]
[Authorize(Roles = "Admin")]
public sealed class AdminFeedbacksController : ControllerBase
{
    private readonly ISender _sender;

    public AdminFeedbacksController(ISender sender)
    {
        _sender = sender;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll(
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 20,
        [FromQuery] int? rating = null,
        [FromQuery] FeedbackTopic? topic = null,
        [FromQuery] bool? visibility = null,
        [FromQuery] string? search = null,
        CancellationToken cancellationToken = default)
        => Ok(await _sender.Send(
            new GetAdminFeedbackQuery(page, pageSize, rating, topic, visibility, search),
            cancellationToken));

    [HttpPatch("{id:guid}/visibility")]
    public async Task<IActionResult> SetVisibility(
        Guid id,
        [FromBody] SetFeedbackVisibilityRequest request,
        CancellationToken cancellationToken)
    {
        var updated = await _sender.Send(
            new SetFeedbackVisibilityCommand(id, request.IsVisible),
            cancellationToken);
        return updated ? NoContent() : NotFound();
    }

    [HttpGet("export")]
    public async Task<IActionResult> Export(
        [FromQuery] int? rating = null,
        [FromQuery] FeedbackTopic? topic = null,
        [FromQuery] bool? visibility = null,
        [FromQuery] string? search = null,
        CancellationToken cancellationToken = default)
    {
        var result = await _sender.Send(
            new ExportFeedbackQuery(rating, topic, visibility, search),
            cancellationToken);
        return File(result.Content, "text/csv; charset=utf-8", result.FileName);
    }
}
