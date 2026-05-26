using Locker.Backend.Domain.Enums;

namespace Locker.Backend.Application.Models;

public class LockerDto
{
    public string Id { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public string Location { get; set; } = string.Empty;
    public double Latitude { get; set; }
    public double Longitude { get; set; }
    public bool IsAutoLockEnabled { get; set; }
    public bool IsIntrusionAlertEnabled { get; set; }
    public List<LockerSlotDto> Slots { get; set; } = new();
}

public class LockerSlotDto
{
    public int Index { get; set; }
    public LockerSlotStatus Status { get; set; }
    public string Size { get; set; } = "M";
    public string SensorState { get; set; } = "Closed";
}

public class UpdateSlotStatusRequest
{
    public LockerSlotStatus Status { get; set; }
}
