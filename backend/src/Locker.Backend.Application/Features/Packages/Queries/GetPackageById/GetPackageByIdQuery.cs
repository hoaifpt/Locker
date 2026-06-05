using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Mapping;
using Locker.Backend.Application.Models;
using MediatR;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.Packages.Queries.GetPackageById;

public record GetPackageByIdQuery(Guid Id) : IRequest<PackageDto?>;

public class GetPackageByIdQueryHandler : IRequestHandler<GetPackageByIdQuery, PackageDto?>
{
    private readonly IPackageRepository _packageRepository;
    private readonly PackageMapper _packageMapper;

    public GetPackageByIdQueryHandler(IPackageRepository packageRepository, PackageMapper packageMapper)
    {
        _packageRepository = packageRepository;
        _packageMapper = packageMapper;
    }

    public async Task<PackageDto?> Handle(GetPackageByIdQuery request, CancellationToken cancellationToken)
    {
        var package = await _packageRepository.GetByIdAsync(request.Id, cancellationToken);
        return package == null ? null : _packageMapper.Map(package);
    }
}
