using Locker.Backend.Application.Interfaces;
using MediatR;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.Admin.Commands.DeactivateUser;

public record DeactivateUserCommand(Guid UserId) : IRequest<bool>;

public class DeactivateUserCommandHandler : IRequestHandler<DeactivateUserCommand, bool>
{
    private readonly IIdentityService _identityService;

    public DeactivateUserCommandHandler(IIdentityService identityService)
    {
        _identityService = identityService;
    }

    public async Task<bool> Handle(DeactivateUserCommand request, CancellationToken cancellationToken)
    {
        var user = await _identityService.FindByIdAsync(request.UserId.ToString());
        if (user == null) return false;

        user.IsActive = false;
        await _identityService.UpdateUserAsync(user);
        return true;
    }
}
