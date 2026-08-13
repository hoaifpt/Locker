using System.Text.RegularExpressions;
using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Models;
using Locker.Backend.Domain.Entities;
using Locker.Backend.Domain.Enums;
using Locker.Backend.Infrastructure.Mongo;
using MongoDB.Bson;
using MongoDB.Driver;

namespace Locker.Backend.Infrastructure.Repositories;

public class FeedbackRepository : IFeedbackRepository
{
    private readonly IMongoCollection<Feedback> _collection;

    public FeedbackRepository(MongoContext context)
    {
        _collection = context.Database.GetCollection<Feedback>(context.Settings.FeedbacksCollection);
    }

    public async Task<Feedback?> GetByUserIdAsync(Guid userId, CancellationToken cancellationToken)
    {
        return await _collection.Find(x => x.UserId == userId).FirstOrDefaultAsync(cancellationToken);
    }

    public async Task<Feedback> UpsertByUserIdAsync(
        Guid userId,
        string username,
        int rating,
        FeedbackTopic topic,
        string content,
        string pageUrl,
        CancellationToken cancellationToken)
    {
        var now = DateTime.UtcNow;
        var update = Builders<Feedback>.Update
            .Set(x => x.Username, username)
            .Set(x => x.Rating, rating)
            .Set(x => x.Topic, topic)
            .Set(x => x.Content, content.Trim())
            .Set(x => x.PageUrl, pageUrl)
            .Set(x => x.UpdatedAt, now)
            .SetOnInsert(x => x.Id, Guid.CreateVersion7())
            .SetOnInsert(x => x.UserId, userId)
            .SetOnInsert(x => x.IsVisible, true)
            .SetOnInsert(x => x.CreatedAt, now);

        return await _collection.FindOneAndUpdateAsync(
            x => x.UserId == userId,
            update,
            new FindOneAndUpdateOptions<Feedback> { IsUpsert = true, ReturnDocument = ReturnDocument.After },
            cancellationToken);
    }

    public async Task<IReadOnlyList<Feedback>> GetPublicAsync(int limit, CancellationToken cancellationToken)
    {
        return await _collection.Find(x => x.IsVisible)
            .SortByDescending(x => x.UpdatedAt)
            .Limit(limit)
            .ToListAsync(cancellationToken);
    }

    public async Task<FeedbackSummaryDto> GetSummaryAsync(FeedbackFilter filter, CancellationToken cancellationToken)
    {
        var mongoFilter = BuildFilter(filter);
        var totalReviewersTask = _collection.CountDocumentsAsync(
            Builders<Feedback>.Filter.Empty,
            cancellationToken: cancellationToken);
        var filteredFeedbacksTask = _collection.Find(mongoFilter).ToListAsync(cancellationToken);

        await Task.WhenAll(totalReviewersTask, filteredFeedbacksTask);

        var feedbacks = filteredFeedbacksTask.Result;
        var averageRating = feedbacks.Count == 0
            ? 0
            : Math.Round(feedbacks.Average(x => x.Rating), 2);

        var ratingDistribution = Enumerable.Range(1, 5)
            .Select(rating => new RatingDistributionDto(rating, feedbacks.Count(x => x.Rating == rating)))
            .ToList();
        var topicDistribution = Enum.GetValues<FeedbackTopic>()
            .Select(topic => new TopicDistributionDto(topic, feedbacks.Count(x => x.Topic == topic)))
            .ToList();

        return new FeedbackSummaryDto(
            checked((int)totalReviewersTask.Result),
            averageRating,
            feedbacks.Count(x => x.IsVisible),
            ratingDistribution,
            topicDistribution);
    }

    public async Task<PaginatedResult<Feedback>> GetAdminPageAsync(
        FeedbackFilter filter,
        int page,
        int pageSize,
        CancellationToken cancellationToken)
    {
        var mongoFilter = BuildFilter(filter);
        var totalCountTask = _collection.CountDocumentsAsync(mongoFilter, cancellationToken: cancellationToken);
        var itemsTask = _collection.Find(mongoFilter)
            .SortByDescending(x => x.UpdatedAt)
            .Skip((page - 1) * pageSize)
            .Limit(pageSize)
            .ToListAsync(cancellationToken);

        await Task.WhenAll(totalCountTask, itemsTask);

        return new PaginatedResult<Feedback>
        {
            Items = itemsTask.Result,
            TotalCount = checked((int)totalCountTask.Result),
            PageNumber = page,
            PageSize = pageSize
        };
    }

    public async Task<IReadOnlyList<Feedback>> GetForExportAsync(FeedbackFilter filter, CancellationToken cancellationToken)
    {
        return await _collection.Find(BuildFilter(filter))
            .SortByDescending(x => x.UpdatedAt)
            .ToListAsync(cancellationToken);
    }

    public async Task<bool> SetVisibilityAsync(Guid id, bool isVisible, CancellationToken cancellationToken)
    {
        var result = await _collection.UpdateOneAsync(
            x => x.Id == id,
            Builders<Feedback>.Update.Set(x => x.IsVisible, isVisible),
            cancellationToken: cancellationToken);
        return result.MatchedCount == 1;
    }

    private static FilterDefinition<Feedback> BuildFilter(FeedbackFilter filter)
    {
        var parts = new List<FilterDefinition<Feedback>>();

        if (filter.Rating.HasValue)
            parts.Add(Builders<Feedback>.Filter.Eq(x => x.Rating, filter.Rating.Value));
        if (filter.Topic.HasValue)
            parts.Add(Builders<Feedback>.Filter.Eq(x => x.Topic, filter.Topic.Value));
        if (filter.IsVisible.HasValue)
            parts.Add(Builders<Feedback>.Filter.Eq(x => x.IsVisible, filter.IsVisible.Value));
        if (!string.IsNullOrWhiteSpace(filter.Search))
        {
            var safe = Regex.Escape(filter.Search.Trim());
            var regex = new BsonRegularExpression(safe, "i");
            parts.Add(Builders<Feedback>.Filter.Or(
                Builders<Feedback>.Filter.Regex(x => x.Username, regex),
                Builders<Feedback>.Filter.Regex(x => x.Content, regex)));
        }

        return parts.Count == 0
            ? Builders<Feedback>.Filter.Empty
            : Builders<Feedback>.Filter.And(parts);
    }
}
