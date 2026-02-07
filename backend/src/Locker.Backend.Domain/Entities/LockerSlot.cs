using Locker.Backend.Domain.Enums;

namespace Locker.Backend.Domain.Entities;

public class LockerSlot
{
    public int Index { get; set; }
    public LockerSlotStatus Status { get; set; } = LockerSlotStatus.Available;
}
