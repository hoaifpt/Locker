using Locker.Backend.Domain.Entities;
using Microsoft.Extensions.Options;
using MongoDB.Bson;
using MongoDB.Bson.Serialization;
using MongoDB.Bson.Serialization.Conventions;
using MongoDB.Bson.Serialization.IdGenerators;
using MongoDB.Bson.Serialization.Serializers;
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

        BsonClassMap.RegisterClassMap<BaseEntity>(cm =>
        {
            cm.AutoMap();
            cm.MapIdProperty(x => x.Id)
              .SetSerializer(new StringSerializer(BsonType.ObjectId))
              .SetIdGenerator(StringObjectIdGenerator.Instance);
        });
    }

    public MongoContext(IOptions<MongoSettings> settings)
    {
        var mongoClient = new MongoClient(settings.Value.ConnectionString);
        Database = mongoClient.GetDatabase(settings.Value.DatabaseName);
        Settings = settings.Value;
    }

    public IMongoDatabase Database { get; }
    public MongoSettings Settings { get; }
}
