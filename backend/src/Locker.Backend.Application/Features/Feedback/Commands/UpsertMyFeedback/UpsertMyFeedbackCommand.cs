using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Models;
using Locker.Backend.Domain.Enums;
using MediatR;
using FeedbackEntity = Locker.Backend.Domain.Entities.Feedback;

namespace Locker.Backend.Application.Features.Feedback.Commands.UpsertMyFeedback;

public sealed record UpsertMyFeedbackCommand(
    Guid UserId,
    int Rating,
    FeedbackTopic Topic,
    string Content,
    string PageUrl) : IRequest<FeedbackDto?>;

public sealed class UpsertMyFeedbackCommandHandler : IRequestHandler<UpsertMyFeedbackCommand, FeedbackDto?>
{
    private readonly IFeedbackRepository _feedbackRepository;
    private readonly IIdentityService _identityService;
    private readonly IRealtimeNotificationService _notificationService;

    public UpsertMyFeedbackCommandHandler(
        IFeedbackRepository feedbackRepository,
        IIdentityService identityService,
        IRealtimeNotificationService notificationService)
    {
        _feedbackRepository = feedbackRepository;
        _identityService = identityService;
        _notificationService = notificationService;
    }

    public async Task<FeedbackDto?> Handle(UpsertMyFeedbackCommand request, CancellationToken cancellationToken)
    {
        var user = await _identityService.FindByIdAsync(request.UserId.ToString());
        if (user is null)
            return null;

        var existing = await _feedbackRepository.GetByUserIdAsync(request.UserId, cancellationToken);
        var isUpdate = existing is not null;

        var username = user.UserName ?? user.FullName ?? "Người dùng";
        var feedback = await _feedbackRepository.UpsertByUserIdAsync(
            request.UserId,
            username,
            request.Rating,
            request.Topic,
            request.Content.Trim(),
            request.PageUrl,
            cancellationToken);

        await _notificationService.NotifyAdminsAsync(
            isUpdate ? "Feedback đã được cập nhật" : "Feedback mới",
            $"Có feedback {request.Rating}/5 về chủ đề {request.Topic} cần xem xét.",
            cancellationToken);

        return ToDto(feedback);
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
