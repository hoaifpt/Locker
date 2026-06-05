using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Mapping;
using Locker.Backend.Application.Models;
using Locker.Backend.Domain.Entities;
using Microsoft.AspNetCore.Identity;
using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Services;

public class UserService
{
    private readonly IIdentityService _identityService;
    private readonly UserMapper _userMapper;

    public UserService(IIdentityService identityService, UserMapper userMapper)
    {
        _identityService = identityService;
        _userMapper = userMapper;
    }

    public async Task<UserDto?> GetCurrentUserAsync(Guid userId, CancellationToken cancellationToken)
    {
        var user = await _identityService.FindByIdAsync(userId.ToString());
        if (user == null) return null;

        var dto = _userMapper.Map(user);
        var roles = await _identityService.GetRolesAsync(user);
        dto.Role = roles.FirstOrDefault() ?? "User";
        
        return dto;
    }

    public async Task<UserDto?> UpdateProfileAsync(Guid userId, UpdateProfileRequest request, CancellationToken cancellationToken)
    {
        var user = await _identityService.FindByIdAsync(userId.ToString());
        if (user == null)
            return null;

        if (request.Email != null)
        {
            await _identityService.SetEmailAsync(user, request.Email);
        }

        if (request.FullName != null)
            user.FullName = request.FullName;

        await _identityService.UpdateUserAsync(user);
        
        var dto = _userMapper.Map(user);
        var roles = await _identityService.GetRolesAsync(user);
        dto.Role = roles.FirstOrDefault() ?? "User";
        
        return dto;
    }

    public async Task<bool> ChangePasswordAsync(Guid userId, ChangePasswordRequest request, CancellationToken cancellationToken)
    {
        var user = await _identityService.FindByIdAsync(userId.ToString());
        if (user == null)
            return false;

        var result = await _identityService.ChangePasswordAsync(user, request.CurrentPassword, request.NewPassword);
        return result.Success;
    }
}
