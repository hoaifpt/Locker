namespace Locker.Backend.Domain.Entities;

public class Package : BaseEntity
{
    public string Name { get; set; } = string.Empty;
    public string Size { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public decimal PricePerHour { get; set; }
    public bool IsActive { get; set; } = true;
}
