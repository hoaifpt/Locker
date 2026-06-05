using Locker.Backend.Application.Interfaces;
using Locker.Backend.Domain.Enums;
using MediatR;
using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.Bookings.Commands.CompleteBooking;

public record CompleteBookingCommand(Guid BookingId, Guid UserId) : IRequest<bool>;

public class CompleteBookingCommandHandler : IRequestHandler<CompleteBookingCommand, bool>
{
    private readonly IBookingRepository _bookingRepository;
    private readonly ILockerRepository _lockerRepository;

    public CompleteBookingCommandHandler(IBookingRepository bookingRepository, ILockerRepository lockerRepository)
    {
        _bookingRepository = bookingRepository;
        _lockerRepository = lockerRepository;
    }

    public async Task<bool> Handle(CompleteBookingCommand request, CancellationToken cancellationToken)
    {
        var booking = await _bookingRepository.GetByIdAsync(request.BookingId, cancellationToken);
        if (booking == null || booking.UserId != request.UserId) return false;
        if (booking.Status != BookingStatus.Active) return false;

        var locker = await _lockerRepository.GetByIdAsync(booking.LockerId, cancellationToken);
        if (locker == null) return false;

        booking.Status = BookingStatus.Completed;
        booking.CompletedAt = DateTime.UtcNow;

        var slot = locker.Slots.FirstOrDefault(s => s.Index == booking.SlotIndex);
        if (slot != null)
        {
            slot.Status = LockerSlotStatus.Available;
            slot.BookingId = null;
        }

        await _bookingRepository.UpdateAsync(booking, cancellationToken);
        await _lockerRepository.UpdateAsync(locker, cancellationToken);
        return true;
    }
}
