using Locker.Backend.Application.Interfaces;
using MediatR;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.DeviceTokens.Commands.DeleteDeviceToken;

public record DeleteDeviceTokenCommand(Guid Id, Guid UserId) : IRequest<bool>;

public class DeleteDeviceTokenCommandHandler : IRequestHandler<DeleteDeviceTokenCommand, bool>
{
    private readonly IDeviceTokenRepository _repository;

    public DeleteDeviceTokenCommandHandler(IDeviceTokenRepository repository)
    {
        _repository = repository;
    }

    public async Task<bool> Handle(DeleteDeviceTokenCommand request, CancellationToken cancellationToken)
    {
        var token = await _repository.GetByIdAsync(request.Id, cancellationToken);
        if (token == null || token.UserId != request.UserId)
            return false;

        await _repository.DeleteAsync(request.Id, cancellationToken);
        return true;
    }
}
