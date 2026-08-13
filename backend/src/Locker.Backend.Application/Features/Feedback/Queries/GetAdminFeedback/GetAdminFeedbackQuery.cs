using FluentValidation;
using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Models;
using Locker.Backend.Domain.Enums;
using MediatR;
using FeedbackEntity = Locker.Backend.Domain.Entities.Feedback;

namespace Locker.Backend.Application.Features.Feedback.Queries.GetAdminFeedback;

public sealed record GetAdminFeedbackQuery(
    int Page,
    int PageSize,
    int? Rating,
    FeedbackTopic? Topic,
    bool? IsVisible,
    string? Search) : IRequest<AdminFeedbackResponse>;

public sealed class GetAdminFeedbackQueryValidator : AbstractValidator<GetAdminFeedbackQuery>
{
    public GetAdminFeedbackQueryValidator()
    {
        RuleFor(x => x.Page).GreaterThanOrEqualTo(1);
        RuleFor(x => x.PageSize).InclusiveBetween(1, 100);
        RuleFor(x => x.Rating).InclusiveBetween(1, 5).When(x => x.Rating.HasValue);
        RuleFor(x => x.Topic).IsInEnum().When(x => x.Topic.HasValue);
        RuleFor(x => x.Search).MaximumLength(200).When(x => x.Search is not null);
    }
}

public sealed class GetAdminFeedbackQueryHandler
    : IRequestHandler<GetAdminFeedbackQuery, AdminFeedbackResponse>
{
    private readonly IFeedbackRepository _repository;

    public GetAdminFeedbackQueryHandler(IFeedbackRepository repository)
    {
        _repository = repository;
    }

    public async Task<AdminFeedbackResponse> Handle(
        GetAdminFeedbackQuery request,
        CancellationToken cancellationToken)
    {
        var filter = new FeedbackFilter(
            request.Rating,
            request.Topic,
            request.IsVisible,
            request.Search);
        var pageTask = _repository.GetAdminPageAsync(filter, request.Page, request.PageSize, cancellationToken);
        var summaryTask = _repository.GetSummaryAsync(filter, cancellationToken);

        await Task.WhenAll(pageTask, summaryTask);

        var page = pageTask.Result;
        return new AdminFeedbackResponse(
            new PaginatedResult<AdminFeedbackItemDto>
            {
                Items = page.Items.Select(ToDto).ToList(),
                TotalCount = page.TotalCount,
                PageNumber = page.PageNumber,
                PageSize = page.PageSize
            },
            summaryTask.Result);
    }

    private static AdminFeedbackItemDto ToDto(FeedbackEntity item) => new(
        item.Id,
        item.Username,
        item.Rating,
        item.Topic,
        item.Content,
        item.PageUrl,
        item.IsVisible,
        item.CreatedAt,
        item.UpdatedAt);
}
