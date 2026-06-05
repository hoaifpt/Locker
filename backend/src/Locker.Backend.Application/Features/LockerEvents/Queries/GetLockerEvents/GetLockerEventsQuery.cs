using Locker.Backend.Application.Interfaces;
using Locker.Backend.Domain.Entities;
using MediatR;
using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.LockerEvents.Queries.GetLockerEvents;

public record GetLockerEventsQuery(Guid LockerId, int? SlotIndex) : IRequest<List<LockerEvent>>;

public class GetLockerEventsQueryHandler : IRequestHandler<GetLockerEventsQuery, List<LockerEvent>>
{
    private readonly ILockerEventRepository _repository;

    public GetLockerEventsQueryHandler(ILockerEventRepository repository)
    {
        _repository = repository;
    }

    public async Task<List<LockerEvent>> Handle(GetLockerEventsQuery request, CancellationToken cancellationToken)
    {
        if (request.SlotIndex.HasValue)
        {
            return await _repository.GetByLockerAndSlotAsync(request.LockerId, request.SlotIndex.Value, cancellationToken);
        }
        return await _repository.GetByLockerIdAsync(request.LockerId, cancellationToken);
    }
}
