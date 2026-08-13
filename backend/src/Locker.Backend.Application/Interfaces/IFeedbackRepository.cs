using Locker.Backend.Application.Models;
using Locker.Backend.Domain.Entities;
using Locker.Backend.Domain.Enums;

namespace Locker.Backend.Application.Interfaces;

public interface IFeedbackRepository
{
    Task<Feedback?> GetByUserIdAsync(Guid userId, CancellationToken cancellationToken);
    Task<Feedback> UpsertByUserIdAsync(
        Guid userId,
        string username,
        int rating,
        FeedbackTopic topic,
        string content,
        string pageUrl,
        CancellationToken cancellationToken);
    Task<IReadOnlyList<Feedback>> GetPublicAsync(int limit, CancellationToken cancellationToken);
    Task<FeedbackSummaryDto> GetSummaryAsync(FeedbackFilter filter, CancellationToken cancellationToken);
    Task<PaginatedResult<Feedback>> GetAdminPageAsync(
        FeedbackFilter filter,
        int page,
        int pageSize,
        CancellationToken cancellationToken);
    Task<IReadOnlyList<Feedback>> GetForExportAsync(FeedbackFilter filter, CancellationToken cancellationToken);
    Task<bool> SetVisibilityAsync(Guid id, bool isVisible, CancellationToken cancellationToken);
}
