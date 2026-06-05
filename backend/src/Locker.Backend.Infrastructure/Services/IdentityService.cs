using Locker.Backend.Application.Interfaces;
using Locker.Backend.Domain.Entities;
using Microsoft.AspNetCore.Identity;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Locker.Backend.Infrastructure.Services;

public class IdentityService : IIdentityService
{
    private readonly UserManager<User> _userManager;

    public IdentityService(UserManager<User> userManager)
    {
        _userManager = userManager;
    }

    public async Task<User?> FindByIdAsync(string userId) => await _userManager.FindByIdAsync(userId);
    public async Task<User?> FindByEmailAsync(string email) => await _userManager.FindByEmailAsync(email);
    public async Task<User?> FindByNameAsync(string userName) => await _userManager.FindByNameAsync(userName);
    public Task<User?> FindByPhoneNumberAsync(string phoneNumber) => Task.FromResult(_userManager.Users.FirstOrDefault(u => u.PhoneNumber == phoneNumber));
    public Task<User?> FindByEmailVerificationTokenAsync(string token) => Task.FromResult(_userManager.Users.FirstOrDefault(u => u.EmailVerificationToken == token));
    
    public Task<List<User>> GetAllUsersAsync() => Task.FromResult(_userManager.Users.ToList());
    
    public async Task<bool> IsEmailConfirmedAsync(User user) => await _userManager.IsEmailConfirmedAsync(user);
    public async Task<bool> IsLockedOutAsync(User user) => await _userManager.IsLockedOutAsync(user);
    public async Task<bool> CheckPasswordAsync(User user, string password) => await _userManager.CheckPasswordAsync(user, password);
    
    public async Task AccessFailedAsync(User user) => await _userManager.AccessFailedAsync(user);
    public async Task ResetAccessFailedCountAsync(User user) => await _userManager.ResetAccessFailedCountAsync(user);
    
    public async Task<(bool Success, IEnumerable<string> Errors)> CreateUserAsync(User user, string password)
    {
        var result = await _userManager.CreateAsync(user, password);
        return (result.Succeeded, result.Errors.Select(e => e.Description));
    }
    
    public async Task UpdateUserAsync(User user) => await _userManager.UpdateAsync(user);
    
    public async Task AddToRoleAsync(User user, string role) => await _userManager.AddToRoleAsync(user, role);
    public async Task<IList<string>> GetRolesAsync(User user) => await _userManager.GetRolesAsync(user);
    public async Task RemoveFromRolesAsync(User user, IEnumerable<string> roles) => await _userManager.RemoveFromRolesAsync(user, roles);
    
    public async Task<string> GeneratePasswordResetTokenAsync(User user) => await _userManager.GeneratePasswordResetTokenAsync(user);
    public async Task<(bool Success, IEnumerable<string> Errors)> ResetPasswordAsync(User user, string token, string newPassword)
    {
        var result = await _userManager.ResetPasswordAsync(user, token, newPassword);
        return (result.Succeeded, result.Errors.Select(e => e.Description));
    }
    
    public async Task SetEmailAsync(User user, string email) => await _userManager.SetEmailAsync(user, email);
    public async Task<(bool Success, IEnumerable<string> Errors)> ChangePasswordAsync(User user, string currentPassword, string newPassword)
    {
        var result = await _userManager.ChangePasswordAsync(user, currentPassword, newPassword);
        return (result.Succeeded, result.Errors.Select(e => e.Description));
    }
}
