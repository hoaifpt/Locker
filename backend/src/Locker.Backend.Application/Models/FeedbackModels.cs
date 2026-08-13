using Locker.Backend.Domain.Enums;

namespace Locker.Backend.Application.Models;

public sealed record UpsertFeedbackRequest(
    int Rating,
    FeedbackTopic Topic,
    string Content,
    string PageUrl);

public sealed record FeedbackDto(
    Guid Id,
    int Rating,
    FeedbackTopic Topic,
    string Content,
    string PageUrl,
    bool IsVisible,
    DateTime CreatedAt,
    DateTime UpdatedAt);

public sealed record PublicFeedbackDto(
    string Username,
    int Rating,
    FeedbackTopic Topic,
    string Content,
    DateTime UpdatedAt);

public sealed record RatingDistributionDto(int Rating, int Count);
public sealed record TopicDistributionDto(FeedbackTopic Topic, int Count);

public sealed record FeedbackSummaryDto(
    int TotalReviewers,
    double AverageRating,
    int VisibleReviewers,
    IReadOnlyList<RatingDistributionDto> RatingDistribution,
    IReadOnlyList<TopicDistributionDto> TopicDistribution);

public sealed record PublicFeedbackResponse(
    double AverageRating,
    int TotalVisibleReviewers,
    IReadOnlyList<PublicFeedbackDto> Reviews);

public sealed record FeedbackFilter(
    int? Rating,
    FeedbackTopic? Topic,
    bool? IsVisible,
    string? Search);

public sealed record AdminFeedbackItemDto(
    Guid Id,
    string Username,
    int Rating,
    FeedbackTopic Topic,
    string Content,
    string PageUrl,
    bool IsVisible,
    DateTime CreatedAt,
    DateTime UpdatedAt);

public sealed record AdminFeedbackResponse(
    PaginatedResult<AdminFeedbackItemDto> Page,
    FeedbackSummaryDto Summary);

public sealed record ExportFeedbackResult(byte[] Content, string FileName);
