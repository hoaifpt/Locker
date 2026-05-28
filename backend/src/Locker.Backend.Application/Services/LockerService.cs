using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Mapping;
using Locker.Backend.Application.Models;
using Locker.Backend.Domain.Entities;
using Locker.Backend.Domain.Enums;
using LockerEntity = Locker.Backend.Domain.Entities.Locker;

namespace Locker.Backend.Application.Services;

public class LockerService
{
    private readonly ILockerRepository _lockerRepository;
    private readonly IBookingRepository _bookingRepository;
    private readonly IOrderRepository _orderRepository;
    private readonly LockerMapper _lockerMapper;

    public LockerService(
        ILockerRepository lockerRepository,
        IBookingRepository bookingRepository,
        IOrderRepository orderRepository,
        LockerMapper lockerMapper)
    {
        _lockerRepository = lockerRepository;
        _bookingRepository = bookingRepository;
        _orderRepository = orderRepository;
        _lockerMapper = lockerMapper;
    }

    public async Task<List<LockerDto>> GetAllAsync(CancellationToken cancellationToken)
    {
        var lockers = await _lockerRepository.GetAllAsync(cancellationToken);
        return lockers.Select(_lockerMapper.Map).ToList();
    }

    public async Task<List<LockerDto>> GetAvailableAsync(CancellationToken cancellationToken)
    {
        var lockers = await _lockerRepository.GetAllAsync(cancellationToken);
        var available = lockers.Where(l => l.Slots.Any(s => s.Status == LockerSlotStatus.Available)).ToList();
        return available.Select(_lockerMapper.Map).ToList();
    }

    public async Task<LockerDto?> GetByIdAsync(string id, CancellationToken cancellationToken)
    {
        var locker = await _lockerRepository.GetByIdAsync(id, cancellationToken);
        return locker == null ? null : _lockerMapper.Map(locker);
    }

    public async Task<LockerDto> CreateAsync(CreateLockerRequest request, CancellationToken cancellationToken)
    {
        var locker = new LockerEntity
        {
            Name = request.Name,
            Location = request.Location,
            Latitude = request.Latitude,
            Longitude = request.Longitude,
            Slots = Enumerable.Range(1, request.Slots)
                .Select(index => new LockerSlot { Index = index })
                .ToList()
        };

        await _lockerRepository.CreateAsync(locker, cancellationToken);
        return _lockerMapper.Map(locker);
    }

    public async Task<bool> UpdateAsync(string id, UpdateLockerRequest request, CancellationToken cancellationToken)
    {
        var locker = await _lockerRepository.GetByIdAsync(id, cancellationToken);
        if (locker == null) return false;

        locker.Name = request.Name;
        locker.Location = request.Location;
        locker.Latitude = request.Latitude;
        locker.Longitude = request.Longitude;
        await _lockerRepository.UpdateAsync(locker, cancellationToken);
        return true;
    }

    public async Task<bool> SoftDeleteAsync(string id, CancellationToken cancellationToken)
    {
        return await _lockerRepository.SoftDeleteAsync(id, cancellationToken);
    }

    public async Task<bool> UpdateSlotStatusAsync(string lockerId, int slotIndex, LockerSlotStatus status, CancellationToken cancellationToken)
    {
        var locker = await _lockerRepository.GetByIdAsync(lockerId, cancellationToken);
        if (locker == null) return false;

        var slot = locker.Slots.FirstOrDefault(s => s.Index == slotIndex);
        if (slot == null) return false;

        slot.Status = status;
        await _lockerRepository.UpdateAsync(locker, cancellationToken);
        return true;
    }

    public async Task<List<LockerMapSlotDto>> GetMapAsync(CancellationToken cancellationToken)
    {
        var lockers = await _lockerRepository.GetAllAsync(cancellationToken);
        var results = new List<LockerMapSlotDto>();

        foreach (var locker in lockers)
        {
            foreach (var slot in locker.Slots)
            {
                results.Add(new LockerMapSlotDto
                {
                    LockerId = locker.Id,
                    SlotIndex = slot.Index,
                    Size = slot.Size,
                    Status = slot.Status,
                    SensorState = slot.SensorState,
                    HubLocation = locker.Location
                });
            }
        }

        return results;
    }

    public async Task<bool> UpdateSettingsAsync(string lockerId, UpdateLockerSettingsRequest request, CancellationToken cancellationToken)
    {
        var locker = await _lockerRepository.GetByIdAsync(lockerId, cancellationToken);
        if (locker == null) return false;

        if (request.IsAutoLockEnabled.HasValue)
            locker.IsAutoLockEnabled = request.IsAutoLockEnabled.Value;

        if (request.IsIntrusionAlertEnabled.HasValue)
            locker.IsIntrusionAlertEnabled = request.IsIntrusionAlertEnabled.Value;

        await _lockerRepository.UpdateAsync(locker, cancellationToken);
        return true;
    }

    public async Task<OpenLockerResult> OpenSlotAsync(
        string lockerId,
        int slotIndex,
        string? userId,
        bool isPrivileged,
        CancellationToken cancellationToken)
    {
        var locker = await _lockerRepository.GetByIdAsync(lockerId, cancellationToken);
        if (locker == null) return OpenLockerResult.NotFound;

        var slot = locker.Slots.FirstOrDefault(s => s.Index == slotIndex);
        if (slot == null) return OpenLockerResult.NotFound;

        if (!isPrivileged)
        {
            if (string.IsNullOrWhiteSpace(userId)) return OpenLockerResult.Forbidden;

            var booking = await _bookingRepository.GetActiveBySlotAsync(lockerId, slotIndex, cancellationToken);
            var order = await _orderRepository.GetActiveBySlotAsync(lockerId, slotIndex, cancellationToken);

            var allowed = (booking != null && booking.UserId == userId) ||
                          (order != null && order.UserId == userId);

            if (!allowed) return OpenLockerResult.Forbidden;
        }

        slot.SensorState = "Open";
        await _lockerRepository.UpdateAsync(locker, cancellationToken);
        return OpenLockerResult.Success;
    }

    public async Task<bool> RecordOpenEventAsync(string lockerId, int slotIndex, LockerOpenEventRequest request, CancellationToken cancellationToken)
    {
        var locker = await _lockerRepository.GetByIdAsync(lockerId, cancellationToken);
        if (locker == null) return false;

        var slot = locker.Slots.FirstOrDefault(s => s.Index == slotIndex);
        if (slot == null) return false;

        slot.SensorState = request.SensorState;
        await _lockerRepository.UpdateAsync(locker, cancellationToken);
        return true;
    }
}

public enum OpenLockerResult
{
    Success,
    Forbidden,
    NotFound
}
