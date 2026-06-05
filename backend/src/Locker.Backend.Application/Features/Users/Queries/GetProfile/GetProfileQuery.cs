using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Mapping;
using Locker.Backend.Application.Models;
using MediatR;
using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.Users.Queries.GetProfile;

public record GetProfileQuery(Guid UserId) : IRequest<UserDto?>;

public class GetProfileQueryHandler : IRequestHandler<GetProfileQuery, UserDto?>
{
    private readonly IIdentityService _identityService;
    private readonly UserMapper _userMapper;

    public GetProfileQueryHandler(IIdentityService identityService, UserMapper userMapper)
    {
        _identityService = identityService;
        _userMapper = userMapper;
    }

    public async Task<UserDto?> Handle(GetProfileQuery request, CancellationToken cancellationToken)
    {
        var user = await _identityService.FindByIdAsync(request.UserId.ToString());
        if (user == null) return null;

        var dto = _userMapper.Map(user);
        var roles = await _identityService.GetRolesAsync(user);
        dto.Role = roles.FirstOrDefault() ?? "User";
        
        return dto;
    }
}
