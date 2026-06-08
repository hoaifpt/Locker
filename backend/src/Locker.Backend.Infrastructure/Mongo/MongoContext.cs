using Locker.Backend.Domain.Entities;
using Microsoft.Extensions.Options;
using MongoDB.Bson;
using MongoDB.Bson.Serialization.Serializers;
using MongoDB.Bson.Serialization;
using MongoDB.Bson.Serialization.Conventions;
using MongoDB.Driver;

namespace Locker.Backend.Infrastructure.Mongo;

public class MongoContext
{
    static MongoContext()
    {
        var pack = new ConventionPack
        {
            new CamelCaseElementNameConvention(),
            new IgnoreExtraElementsConvention(true)
        };
        ConventionRegistry.Register("CamelCaseIgnoreExtra", pack, _ => true);

        #pragma warning disable CS0618
        BsonSerializer.RegisterSerializer(new GuidSerializer(GuidRepresentation.Standard));
        #pragma warning restore CS0618

        if (!BsonClassMap.IsClassMapRegistered(typeof(BaseEntity)))
        {
            BsonClassMap.RegisterClassMap<BaseEntity>(cm =>
            {
                cm.AutoMap();
                cm.MapIdProperty(x => x.Id);
            });
        }
    }

    public MongoContext(IOptions<MongoSettings> settings)
    {
        var mongoClient = new MongoClient(settings.Value.ConnectionString);
        Database = mongoClient.GetDatabase(settings.Value.DatabaseName);
        Settings = settings.Value;

        EnsureIndexes();
    }

    public IMongoDatabase Database { get; }
    public MongoSettings Settings { get; }

    private void EnsureIndexes()
    {
        Database.GetCollection<User>(Settings.UsersCollection).Indexes.CreateMany(new[]
        {
            new CreateIndexModel<User>(Builders<User>.IndexKeys.Ascending(x => x.Email), new CreateIndexOptions { Unique = true }),
            new CreateIndexModel<User>(Builders<User>.IndexKeys.Ascending(x => x.PhoneNumber))
        });

        Database.GetCollection<RefreshToken>(Settings.RefreshTokensCollection).Indexes.CreateMany(new[]
        {
            new CreateIndexModel<RefreshToken>(Builders<RefreshToken>.IndexKeys.Ascending(x => x.Token), new CreateIndexOptions { Unique = true }),
            new CreateIndexModel<RefreshToken>(Builders<RefreshToken>.IndexKeys.Ascending(x => x.UserId)),
            new CreateIndexModel<RefreshToken>(Builders<RefreshToken>.IndexKeys.Ascending(x => x.ExpiresAt), new CreateIndexOptions { ExpireAfter = TimeSpan.Zero })
        });

        Database.GetCollection<OtpCode>(Settings.OtpCodesCollection).Indexes.CreateMany(new[]
        {
            new CreateIndexModel<OtpCode>(Builders<OtpCode>.IndexKeys.Ascending(x => x.UserId).Ascending(x => x.Target).Ascending(x => x.ExpiresAt)),
            new CreateIndexModel<OtpCode>(Builders<OtpCode>.IndexKeys.Ascending(x => x.ExpiresAt), new CreateIndexOptions { ExpireAfter = TimeSpan.Zero })
        });

        Database.GetCollection<Order>(Settings.OrdersCollection).Indexes.CreateMany(new[]
        {
            new CreateIndexModel<Order>(Builders<Order>.IndexKeys.Ascending(x => x.LockerId).Ascending(x => x.SlotIndex).Ascending(x => x.Status)),
            new CreateIndexModel<Order>(Builders<Order>.IndexKeys.Ascending(x => x.UserId).Ascending(x => x.Status)),
            new CreateIndexModel<Order>(Builders<Order>.IndexKeys.Ascending(x => x.Status).Ascending(x => x.CreatedAt))
        });

        Database.GetCollection<Booking>(Settings.BookingsCollection).Indexes.CreateMany(new[]
        {
            new CreateIndexModel<Booking>(Builders<Booking>.IndexKeys.Ascending(x => x.UserId).Ascending(x => x.Status)),
            new CreateIndexModel<Booking>(Builders<Booking>.IndexKeys.Ascending(x => x.LockerId).Ascending(x => x.SlotIndex))
        });

        Database.GetCollection<WalletTransaction>(Settings.WalletTransactionsCollection).Indexes.CreateOne(
            new CreateIndexModel<WalletTransaction>(Builders<WalletTransaction>.IndexKeys.Ascending(x => x.UserId).Descending(x => x.CreatedAt)));

        Database.GetCollection<DeliveryRequest>(Settings.DeliveryRequestsCollection).Indexes.CreateMany(new[]
        {
            new CreateIndexModel<DeliveryRequest>(Builders<DeliveryRequest>.IndexKeys.Ascending(x => x.TrackingCode), new CreateIndexOptions { Unique = true }),
            new CreateIndexModel<DeliveryRequest>(Builders<DeliveryRequest>.IndexKeys.Ascending(x => x.UserId))
        });

        Database.GetCollection<SendReceiveOrder>(Settings.SendReceiveOrdersCollection).Indexes.CreateMany(new[]
        {
            new CreateIndexModel<SendReceiveOrder>(Builders<SendReceiveOrder>.IndexKeys.Ascending(x => x.SenderId)),
            new CreateIndexModel<SendReceiveOrder>(Builders<SendReceiveOrder>.IndexKeys.Ascending(x => x.ReceiverId))
        });

        Database.GetCollection<LockerEvent>(Settings.LockerEventsCollection).Indexes.CreateMany(new[]
        {
            new CreateIndexModel<LockerEvent>(Builders<LockerEvent>.IndexKeys.Ascending(x => x.LockerId).Ascending(x => x.SlotIndex)),
            new CreateIndexModel<LockerEvent>(Builders<LockerEvent>.IndexKeys.Ascending(x => x.CreatedAt))
        });
    }
}
