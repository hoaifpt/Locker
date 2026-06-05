using Locker.Backend.Application.Interfaces;
using MediatR;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.Lockers.Commands.UpdateLocker;

public record UpdateLockerCommand(Guid Id, string Name, string Location, double Latitude, double Longitude) : IRequest<bool>;

public class UpdateLockerCommandHandler : IRequestHandler<UpdateLockerCommand, bool>
{
    private readonly ILockerRepository _lockerRepository;

    public UpdateLockerCommandHandler(ILockerRepository lockerRepository)
    {
        _lockerRepository = lockerRepository;
    }

    public async Task<bool> Handle(UpdateLockerCommand request, CancellationToken cancellationToken)
    {
        var locker = await _lockerRepository.GetByIdAsync(request.Id, cancellationToken);
        if (locker == null) return false;

        locker.Name = request.Name;
        locker.Location = request.Location;
        locker.Latitude = request.Latitude;
        locker.Longitude = request.Longitude;
        await _lockerRepository.UpdateAsync(locker, cancellationToken);
        return true;
    }
}
