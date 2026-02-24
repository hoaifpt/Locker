using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Models;
using Locker.Backend.Domain.Entities;

namespace Locker.Backend.Application.Services;

public class UserService
{
    private readonly IUserRepository _userRepository;
    private readonly IPasswordHasher _passwordHasher;

    public UserService(IUserRepository userRepository, IPasswordHasher passwordHasher)
    {
        _userRepository = userRepository;
        _passwordHasher = passwordHasher;
    }

    public async Task<UserDto?> GetCurrentUserAsync(string userId, CancellationToken cancellationToken)
    {
        var user = await _userRepository.GetByIdAsync(userId, cancellationToken);
        return user == null ? null : MapToDto(user);
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
        return MapToDto(user);
    }

    public async Task<bool> ChangePasswordAsync(string userId, ChangePasswordRequest request, CancellationToken cancellationToken)
    {
        var user = await _userRepository.GetByIdAsync(userId, cancellationToken);
        if (user == null)
            return false;

        if (!_passwordHasher.Verify(request.CurrentPassword, user.PasswordHash))
            return false;

        user.PasswordHash = _passwordHasher.Hash(request.NewPassword);
        await _userRepository.UpdateAsync(user, cancellationToken);
        return true;
    }

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
}
