using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Mapping;
using Locker.Backend.Application.Models;
using Locker.Backend.Domain.Entities;
using MediatR;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using LockerEntity = Locker.Backend.Domain.Entities.Locker;

namespace Locker.Backend.Application.Features.Lockers.Commands.CreateLocker;

public record CreateLockerCommand(string Name, string Location, double Latitude, double Longitude, int Slots) : IRequest<LockerDto>;

public class CreateLockerCommandHandler : IRequestHandler<CreateLockerCommand, LockerDto>
{
    private readonly ILockerRepository _lockerRepository;
    private readonly LockerMapper _lockerMapper;

    public CreateLockerCommandHandler(ILockerRepository lockerRepository, LockerMapper lockerMapper)
    {
        _lockerRepository = lockerRepository;
        _lockerMapper = lockerMapper;
    }

    public async Task<LockerDto> Handle(CreateLockerCommand request, CancellationToken cancellationToken)
    {
        var locker = new LockerEntity
        {
            Name = request.Name,
            Location = request.Location,
            Latitude = request.Latitude,
            Longitude = request.Longitude,
            Slots = Enumerable.Range(1, request.Slots)
                .Select(index => new LockerSlot { Index = index })
                .ToList()
        };

        await _lockerRepository.CreateAsync(locker, cancellationToken);
        return _lockerMapper.Map(locker);
    }
}
