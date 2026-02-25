using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Models;
using Locker.Backend.Domain.Entities;

namespace Locker.Backend.Application.Services;

public class PackageService
{
    private readonly IPackageRepository _packageRepository;

    public PackageService(IPackageRepository packageRepository)
    {
        _packageRepository = packageRepository;
    }

    public async Task<List<PackageDto>> GetAllAsync(CancellationToken cancellationToken)
    {
        var packages = await _packageRepository.GetActiveAsync(cancellationToken);
        return packages.Select(ToDto).ToList();
    }

    public async Task<PackageDto?> GetByIdAsync(string id, CancellationToken cancellationToken)
    {
        var package = await _packageRepository.GetByIdAsync(id, cancellationToken);
        return package == null ? null : ToDto(package);
    }

    public async Task<PackageDto> CreateAsync(CreatePackageRequest request, CancellationToken cancellationToken)
    {
        var package = new Package
        {
            Name = request.Name,
            Size = request.Size,
            Description = request.Description,
            PricePerHour = request.PricePerHour
        };
        await _packageRepository.CreateAsync(package, cancellationToken);
        return ToDto(package);
    }

    public async Task<bool> UpdateAsync(string id, UpdatePackageRequest request, CancellationToken cancellationToken)
    {
        var package = await _packageRepository.GetByIdAsync(id, cancellationToken);
        if (package == null) return false;

        package.Name = request.Name;
        package.Size = request.Size;
        package.Description = request.Description;
        package.PricePerHour = request.PricePerHour;
        package.IsActive = request.IsActive;

        await _packageRepository.UpdateAsync(package, cancellationToken);
        return true;
    }

    public async Task<bool> DeleteAsync(string id, CancellationToken cancellationToken)
    {
        var package = await _packageRepository.GetByIdAsync(id, cancellationToken);
        if (package == null) return false;

        await _packageRepository.DeleteAsync(id, cancellationToken);
        return true;
    }

    private static PackageDto ToDto(Package p) => new()
    {
        Id = p.Id,
        Name = p.Name,
        Size = p.Size,
        Description = p.Description,
        PricePerHour = p.PricePerHour,
        IsActive = p.IsActive
    };
}
