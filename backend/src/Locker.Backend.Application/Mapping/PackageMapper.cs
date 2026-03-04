using Locker.Backend.Application.Models;
using Locker.Backend.Domain.Entities;

namespace Locker.Backend.Application.Mapping;

public class PackageMapper : IMapper<Package, PackageDto>
{
    public PackageDto Map(Package source) => new()
    {
        Id = source.Id,
        Name = source.Name,
        Size = source.Size,
        Description = source.Description,
        PricePerHour = source.PricePerHour,
        IsActive = source.IsActive
    };

    public Package ToEntity(CreatePackageRequest request) => new()
    {
        Name = request.Name,
        Size = request.Size,
        Description = request.Description,
        PricePerHour = request.PricePerHour
    };

    public void UpdateEntity(UpdatePackageRequest request, Package target)
    {
        target.Name = request.Name;
        target.Size = request.Size;
        target.Description = request.Description;
        target.PricePerHour = request.PricePerHour;
        target.IsActive = request.IsActive;
    }
}
