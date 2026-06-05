using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Mapping;
using Locker.Backend.Application.Models;
using MediatR;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.Lockers.Queries.GetAllLockers;

public record GetAllLockersQuery() : IRequest<List<LockerDto>>;

public class GetAllLockersQueryHandler : IRequestHandler<GetAllLockersQuery, List<LockerDto>>
{
    private readonly ILockerRepository _lockerRepository;
    private readonly LockerMapper _lockerMapper;

    public GetAllLockersQueryHandler(ILockerRepository lockerRepository, LockerMapper lockerMapper)
    {
        _lockerRepository = lockerRepository;
        _lockerMapper = lockerMapper;
    }

    public async Task<List<LockerDto>> Handle(GetAllLockersQuery request, CancellationToken cancellationToken)
    {
        var lockers = await _lockerRepository.GetAllAsync(cancellationToken);
        return lockers.Select(_lockerMapper.Map).ToList();
    }
}
