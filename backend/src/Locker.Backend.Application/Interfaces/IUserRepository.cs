using Locker.Backend.Domain.Entities;

namespace Locker.Backend.Application.Interfaces;

public interface IUserRepository
{
    Task<User?> GetByUsernameAsync(string username, CancellationToken cancellationToken);
    Task<User?> GetByIdAsync(string id, CancellationToken cancellationToken);
    Task<User?> GetByEmailAsync(string email, CancellationToken cancellationToken);
<<<<<<< HEAD
    Task<User?> GetByPhoneNumberAsync(string phoneNumber, CancellationToken cancellationToken);
    Task<User?> GetByVerificationTokenAsync(string token, CancellationToken cancellationToken);
=======
>>>>>>> cd41969f38b41cd3f098ee3ee44d55472bf88075
    Task<List<User>> GetAllAsync(CancellationToken cancellationToken);
    Task CreateAsync(User user, CancellationToken cancellationToken);
    Task UpdateAsync(User user, CancellationToken cancellationToken);
}
