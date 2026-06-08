using Locker.Backend.Application.Interfaces;
using Locker.Backend.Domain.Enums;
using MediatR;
using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.Bookings.Commands.SetPin;

public record SetPinCommand(Guid BookingId, Guid UserId, string Pin) : IRequest<bool>;

public class SetPinCommandHandler : IRequestHandler<SetPinCommand, bool>
{
    private readonly IBookingRepository _bookingRepository;
    private readonly IPaymentRepository _paymentRepository;
    private readonly ILockerRepository _lockerRepository;
    private readonly IPasswordHasher _passwordHasher;

    public SetPinCommandHandler(
        IBookingRepository bookingRepository,
        IPaymentRepository paymentRepository,
        ILockerRepository lockerRepository,
        IPasswordHasher passwordHasher)
    {
        _bookingRepository = bookingRepository;
        _paymentRepository = paymentRepository;
        _lockerRepository = lockerRepository;
        _passwordHasher = passwordHasher;
    }

    public async Task<bool> Handle(SetPinCommand request, CancellationToken cancellationToken)
    {
        var booking = await _bookingRepository.GetByIdAsync(request.BookingId, cancellationToken);
        if (booking == null || booking.UserId != request.UserId) return false;
        if (booking.Status != BookingStatus.Pending) return false;

        // Payment must be completed before setting PIN
        if (booking.PaymentId == null)
            return false;

        var payment = await _paymentRepository.GetByBookingIdAsync(request.BookingId, cancellationToken);
        if (payment == null || payment.Status != PaymentStatus.Completed)
            return false;

        var locker = await _lockerRepository.GetByIdAsync(booking.LockerId, cancellationToken);
        if (locker == null) return false;

        booking.PinHash = _passwordHasher.Hash(request.Pin);
        booking.Status = BookingStatus.Active;
        booking.StartedAt = DateTime.UtcNow;

        var slot = locker.Slots.FirstOrDefault(s => s.Index == booking.SlotIndex);
        if (slot != null)
            slot.Status = LockerSlotStatus.Active;

        await _bookingRepository.UpdateAsync(booking, cancellationToken);
        await _lockerRepository.UpdateAsync(locker, cancellationToken);
        return true;
    }
}
