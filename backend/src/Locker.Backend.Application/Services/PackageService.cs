using Locker.Backend.Application.Interfaces;
<<<<<<< HEAD
using Locker.Backend.Application.Mapping;
using Locker.Backend.Application.Models;
=======
using Locker.Backend.Application.Models;
using Locker.Backend.Domain.Entities;
>>>>>>> cd41969f38b41cd3f098ee3ee44d55472bf88075

namespace Locker.Backend.Application.Services;

public class PackageService
{
    private readonly IPackageRepository _packageRepository;
<<<<<<< HEAD
    private readonly PackageMapper _packageMapper;

    public PackageService(IPackageRepository packageRepository, PackageMapper packageMapper)
    {
        _packageRepository = packageRepository;
        _packageMapper = packageMapper;
=======

    public PackageService(IPackageRepository packageRepository)
    {
        _packageRepository = packageRepository;
>>>>>>> cd41969f38b41cd3f098ee3ee44d55472bf88075
    }

    public async Task<List<PackageDto>> GetAllAsync(CancellationToken cancellationToken)
    {
        var packages = await _packageRepository.GetActiveAsync(cancellationToken);
<<<<<<< HEAD
        return packages.Select(_packageMapper.Map).ToList();
=======
        return packages.Select(ToDto).ToList();
>>>>>>> cd41969f38b41cd3f098ee3ee44d55472bf88075
    }

    public async Task<PackageDto?> GetByIdAsync(string id, CancellationToken cancellationToken)
    {
        var package = await _packageRepository.GetByIdAsync(id, cancellationToken);
<<<<<<< HEAD
        return package == null ? null : _packageMapper.Map(package);
=======
        return package == null ? null : ToDto(package);
>>>>>>> cd41969f38b41cd3f098ee3ee44d55472bf88075
    }

    public async Task<PackageDto> CreateAsync(CreatePackageRequest request, CancellationToken cancellationToken)
    {
<<<<<<< HEAD
        var package = _packageMapper.ToEntity(request);
        await _packageRepository.CreateAsync(package, cancellationToken);
        return _packageMapper.Map(package);
=======
        var package = new Package
        {
            Name = request.Name,
            Size = request.Size,
            Description = request.Description,
            PricePerHour = request.PricePerHour
        };
        await _packageRepository.CreateAsync(package, cancellationToken);
        return ToDto(package);
>>>>>>> cd41969f38b41cd3f098ee3ee44d55472bf88075
    }

    public async Task<bool> UpdateAsync(string id, UpdatePackageRequest request, CancellationToken cancellationToken)
    {
        var package = await _packageRepository.GetByIdAsync(id, cancellationToken);
        if (package == null) return false;

<<<<<<< HEAD
        _packageMapper.UpdateEntity(request, package);
=======
        package.Name = request.Name;
        package.Size = request.Size;
        package.Description = request.Description;
        package.PricePerHour = request.PricePerHour;
        package.IsActive = request.IsActive;

>>>>>>> cd41969f38b41cd3f098ee3ee44d55472bf88075
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
<<<<<<< HEAD
=======

    private static PackageDto ToDto(Package p) => new()
    {
        Id = p.Id,
        Name = p.Name,
        Size = p.Size,
        Description = p.Description,
        PricePerHour = p.PricePerHour,
        IsActive = p.IsActive
    };
>>>>>>> cd41969f38b41cd3f098ee3ee44d55472bf88075
}
