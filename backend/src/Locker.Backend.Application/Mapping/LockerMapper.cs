using Locker.Backend.Application.Models;
using Locker.Backend.Domain.Entities;
using LockerEntity = Locker.Backend.Domain.Entities.Locker;

namespace Locker.Backend.Application.Mapping;

public class LockerSlotMapper : IMapper<LockerSlot, LockerSlotDto>
{
    public LockerSlotDto Map(LockerSlot source) => new()
    {
        Index = source.Index,
        Status = source.Status
    };
}

public class LockerMapper : IMapper<LockerEntity, LockerDto>
{
    private readonly LockerSlotMapper _slotMapper;

    public LockerMapper(LockerSlotMapper slotMapper)
    {
        _slotMapper = slotMapper;
    }

    public LockerDto Map(LockerEntity source) => new()
    {
        Id = source.Id,
        Name = source.Name,
        Location = source.Location,
        Slots = source.Slots.Select(_slotMapper.Map).ToList()
    };
}
