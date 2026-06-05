using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Mapping;
using Locker.Backend.Application.Models;
using MediatR;
using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.Users.Commands.UpdateProfile;

public record UpdateProfileCommand(Guid UserId, string? Email, string? FullName) : IRequest<UserDto?>;

public class UpdateProfileCommandHandler : IRequestHandler<UpdateProfileCommand, UserDto?>
{
    private readonly IIdentityService _identityService;
    private readonly UserMapper _userMapper;

    public UpdateProfileCommandHandler(IIdentityService identityService, UserMapper userMapper)
    {
        _identityService = identityService;
        _userMapper = userMapper;
    }

    public async Task<UserDto?> Handle(UpdateProfileCommand request, CancellationToken cancellationToken)
    {
        var user = await _identityService.FindByIdAsync(request.UserId.ToString());
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
}
