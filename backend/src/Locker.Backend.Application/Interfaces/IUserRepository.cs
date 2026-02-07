using Locker.Backend.Domain.Entities;

namespace Locker.Backend.Application.Interfaces;

public interface IUserRepository
{
    Task<User?> GetByUsernameAsync(string username, CancellationToken cancellationToken);
    Task<User?> GetByIdAsync(string id, CancellationToken cancellationToken);
    Task CreateAsync(User user, CancellationToken cancellationToken);
}
