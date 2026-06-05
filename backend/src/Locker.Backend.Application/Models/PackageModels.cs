namespace Locker.Backend.Application.Models;

public class PackageDto
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Size { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public decimal PricePerHour { get; set; }
    public bool IsActive { get; set; }
}

public class CreatePackageRequest
{
    public string Name { get; set; } = string.Empty;
    public string Size { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public decimal PricePerHour { get; set; }
}

public class UpdatePackageRequest
{
    public string Name { get; set; } = string.Empty;
    public string Size { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public decimal PricePerHour { get; set; }
    public bool IsActive { get; set; }
}
