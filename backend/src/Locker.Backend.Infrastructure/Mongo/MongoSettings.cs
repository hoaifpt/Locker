namespace Locker.Backend.Infrastructure.Mongo;

public class MongoSettings
{
    public string ConnectionString { get; set; } = "mongodb://localhost:27017";
    public string DatabaseName { get; set; } = "locker";
    public string UsersCollection { get; set; } = "users";
    public string LockersCollection { get; set; } = "lockers";
}
