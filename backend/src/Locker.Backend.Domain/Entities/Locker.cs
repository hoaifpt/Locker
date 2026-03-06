namespace Locker.Backend.Domain.Entities;

public class Locker : BaseEntity
{
    public string Name { get; set; } = string.Empty;
    public string Location { get; set; } = string.Empty;
    public double Latitude { get; set; }
    public double Longitude { get; set; }
    public List<LockerSlot> Slots { get; set; } = new();
    public bool IsDeleted { get; set; } = false;
}
