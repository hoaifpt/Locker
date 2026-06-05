using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Mapping;
using Locker.Backend.Application.Models;
using MediatR;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.Admin.Queries.GetAllUsers;

public record GetAllUsersQuery() : IRequest<List<UserDto>>;

public class GetAllUsersQueryHandler : IRequestHandler<GetAllUsersQuery, List<UserDto>>
{
    private readonly IIdentityService _identityService;
    private readonly UserMapper _userMapper;

    public GetAllUsersQueryHandler(IIdentityService identityService, UserMapper userMapper)
    {
        _identityService = identityService;
        _userMapper = userMapper;
    }

    public async Task<List<UserDto>> Handle(GetAllUsersQuery request, CancellationToken cancellationToken)
    {
        var users = await _identityService.GetAllUsersAsync();
        var dtos = new List<UserDto>();
        foreach (var user in users)
        {
            var dto = _userMapper.Map(user);
            var roles = await _identityService.GetRolesAsync(user);
            dto.Role = roles.FirstOrDefault() ?? "User";
            dtos.Add(dto);
        }
        return dtos;
    }
}
