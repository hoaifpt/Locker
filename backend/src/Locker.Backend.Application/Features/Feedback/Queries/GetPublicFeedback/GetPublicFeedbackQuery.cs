using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Models;
using MediatR;
using FeedbackEntity = Locker.Backend.Domain.Entities.Feedback;

namespace Locker.Backend.Application.Features.Feedback.Queries.GetPublicFeedback;

public sealed record GetPublicFeedbackQuery(int Limit = 6) : IRequest<PublicFeedbackResponse>;

public sealed class GetPublicFeedbackQueryHandler : IRequestHandler<GetPublicFeedbackQuery, PublicFeedbackResponse>
{
    private readonly IFeedbackRepository _feedbackRepository;

    public GetPublicFeedbackQueryHandler(IFeedbackRepository feedbackRepository)
    {
        _feedbackRepository = feedbackRepository;
    }

    public async Task<PublicFeedbackResponse> Handle(GetPublicFeedbackQuery request, CancellationToken cancellationToken)
    {
        var limit = Math.Clamp(request.Limit, 1, 6);
        var feedbackTask = _feedbackRepository.GetPublicAsync(limit, cancellationToken);
        var summaryTask = _feedbackRepository.GetSummaryAsync(
            new FeedbackFilter(null, null, true, null),
            cancellationToken);

        await Task.WhenAll(feedbackTask, summaryTask);

        return new PublicFeedbackResponse(
            summaryTask.Result.AverageRating,
            summaryTask.Result.VisibleReviewers,
            feedbackTask.Result.Select(ToPublic).ToList());
    }

    private static PublicFeedbackDto ToPublic(FeedbackEntity item) => new(
        item.Username,
        item.Rating,
        item.Topic,
        item.Content,
        item.UpdatedAt);
}
