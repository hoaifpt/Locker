using Locker.Backend.Domain.Enums;

namespace Locker.Backend.Application.Models;

public class LockerDto
{
    public string Id { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public string Location { get; set; } = string.Empty;
    public List<LockerSlotDto> Slots { get; set; } = new();
}

public class LockerSlotDto
{
    public int Index { get; set; }
    public LockerSlotStatus Status { get; set; }
}

public class UpdateSlotStatusRequest
{
    public LockerSlotStatus Status { get; set; }
}
