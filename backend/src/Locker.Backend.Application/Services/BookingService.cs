using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Models;
using Locker.Backend.Domain.Entities;
using Locker.Backend.Domain.Enums;

namespace Locker.Backend.Application.Services;

public class BookingService
{
    private readonly IBookingRepository _bookingRepository;
    private readonly ILockerRepository _lockerRepository;
    private readonly IPackageRepository _packageRepository;
    private readonly IPaymentRepository _paymentRepository;
    private readonly IPasswordHasher _passwordHasher;

    public BookingService(
        IBookingRepository bookingRepository,
        ILockerRepository lockerRepository,
        IPackageRepository packageRepository,
        IPaymentRepository paymentRepository,
        IPasswordHasher passwordHasher)
    {
        _bookingRepository = bookingRepository;
        _lockerRepository = lockerRepository;
        _packageRepository = packageRepository;
        _paymentRepository = paymentRepository;
        _passwordHasher = passwordHasher;
    }

    public async Task<BookingDto?> GetByIdAsync(string id, CancellationToken cancellationToken)
    {
        var booking = await _bookingRepository.GetByIdAsync(id, cancellationToken);
        return booking == null ? null : ToDto(booking);
    }

    public async Task<List<BookingDto>> GetAllAsync(CancellationToken cancellationToken)
    {
        var bookings = await _bookingRepository.GetAllAsync(cancellationToken);
        return bookings.Select(ToDto).ToList();
    }

    public async Task<List<BookingDto>> GetMyBookingsAsync(string userId, BookingStatus? status, CancellationToken cancellationToken)
    {
        var bookings = await _bookingRepository.GetByUserIdAsync(userId, cancellationToken);
        if (status.HasValue)
            bookings = bookings.Where(b => b.Status == status.Value).ToList();
        return bookings.Select(ToDto).ToList();
    }

    public async Task<BookingDto?> CreateAsync(string userId, CreateBookingRequest request, CancellationToken cancellationToken)
    {
        var locker = await _lockerRepository.GetByIdAsync(request.LockerId, cancellationToken);
        if (locker == null) return null;

        var slot = locker.Slots.FirstOrDefault(s => s.Index == request.SlotIndex);
        if (slot == null || slot.Status != LockerSlotStatus.Available) return null;

        var package = await _packageRepository.GetByIdAsync(request.PackageId, cancellationToken);
        if (package == null || !package.IsActive) return null;

        var booking = new Booking
        {
            UserId = userId,
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

        return ToDto(booking);
    }

    public async Task<bool> SetPinAsync(string bookingId, string userId, SetPinRequest request, CancellationToken cancellationToken)
    {
        var booking = await _bookingRepository.GetByIdAsync(bookingId, cancellationToken);
        if (booking == null || booking.UserId != userId) return false;
        if (booking.Status != BookingStatus.Pending) return false;

        // Payment must be completed before setting PIN
        if (booking.PaymentId != null)
        {
            var payment = await _paymentRepository.GetByBookingIdAsync(bookingId, cancellationToken);
            if (payment == null || payment.Status != PaymentStatus.Completed) return false;
        }

        var locker = await _lockerRepository.GetByIdAsync(booking.LockerId, cancellationToken);
        if (locker == null) return false;

        booking.PinHash = _passwordHasher.Hash(request.Pin);
        booking.Status = BookingStatus.Active;
        booking.StartedAt = DateTime.UtcNow;

        var slot = locker.Slots.FirstOrDefault(s => s.Index == booking.SlotIndex);
        if (slot != null)
            slot.Status = LockerSlotStatus.Ative;

        await _bookingRepository.UpdateAsync(booking, cancellationToken);
        await _lockerRepository.UpdateAsync(locker, cancellationToken);
        return true;
    }

    public async Task<bool> VerifyPinAsync(string bookingId, VerifyPinRequest request, CancellationToken cancellationToken)
    {
        var booking = await _bookingRepository.GetByIdAsync(bookingId, cancellationToken);
        if (booking == null || booking.Status != BookingStatus.Active) return false;

        return _passwordHasher.Verify(request.Pin, booking.PinHash);
    }

    public async Task<bool> CompleteAsync(string bookingId, string userId, CancellationToken cancellationToken)
    {
        var booking = await _bookingRepository.GetByIdAsync(bookingId, cancellationToken);
        if (booking == null || booking.UserId != userId) return false;
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

    public async Task<bool> CancelAsync(string bookingId, string userId, CancellationToken cancellationToken)
    {
        var booking = await _bookingRepository.GetByIdAsync(bookingId, cancellationToken);
        if (booking == null || booking.UserId != userId) return false;
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

    private static BookingDto ToDto(Booking b) => new()
    {
        Id = b.Id,
        UserId = b.UserId,
        LockerId = b.LockerId,
        SlotIndex = b.SlotIndex,
        PackageId = b.PackageId,
        MobileNumber = b.MobileNumber,
        Status = b.Status,
        TotalAmount = b.TotalAmount,
        PaymentId = b.PaymentId,
        CreatedAt = b.CreatedAt,
        StartedAt = b.StartedAt,
        CompletedAt = b.CompletedAt
    };
}
