using Locker.Backend.Application.Interfaces;
using MediatR;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.Admin.Commands.UpdateUserRole;

public record UpdateUserRoleCommand(Guid UserId, string Role) : IRequest<bool>;

public class UpdateUserRoleCommandHandler : IRequestHandler<UpdateUserRoleCommand, bool>
{
    private readonly IIdentityService _identityService;

    public UpdateUserRoleCommandHandler(IIdentityService identityService)
    {
        _identityService = identityService;
    }

    public async Task<bool> Handle(UpdateUserRoleCommand request, CancellationToken cancellationToken)
    {
        var user = await _identityService.FindByIdAsync(request.UserId.ToString());
        if (user == null) return false;

        var currentRoles = await _identityService.GetRolesAsync(user);
        await _identityService.RemoveFromRolesAsync(user, currentRoles);
        await _identityService.AddToRoleAsync(user, request.Role);
        return true;
    }
}
