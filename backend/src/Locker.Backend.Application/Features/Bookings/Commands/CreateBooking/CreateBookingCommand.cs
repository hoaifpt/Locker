using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Mapping;
using Locker.Backend.Application.Models;
using Locker.Backend.Domain.Entities;
using Locker.Backend.Domain.Enums;
using MediatR;
using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using BookingEntity = Locker.Backend.Domain.Entities.Booking;

namespace Locker.Backend.Application.Features.Bookings.Commands.CreateBooking;

public record CreateBookingCommand(Guid UserId, Guid LockerId, int SlotIndex, Guid PackageId, string MobileNumber) : IRequest<BookingDto?>;

public class CreateBookingCommandHandler : IRequestHandler<CreateBookingCommand, BookingDto?>
{
    private readonly IBookingRepository _bookingRepository;
    private readonly ILockerRepository _lockerRepository;
    private readonly IPackageRepository _packageRepository;
    private readonly BookingMapper _bookingMapper;

    public CreateBookingCommandHandler(
        IBookingRepository bookingRepository,
        ILockerRepository lockerRepository,
        IPackageRepository packageRepository,
        BookingMapper bookingMapper)
    {
        _bookingRepository = bookingRepository;
        _lockerRepository = lockerRepository;
        _packageRepository = packageRepository;
        _bookingMapper = bookingMapper;
    }

    public async Task<BookingDto?> Handle(CreateBookingCommand request, CancellationToken cancellationToken)
    {
        var locker = await _lockerRepository.GetByIdAsync(request.LockerId, cancellationToken);
        if (locker == null) return null;

        var slot = locker.Slots.FirstOrDefault(s => s.Index == request.SlotIndex);
        if (slot == null || slot.Status != LockerSlotStatus.Available) return null;

        var package = await _packageRepository.GetByIdAsync(request.PackageId, cancellationToken);
        if (package == null || !package.IsActive) return null;

        var booking = new BookingEntity
        {
            UserId = request.UserId,
            LockerId = request.LockerId,
            SlotIndex = request.SlotIndex,
            PackageId = request.PackageId,
            MobileNumber = request.MobileNumber,
            TotalAmount = package.PricePerHour,
            Status = BookingStatus.Pending
        };

        slot.Status = LockerSlotStatus.Pending;
        slot.BookingId = booking.Id;

        await _bookingRepository.CreateAsync(booking, cancellationToken);
        await _lockerRepository.UpdateAsync(locker, cancellationToken);

        return _bookingMapper.Map(booking);
    }
}
