using Locker.Backend.Application.Interfaces;
using MediatR;
using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.Lockers.Commands.OpenLockerSlot;

public record OpenLockerSlotCommand(Guid LockerId, int SlotIndex, Guid? UserId, bool IsPrivileged) : IRequest<OpenLockerResult>;

public class OpenLockerSlotCommandHandler : IRequestHandler<OpenLockerSlotCommand, OpenLockerResult>
{
    private readonly ILockerRepository _lockerRepository;
    private readonly IBookingRepository _bookingRepository;
    private readonly IOrderRepository _orderRepository;

    public OpenLockerSlotCommandHandler(ILockerRepository lockerRepository, IBookingRepository bookingRepository, IOrderRepository orderRepository)
    {
        _lockerRepository = lockerRepository;
        _bookingRepository = bookingRepository;
        _orderRepository = orderRepository;
    }

    public async Task<OpenLockerResult> Handle(OpenLockerSlotCommand request, CancellationToken cancellationToken)
    {
        var locker = await _lockerRepository.GetByIdAsync(request.LockerId, cancellationToken);
        if (locker == null) return OpenLockerResult.NotFound;

        var slot = locker.Slots.FirstOrDefault(s => s.Index == request.SlotIndex);
        if (slot == null) return OpenLockerResult.NotFound;

        if (!request.IsPrivileged)
        {
            if (request.UserId == null || request.UserId == Guid.Empty) return OpenLockerResult.Forbidden;

            var booking = await _bookingRepository.GetActiveBySlotAsync(request.LockerId, request.SlotIndex, cancellationToken);
            var order = await _orderRepository.GetActiveBySlotAsync(request.LockerId, request.SlotIndex, cancellationToken);

            var allowed = (booking != null && booking.UserId == request.UserId) ||
                          (order != null && order.UserId == request.UserId);

            if (!allowed) return OpenLockerResult.Forbidden;
        }

        slot.SensorState = "Open";
        await _lockerRepository.UpdateAsync(locker, cancellationToken);
        return OpenLockerResult.Success;
    }
}

public enum OpenLockerResult
{
    Success,
    Forbidden,
    NotFound
}
