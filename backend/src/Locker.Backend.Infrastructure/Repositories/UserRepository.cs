using Locker.Backend.Application.Interfaces;
using Locker.Backend.Domain.Entities;
using Locker.Backend.Infrastructure.Mongo;
using MongoDB.Driver;

namespace Locker.Backend.Infrastructure.Repositories;

public class UserRepository : IUserRepository
{
    private readonly IMongoCollection<User> _collection;

    public UserRepository(MongoContext context)
    {
        _collection = context.Database.GetCollection<User>(context.Settings.UsersCollection);
    }

    public async Task<User?> GetByUsernameAsync(string username, CancellationToken cancellationToken)
    {
        var cursor = await _collection.FindAsync(u => u.Username == username, cancellationToken: cancellationToken);
        return await cursor.FirstOrDefaultAsync(cancellationToken);
    }

    public async Task<User?> GetByIdAsync(string id, CancellationToken cancellationToken)
    {
        var cursor = await _collection.FindAsync(u => u.Id == id, cancellationToken: cancellationToken);
        return await cursor.FirstOrDefaultAsync(cancellationToken);
    }

    public Task CreateAsync(User user, CancellationToken cancellationToken)
    {
        return _collection.InsertOneAsync(user, cancellationToken: cancellationToken);
    }
}
