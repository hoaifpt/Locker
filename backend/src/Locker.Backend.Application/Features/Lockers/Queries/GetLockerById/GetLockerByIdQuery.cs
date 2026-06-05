using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Mapping;
using Locker.Backend.Application.Models;
using MediatR;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.Lockers.Queries.GetLockerById;

public record GetLockerByIdQuery(Guid Id) : IRequest<LockerDto?>;

public class GetLockerByIdQueryHandler : IRequestHandler<GetLockerByIdQuery, LockerDto?>
{
    private readonly ILockerRepository _lockerRepository;
    private readonly LockerMapper _lockerMapper;

    public GetLockerByIdQueryHandler(ILockerRepository lockerRepository, LockerMapper lockerMapper)
    {
        _lockerRepository = lockerRepository;
        _lockerMapper = lockerMapper;
    }

    public async Task<LockerDto?> Handle(GetLockerByIdQuery request, CancellationToken cancellationToken)
    {
        var locker = await _lockerRepository.GetByIdAsync(request.Id, cancellationToken);
        return locker == null ? null : _lockerMapper.Map(locker);
    }
}
