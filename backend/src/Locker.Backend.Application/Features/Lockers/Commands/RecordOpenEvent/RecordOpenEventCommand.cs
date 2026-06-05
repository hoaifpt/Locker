using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Models;
using MediatR;
using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.Lockers.Commands.RecordOpenEvent;

public record RecordOpenEventCommand(Guid LockerId, int SlotIndex, string SensorState) : IRequest<bool>;

public class RecordOpenEventCommandHandler : IRequestHandler<RecordOpenEventCommand, bool>
{
    private readonly ILockerRepository _lockerRepository;

    public RecordOpenEventCommandHandler(ILockerRepository lockerRepository)
    {
        _lockerRepository = lockerRepository;
    }

    public async Task<bool> Handle(RecordOpenEventCommand request, CancellationToken cancellationToken)
    {
        var locker = await _lockerRepository.GetByIdAsync(request.LockerId, cancellationToken);
        if (locker == null) return false;

        var slot = locker.Slots.FirstOrDefault(s => s.Index == request.SlotIndex);
        if (slot == null) return false;

        slot.SensorState = request.SensorState;
        await _lockerRepository.UpdateAsync(locker, cancellationToken);
        return true;
    }
}
