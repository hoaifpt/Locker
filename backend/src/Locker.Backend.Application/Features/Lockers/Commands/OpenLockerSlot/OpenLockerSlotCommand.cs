using Locker.Backend.Application.Interfaces;
using MediatR;
using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.Lockers.Commands.OpenLockerSlot;

public record OpenLockerSlotCommand(Guid LockerId, int SlotIndex, Guid? UserId, bool IsPrivileged, string? Pin = null) : IRequest<OpenLockerResult>;

public class OpenLockerSlotCommandHandler : IRequestHandler<OpenLockerSlotCommand, OpenLockerResult>
{
    private const int MaxPinAttempts = 5;
    private static readonly TimeSpan LockoutDuration = TimeSpan.FromMinutes(15);

    private readonly ILockerRepository _lockerRepository;
    private readonly IBookingRepository _bookingRepository;
    private readonly IOrderRepository _orderRepository;
    private readonly IPasswordHasher _passwordHasher;
    private readonly ILockerEventRepository _lockerEventRepository;

    public OpenLockerSlotCommandHandler(
        ILockerRepository lockerRepository,
        IBookingRepository bookingRepository,
        IOrderRepository orderRepository,
        IPasswordHasher passwordHasher,
        ILockerEventRepository lockerEventRepository)
    {
        _lockerRepository = lockerRepository;
        _bookingRepository = bookingRepository;
        _orderRepository = orderRepository;
        _passwordHasher = passwordHasher;
        _lockerEventRepository = lockerEventRepository;
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

            var ownsBooking = booking != null && booking.UserId == request.UserId;
            var ownsOrder = order != null && order.UserId == request.UserId;
            var allowed = ownsBooking || ownsOrder;

            if (!allowed) return OpenLockerResult.Forbidden;

            if (ownsBooking)
            {
                if (!await VerifyBookingPinAsync(booking!, request.Pin, cancellationToken))
                    return OpenLockerResult.InvalidPin;
            }

            if (ownsOrder)
            {
                if (!await VerifyOrderPinAsync(order!, request.Pin, cancellationToken))
                    return OpenLockerResult.InvalidPin;
            }
        }

        slot.SensorState = "Open";
        await _lockerRepository.UpdateAsync(locker, cancellationToken);

        await _lockerEventRepository.CreateAsync(new Locker.Backend.Domain.Entities.LockerEvent
        {
            LockerId = locker.Id,
            SlotIndex = request.SlotIndex,
            UserId = request.UserId,
            EventType = "Open"
        }, cancellationToken);

        return OpenLockerResult.Success;
    }

    private async Task<bool> VerifyBookingPinAsync(Locker.Backend.Domain.Entities.Booking booking, string? pin, CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(pin) || string.IsNullOrWhiteSpace(booking.PinHash))
            return false;

        if (booking.PinLockedUntil.HasValue && booking.PinLockedUntil.Value > DateTime.UtcNow)
            return false;

        var isValid = _passwordHasher.Verify(pin, booking.PinHash);
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

    private async Task<bool> VerifyOrderPinAsync(Locker.Backend.Domain.Entities.Order order, string? pin, CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(pin) || string.IsNullOrWhiteSpace(order.PinHash))
            return false;

        if (order.PinLockedUntil.HasValue && order.PinLockedUntil.Value > DateTime.UtcNow)
            return false;

        var isValid = _passwordHasher.Verify(pin, order.PinHash);
        if (isValid)
        {
            order.PinAttempts = 0;
            order.PinLockedUntil = null;
            await _orderRepository.UpdateAsync(order, cancellationToken);
            return true;
        }

        order.PinAttempts++;
        if (order.PinAttempts >= MaxPinAttempts)
        {
            order.PinAttempts = 0;
            order.PinLockedUntil = DateTime.UtcNow.Add(LockoutDuration);
        }

        await _orderRepository.UpdateAsync(order, cancellationToken);
        return false;
    }
}

public enum OpenLockerResult
{
    Success,
    Forbidden,
    InvalidPin,
    NotFound
}
