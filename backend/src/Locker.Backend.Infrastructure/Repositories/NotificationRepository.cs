using Locker.Backend.Application.Interfaces;
using Locker.Backend.Domain.Entities;
using Locker.Backend.Infrastructure.Mongo;
using MongoDB.Driver;

namespace Locker.Backend.Infrastructure.Repositories;

public class NotificationRepository : GenericRepository<Notification>, INotificationRepository
{
    public NotificationRepository(MongoContext context)
        : base(context.Database.GetCollection<Notification>(context.Settings.NotificationsCollection))
    {
    }

    public async Task<List<Notification>> GetByUserIdAsync(string userId, CancellationToken cancellationToken)
    {
        return await _collection.Find(x => x.UserId == userId)
                                .SortByDescending(x => x.CreatedAt)
                                .ToListAsync(cancellationToken);
    }

    public async Task<long> CountUnreadAsync(string userId, CancellationToken cancellationToken)
    {
        return await _collection.CountDocumentsAsync(x => x.UserId == userId && !x.IsRead, cancellationToken: cancellationToken);
    }

    public async Task MarkAllAsReadAsync(string userId, CancellationToken cancellationToken)
    {
        var update = Builders<Notification>.Update.Set(x => x.IsRead, true);
        await _collection.UpdateManyAsync(x => x.UserId == userId && !x.IsRead, update, cancellationToken: cancellationToken);
    }
}