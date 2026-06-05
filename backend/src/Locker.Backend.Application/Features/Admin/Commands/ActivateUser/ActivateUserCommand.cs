using Locker.Backend.Application.Interfaces;
using MediatR;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.Admin.Commands.ActivateUser;

public record ActivateUserCommand(Guid UserId) : IRequest<bool>;

public class ActivateUserCommandHandler : IRequestHandler<ActivateUserCommand, bool>
{
    private readonly IIdentityService _identityService;

    public ActivateUserCommandHandler(IIdentityService identityService)
    {
        _identityService = identityService;
    }

    public async Task<bool> Handle(ActivateUserCommand request, CancellationToken cancellationToken)
    {
        var user = await _identityService.FindByIdAsync(request.UserId.ToString());
        if (user == null) return false;

        user.IsActive = true;
        await _identityService.UpdateUserAsync(user);
        return true;
    }
}
