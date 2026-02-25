using AutoMapper;
using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Models;
using Locker.Backend.Domain.Entities;

namespace Locker.Backend.Application.Services;

public class PackageService
{
    private readonly IPackageRepository _packageRepository;
    private readonly IMapper _mapper;

    public PackageService(IPackageRepository packageRepository, IMapper mapper)
    {
        _packageRepository = packageRepository;
        _mapper = mapper;
    }

    public async Task<List<PackageDto>> GetAllAsync(CancellationToken cancellationToken)
    {
        var packages = await _packageRepository.GetActiveAsync(cancellationToken);
        return _mapper.Map<List<PackageDto>>(packages);
    }

    public async Task<PackageDto?> GetByIdAsync(string id, CancellationToken cancellationToken)
    {
        var package = await _packageRepository.GetByIdAsync(id, cancellationToken);
        return package == null ? null : _mapper.Map<PackageDto>(package);
    }

    public async Task<PackageDto> CreateAsync(CreatePackageRequest request, CancellationToken cancellationToken)
    {
        var package = _mapper.Map<Package>(request);
        await _packageRepository.CreateAsync(package, cancellationToken);
        return _mapper.Map<PackageDto>(package);
    }

    public async Task<bool> UpdateAsync(string id, UpdatePackageRequest request, CancellationToken cancellationToken)
    {
        var package = await _packageRepository.GetByIdAsync(id, cancellationToken);
        if (package == null) return false;

        _mapper.Map(request, package);
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
}
