using Locker.Backend.Application.Interfaces;
using MediatR;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.Lockers.Commands.DeleteLocker;

public record DeleteLockerCommand(Guid Id) : IRequest<bool>;

public class DeleteLockerCommandHandler : IRequestHandler<DeleteLockerCommand, bool>
{
    private readonly ILockerRepository _lockerRepository;

    public DeleteLockerCommandHandler(ILockerRepository lockerRepository)
    {
        _lockerRepository = lockerRepository;
    }

    public async Task<bool> Handle(DeleteLockerCommand request, CancellationToken cancellationToken)
    {
        return await _lockerRepository.SoftDeleteAsync(request.Id, cancellationToken);
    }
}
