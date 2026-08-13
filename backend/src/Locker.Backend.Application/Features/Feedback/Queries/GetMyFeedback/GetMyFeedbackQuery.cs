using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Models;
using MediatR;
using FeedbackEntity = Locker.Backend.Domain.Entities.Feedback;

namespace Locker.Backend.Application.Features.Feedback.Queries.GetMyFeedback;

public sealed record GetMyFeedbackQuery(Guid UserId) : IRequest<FeedbackDto?>;

public sealed class GetMyFeedbackQueryHandler : IRequestHandler<GetMyFeedbackQuery, FeedbackDto?>
{
    private readonly IFeedbackRepository _feedbackRepository;

    public GetMyFeedbackQueryHandler(IFeedbackRepository feedbackRepository)
    {
        _feedbackRepository = feedbackRepository;
    }

    public async Task<FeedbackDto?> Handle(GetMyFeedbackQuery request, CancellationToken cancellationToken)
    {
        var feedback = await _feedbackRepository.GetByUserIdAsync(request.UserId, cancellationToken);
        return feedback is null ? null : ToDto(feedback);
    }

    private static FeedbackDto ToDto(FeedbackEntity item) => new(
        item.Id,
        item.Rating,
        item.Topic,
        item.Content,
        item.PageUrl,
        item.IsVisible,
        item.CreatedAt,
        item.UpdatedAt);
}
