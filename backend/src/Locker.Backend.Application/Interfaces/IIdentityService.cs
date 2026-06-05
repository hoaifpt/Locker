using Locker.Backend.Domain.Entities;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Interfaces;

public interface IIdentityService
{
    Task<User?> FindByIdAsync(string userId);
    Task<User?> FindByEmailAsync(string email);
    Task<User?> FindByNameAsync(string userName);
    Task<User?> FindByPhoneNumberAsync(string phoneNumber);
    Task<User?> FindByEmailVerificationTokenAsync(string token);
    
    Task<List<User>> GetAllUsersAsync();
    
    Task<bool> IsEmailConfirmedAsync(User user);
    Task<bool> IsLockedOutAsync(User user);
    Task<bool> CheckPasswordAsync(User user, string password);
    
    Task AccessFailedAsync(User user);
    Task ResetAccessFailedCountAsync(User user);
    
    Task<(bool Success, IEnumerable<string> Errors)> CreateUserAsync(User user, string password);
    Task UpdateUserAsync(User user);
    
    Task AddToRoleAsync(User user, string role);
    Task<IList<string>> GetRolesAsync(User user);
    Task RemoveFromRolesAsync(User user, IEnumerable<string> roles);
    
    Task<string> GeneratePasswordResetTokenAsync(User user);
    Task<(bool Success, IEnumerable<string> Errors)> ResetPasswordAsync(User user, string token, string newPassword);
    
    Task SetEmailAsync(User user, string email);
    Task<(bool Success, IEnumerable<string> Errors)> ChangePasswordAsync(User user, string currentPassword, string newPassword);
}
