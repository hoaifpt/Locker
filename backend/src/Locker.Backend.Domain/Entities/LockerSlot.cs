using Locker.Backend.Domain.Enums;

namespace Locker.Backend.Domain.Entities;

public class LockerSlot
{
    public int Index { get; set; }
    public LockerSlotStatus Status { get; set; } = LockerSlotStatus.Available;
    public string Size { get; set; } = "M";
    public string SensorState { get; set; } = "Closed";
    public string? BookingId { get; set; }
}
