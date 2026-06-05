using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Mapping;
using Locker.Backend.Application.Models;
using MediatR;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.Packages.Queries.GetAllPackages;

public record GetAllPackagesQuery() : IRequest<List<PackageDto>>;

public class GetAllPackagesQueryHandler : IRequestHandler<GetAllPackagesQuery, List<PackageDto>>
{
    private readonly IPackageRepository _packageRepository;
    private readonly PackageMapper _packageMapper;

    public GetAllPackagesQueryHandler(IPackageRepository packageRepository, PackageMapper packageMapper)
    {
        _packageRepository = packageRepository;
        _packageMapper = packageMapper;
    }

    public async Task<List<PackageDto>> Handle(GetAllPackagesQuery request, CancellationToken cancellationToken)
    {
        var packages = await _packageRepository.GetActiveAsync(cancellationToken);
        return packages.Select(_packageMapper.Map).ToList();
    }
}
