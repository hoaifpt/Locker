using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Mapping;
using Locker.Backend.Application.Models;

namespace Locker.Backend.Application.Services;

public class PackageService
{
    private readonly IPackageRepository _packageRepository;
    private readonly PackageMapper _packageMapper;

    public PackageService(IPackageRepository packageRepository, PackageMapper packageMapper)
    {
        _packageRepository = packageRepository;
        _packageMapper = packageMapper;
    }

    public async Task<List<PackageDto>> GetAllAsync(CancellationToken cancellationToken)
    {
        var packages = await _packageRepository.GetActiveAsync(cancellationToken);
        return packages.Select(_packageMapper.Map).ToList();
    }

    public async Task<PackageDto?> GetByIdAsync(Guid id, CancellationToken cancellationToken)
    {
        var package = await _packageRepository.GetByIdAsync(id, cancellationToken);
        return package == null ? null : _packageMapper.Map(package);
    }

    public async Task<PackageDto> CreateAsync(CreatePackageRequest request, CancellationToken cancellationToken)
    {
        var package = _packageMapper.ToEntity(request);
        await _packageRepository.CreateAsync(package, cancellationToken);
        return _packageMapper.Map(package);
    }

    public async Task<bool> UpdateAsync(Guid id, UpdatePackageRequest request, CancellationToken cancellationToken)
    {
        var package = await _packageRepository.GetByIdAsync(id, cancellationToken);
        if (package == null) return false;

        _packageMapper.UpdateEntity(request, package);
        await _packageRepository.UpdateAsync(package, cancellationToken);
        return true;
    }

    public async Task<bool> SoftDeleteAsync(Guid id, CancellationToken cancellationToken)
    {
        return await _packageRepository.SoftDeleteAsync(id, cancellationToken);
    }
}
