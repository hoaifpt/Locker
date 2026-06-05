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

        return _passwordHasher.Verify(request.Pin, booking.PinHash);
    }
}
