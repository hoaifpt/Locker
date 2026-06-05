using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Mapping;
using Locker.Backend.Application.Models;
using Locker.Backend.Domain.Enums;
using MediatR;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.Lockers.Queries.GetAvailableLockers;

public record GetAvailableLockersQuery() : IRequest<List<LockerDto>>;

public class GetAvailableLockersQueryHandler : IRequestHandler<GetAvailableLockersQuery, List<LockerDto>>
{
    private readonly ILockerRepository _lockerRepository;
    private readonly LockerMapper _lockerMapper;

    public GetAvailableLockersQueryHandler(ILockerRepository lockerRepository, LockerMapper lockerMapper)
    {
        _lockerRepository = lockerRepository;
        _lockerMapper = lockerMapper;
    }

    public async Task<List<LockerDto>> Handle(GetAvailableLockersQuery request, CancellationToken cancellationToken)
    {
        var lockers = await _lockerRepository.GetAllAsync(cancellationToken);
        var available = lockers.Where(l => l.Slots.Any(s => s.Status == LockerSlotStatus.Available)).ToList();
        return available.Select(_lockerMapper.Map).ToList();
    }
}
