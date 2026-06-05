using Locker.Backend.Application.Interfaces;
using Locker.Backend.Domain.Enums;
using MediatR;
using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.Lockers.Commands.UpdateSlotStatus;

public record UpdateSlotStatusCommand(Guid LockerId, int SlotIndex, LockerSlotStatus Status) : IRequest<bool>;

public class UpdateSlotStatusCommandHandler : IRequestHandler<UpdateSlotStatusCommand, bool>
{
    private readonly ILockerRepository _lockerRepository;

    public UpdateSlotStatusCommandHandler(ILockerRepository lockerRepository)
    {
        _lockerRepository = lockerRepository;
    }

    public async Task<bool> Handle(UpdateSlotStatusCommand request, CancellationToken cancellationToken)
    {
        var locker = await _lockerRepository.GetByIdAsync(request.LockerId, cancellationToken);
        if (locker == null) return false;

        var slot = locker.Slots.FirstOrDefault(s => s.Index == request.SlotIndex);
        if (slot == null) return false;

        slot.Status = request.Status;
        await _lockerRepository.UpdateAsync(locker, cancellationToken);
        return true;
    }
}
