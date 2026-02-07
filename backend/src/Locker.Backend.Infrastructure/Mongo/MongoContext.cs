using Microsoft.Extensions.Options;
using MongoDB.Driver;

namespace Locker.Backend.Infrastructure.Mongo;

public class MongoContext
{
    public MongoContext(IOptions<MongoSettings> settings)
    {
        var mongoClient = new MongoClient(settings.Value.ConnectionString);
        Database = mongoClient.GetDatabase(settings.Value.DatabaseName);
        Settings = settings.Value;
    }

    public IMongoDatabase Database { get; }
    public MongoSettings Settings { get; }
}
