using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Models;
using MediatR;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.Lockers.Queries.GetLockerMap;

public record GetLockerMapQuery() : IRequest<List<LockerMapSlotDto>>;

public class GetLockerMapQueryHandler : IRequestHandler<GetLockerMapQuery, List<LockerMapSlotDto>>
{
    private readonly ILockerRepository _lockerRepository;

    public GetLockerMapQueryHandler(ILockerRepository lockerRepository)
    {
        _lockerRepository = lockerRepository;
    }

    public async Task<List<LockerMapSlotDto>> Handle(GetLockerMapQuery request, CancellationToken cancellationToken)
    {
        var lockers = await _lockerRepository.GetAllAsync(cancellationToken);
        var results = new List<LockerMapSlotDto>();

        foreach (var locker in lockers)
        {
            foreach (var slot in locker.Slots)
            {
                results.Add(new LockerMapSlotDto
                {
                    LockerId = locker.Id,
                    SlotIndex = slot.Index,
                    Size = slot.Size,
                    Status = slot.Status,
                    SensorState = slot.SensorState,
                    HubLocation = locker.Location
                });
            }
        }

        return results;
    }
}
