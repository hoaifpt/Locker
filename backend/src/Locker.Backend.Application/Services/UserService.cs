using Locker.Backend.Application.Mapping;
using Locker.Backend.Application.Models;
using Locker.Backend.Domain.Entities;
using Microsoft.AspNetCore.Identity;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Services;

public class UserService
{
    private readonly UserManager<User> _userManager;
    private readonly UserMapper _userMapper;

    public UserService(UserManager<User> userManager, UserMapper userMapper)
    {
        _userManager = userManager;
        _userMapper = userMapper;
    }

    public async Task<UserDto?> GetCurrentUserAsync(Guid userId, CancellationToken cancellationToken)
    {
        var user = await _userManager.FindByIdAsync(userId.ToString());
        if (user == null) return null;

        var dto = _userMapper.Map(user);
        var roles = await _userManager.GetRolesAsync(user);
        dto.Role = roles.FirstOrDefault() ?? "User";
        
        return dto;
    }

    public async Task<UserDto?> UpdateProfileAsync(Guid userId, UpdateProfileRequest request, CancellationToken cancellationToken)
    {
        var user = await _userManager.FindByIdAsync(userId.ToString());
        if (user == null)
            return null;

        if (request.Email != null)
        {
            await _userManager.SetEmailAsync(user, request.Email);
        }

        if (request.FullName != null)
            user.FullName = request.FullName;

        await _userManager.UpdateAsync(user);
        
        var dto = _userMapper.Map(user);
        var roles = await _userManager.GetRolesAsync(user);
        dto.Role = roles.FirstOrDefault() ?? "User";
        
        return dto;
    }

    public async Task<bool> ChangePasswordAsync(Guid userId, ChangePasswordRequest request, CancellationToken cancellationToken)
    {
        var user = await _userManager.FindByIdAsync(userId.ToString());
        if (user == null)
            return false;

        var result = await _userManager.ChangePasswordAsync(user, request.CurrentPassword, request.NewPassword);
        return result.Succeeded;
    }
}
