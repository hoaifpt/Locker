using Locker.Backend.Application.Interfaces;
<<<<<<< HEAD
using Locker.Backend.Application.Mapping;
using Locker.Backend.Application.Models;
=======
using Locker.Backend.Application.Models;
using Locker.Backend.Domain.Entities;
>>>>>>> cd41969f38b41cd3f098ee3ee44d55472bf88075

namespace Locker.Backend.Application.Services;

public class UserService
{
    private readonly IUserRepository _userRepository;
    private readonly IPasswordHasher _passwordHasher;
<<<<<<< HEAD
    private readonly UserMapper _userMapper;

    public UserService(IUserRepository userRepository, IPasswordHasher passwordHasher, UserMapper userMapper)
    {
        _userRepository = userRepository;
        _passwordHasher = passwordHasher;
        _userMapper = userMapper;
=======

    public UserService(IUserRepository userRepository, IPasswordHasher passwordHasher)
    {
        _userRepository = userRepository;
        _passwordHasher = passwordHasher;
>>>>>>> cd41969f38b41cd3f098ee3ee44d55472bf88075
    }

    public async Task<UserDto?> GetCurrentUserAsync(string userId, CancellationToken cancellationToken)
    {
        var user = await _userRepository.GetByIdAsync(userId, cancellationToken);
<<<<<<< HEAD
        return user == null ? null : _userMapper.Map(user);
=======
        return user == null ? null : MapToDto(user);
>>>>>>> cd41969f38b41cd3f098ee3ee44d55472bf88075
    }

    public async Task<UserDto?> UpdateProfileAsync(string userId, UpdateProfileRequest request, CancellationToken cancellationToken)
    {
        var user = await _userRepository.GetByIdAsync(userId, cancellationToken);
        if (user == null)
            return null;

        if (request.Email != null)
            user.Email = request.Email;

        if (request.FullName != null)
            user.FullName = request.FullName;

        await _userRepository.UpdateAsync(user, cancellationToken);
<<<<<<< HEAD
        return _userMapper.Map(user);
=======
        return MapToDto(user);
>>>>>>> cd41969f38b41cd3f098ee3ee44d55472bf88075
    }

    public async Task<bool> ChangePasswordAsync(string userId, ChangePasswordRequest request, CancellationToken cancellationToken)
    {
        var user = await _userRepository.GetByIdAsync(userId, cancellationToken);
        if (user == null)
            return false;

<<<<<<< HEAD
        if (string.IsNullOrEmpty(user.PasswordHash))
            return false;

=======
>>>>>>> cd41969f38b41cd3f098ee3ee44d55472bf88075
        if (!_passwordHasher.Verify(request.CurrentPassword, user.PasswordHash))
            return false;

        user.PasswordHash = _passwordHasher.Hash(request.NewPassword);
        await _userRepository.UpdateAsync(user, cancellationToken);
        return true;
    }
<<<<<<< HEAD
=======

    private static UserDto MapToDto(User user) => new()
    {
        Id = user.Id,
        Username = user.Username,
        Email = user.Email,
        FullName = user.FullName,
        Role = user.Role,
        IsActive = user.IsActive,
        CreatedAt = user.CreatedAt
    };
>>>>>>> cd41969f38b41cd3f098ee3ee44d55472bf88075
}
