using Locker.Backend.Domain.Enums;

namespace Locker.Backend.Application.Models;

public class LockerMapSlotDto
{
    public string LockerId { get; set; } = string.Empty;
    public int SlotIndex { get; set; }
    public string Size { get; set; } = "M";
    public LockerSlotStatus Status { get; set; }
    public string SensorState { get; set; } = "Closed";
    public string HubLocation { get; set; } = string.Empty;
}

public class OpenLockerRequest
{
    public int SlotIndex { get; set; }
    public string? Reason { get; set; }
}

public class UpdateLockerSettingsRequest
{
    public bool? IsAutoLockEnabled { get; set; }
    public bool? IsIntrusionAlertEnabled { get; set; }
}

public class LockerOpenEventRequest
{
    public string SensorState { get; set; } = "Open";
    public DateTime? OccurredAt { get; set; }
}
