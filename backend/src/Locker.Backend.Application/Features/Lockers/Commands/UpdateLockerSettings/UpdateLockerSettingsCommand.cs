using Locker.Backend.Application.Interfaces;
using MediatR;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.Lockers.Commands.UpdateLockerSettings;

public record UpdateLockerSettingsCommand(Guid LockerId, bool? IsAutoLockEnabled, bool? IsIntrusionAlertEnabled) : IRequest<bool>;

public class UpdateLockerSettingsCommandHandler : IRequestHandler<UpdateLockerSettingsCommand, bool>
{
    private readonly ILockerRepository _lockerRepository;

    public UpdateLockerSettingsCommandHandler(ILockerRepository lockerRepository)
    {
        _lockerRepository = lockerRepository;
    }

    public async Task<bool> Handle(UpdateLockerSettingsCommand request, CancellationToken cancellationToken)
    {
        var locker = await _lockerRepository.GetByIdAsync(request.LockerId, cancellationToken);
        if (locker == null) return false;

        if (request.IsAutoLockEnabled.HasValue)
            locker.IsAutoLockEnabled = request.IsAutoLockEnabled.Value;

        if (request.IsIntrusionAlertEnabled.HasValue)
            locker.IsIntrusionAlertEnabled = request.IsIntrusionAlertEnabled.Value;

        await _lockerRepository.UpdateAsync(locker, cancellationToken);
        return true;
    }
}
