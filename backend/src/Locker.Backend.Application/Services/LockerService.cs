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
    private readonly LockerMapper _lockerMapper;

    public LockerService(ILockerRepository lockerRepository, LockerMapper lockerMapper)
    {
        _lockerRepository = lockerRepository;
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
        await _lockerRepository.UpdateAsync(locker, cancellationToken);
        return true;
    }

    public async Task<bool> DeleteAsync(string id, CancellationToken cancellationToken)
    {
        var existing = await _lockerRepository.GetByIdAsync(id, cancellationToken);
        if (existing == null) return false;

        await _lockerRepository.DeleteAsync(id, cancellationToken);
        return true;
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
}
