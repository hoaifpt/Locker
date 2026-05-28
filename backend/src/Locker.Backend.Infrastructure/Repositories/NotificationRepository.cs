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
        var cursor = await _collection.FindAsync(n => n.UserId == userId, cancellationToken: cancellationToken);
        return await cursor.ToListAsync(cancellationToken);
    }

    public async Task<bool> MarkAsReadAsync(string notificationId, string userId, CancellationToken cancellationToken)
    {
        var update = Builders<Notification>.Update.Set(n => n.IsRead, true);
        var result = await _collection.UpdateOneAsync(
            n => n.Id == notificationId && n.UserId == userId,
            update,
            cancellationToken: cancellationToken);
        return result.ModifiedCount > 0;
    }

    public async Task<int> MarkAllAsReadAsync(string userId, CancellationToken cancellationToken)
    {
        var update = Builders<Notification>.Update.Set(n => n.IsRead, true);
        var result = await _collection.UpdateManyAsync(
            n => n.UserId == userId && !n.IsRead,
            update,
            cancellationToken: cancellationToken);
        return (int)result.ModifiedCount;
    }
}
