using Locker.Backend.Application.Interfaces;
using Locker.Backend.Domain.Enums;
using MediatR;
using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.Bookings.Commands.CancelBooking;

public record CancelBookingCommand(Guid BookingId, Guid UserId) : IRequest<bool>;

public class CancelBookingCommandHandler : IRequestHandler<CancelBookingCommand, bool>
{
    private readonly IBookingRepository _bookingRepository;
    private readonly ILockerRepository _lockerRepository;

    public CancelBookingCommandHandler(IBookingRepository bookingRepository, ILockerRepository lockerRepository)
    {
        _bookingRepository = bookingRepository;
        _lockerRepository = lockerRepository;
    }

    public async Task<bool> Handle(CancelBookingCommand request, CancellationToken cancellationToken)
    {
        var booking = await _bookingRepository.GetByIdAsync(request.BookingId, cancellationToken);
        if (booking == null || booking.UserId != request.UserId) return false;
        if (booking.Status == BookingStatus.Completed) return false;

        var locker = await _lockerRepository.GetByIdAsync(booking.LockerId, cancellationToken);
        if (locker != null)
        {
            var slot = locker.Slots.FirstOrDefault(s => s.Index == booking.SlotIndex);
            if (slot != null)
            {
                slot.Status = LockerSlotStatus.Available;
                slot.BookingId = null;
            }
            await _lockerRepository.UpdateAsync(locker, cancellationToken);
        }

        booking.Status = BookingStatus.Canceled;
        await _bookingRepository.UpdateAsync(booking, cancellationToken);
        return true;
    }
}
