using Locker.Backend.Application.Interfaces;
using Locker.Backend.Domain.Enums;
using MediatR;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.Bookings.Commands.VerifyPin;

public record VerifyPinCommand(Guid BookingId, string Pin) : IRequest<bool>;

public class VerifyPinCommandHandler : IRequestHandler<VerifyPinCommand, bool>
{
    private const int MaxPinAttempts = 5;
    private static readonly TimeSpan LockoutDuration = TimeSpan.FromMinutes(15);

    private readonly IBookingRepository _bookingRepository;
    private readonly IPasswordHasher _passwordHasher;

    public VerifyPinCommandHandler(IBookingRepository bookingRepository, IPasswordHasher passwordHasher)
    {
        _bookingRepository = bookingRepository;
        _passwordHasher = passwordHasher;
    }

    public async Task<bool> Handle(VerifyPinCommand request, CancellationToken cancellationToken)
    {
        var booking = await _bookingRepository.GetByIdAsync(request.BookingId, cancellationToken);
        if (booking == null || booking.Status != BookingStatus.Active) return false;

        if (string.IsNullOrEmpty(booking.PinHash)) return false;
        if (booking.PinLockedUntil.HasValue && booking.PinLockedUntil.Value > DateTime.UtcNow) return false;

        var isValid = _passwordHasher.Verify(request.Pin, booking.PinHash);
        if (isValid)
        {
            booking.PinAttempts = 0;
            booking.PinLockedUntil = null;
            await _bookingRepository.UpdateAsync(booking, cancellationToken);
            return true;
        }

        booking.PinAttempts++;
        if (booking.PinAttempts >= MaxPinAttempts)
        {
            booking.PinAttempts = 0;
            booking.PinLockedUntil = DateTime.UtcNow.Add(LockoutDuration);
        }

        await _bookingRepository.UpdateAsync(booking, cancellationToken);
        return false;
    }
}
