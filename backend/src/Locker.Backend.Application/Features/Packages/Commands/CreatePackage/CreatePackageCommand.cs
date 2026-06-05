using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Mapping;
using Locker.Backend.Application.Models;
using MediatR;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.Packages.Commands.CreatePackage;

public record CreatePackageCommand(
    string Name,
    string Size,
    string Description,
    decimal PricePerHour) : IRequest<PackageDto>;

public class CreatePackageCommandHandler : IRequestHandler<CreatePackageCommand, PackageDto>
{
    private readonly IPackageRepository _packageRepository;
    private readonly PackageMapper _packageMapper;

    public CreatePackageCommandHandler(IPackageRepository packageRepository, PackageMapper packageMapper)
    {
        _packageRepository = packageRepository;
        _packageMapper = packageMapper;
    }

    public async Task<PackageDto> Handle(CreatePackageCommand request, CancellationToken cancellationToken)
    {
        var createRequest = new CreatePackageRequest
        {
            Name = request.Name,
            Size = request.Size,
            Description = request.Description,
            PricePerHour = request.PricePerHour
        };

        var package = _packageMapper.ToEntity(createRequest);
        await _packageRepository.CreateAsync(package, cancellationToken);
        return _packageMapper.Map(package);
    }
}
