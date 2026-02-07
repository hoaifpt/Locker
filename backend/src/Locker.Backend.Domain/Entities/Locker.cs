namespace Locker.Backend.Domain.Entities;

public class Locker : BaseEntity
{
    public string Name { get; set; } = string.Empty;
    public string Location { get; set; } = string.Empty;
    public List<LockerSlot> Slots { get; set; } = new();
}
