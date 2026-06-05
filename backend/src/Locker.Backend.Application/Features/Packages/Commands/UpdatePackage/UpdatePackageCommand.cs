using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Mapping;
using Locker.Backend.Application.Models;
using MediatR;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.Packages.Commands.UpdatePackage;

public record UpdatePackageCommand(
    Guid Id,
    string Name,
    string Size,
    string Description,
    decimal PricePerHour,
    bool IsActive) : IRequest<bool>;

public class UpdatePackageCommandHandler : IRequestHandler<UpdatePackageCommand, bool>
{
    private readonly IPackageRepository _packageRepository;
    private readonly PackageMapper _packageMapper;

    public UpdatePackageCommandHandler(IPackageRepository packageRepository, PackageMapper packageMapper)
    {
        _packageRepository = packageRepository;
        _packageMapper = packageMapper;
    }

    public async Task<bool> Handle(UpdatePackageCommand request, CancellationToken cancellationToken)
    {
        var package = await _packageRepository.GetByIdAsync(request.Id, cancellationToken);
        if (package == null) return false;

        var updateRequest = new UpdatePackageRequest
        {
            Name = request.Name,
            Size = request.Size,
            Description = request.Description,
            PricePerHour = request.PricePerHour,
            IsActive = request.IsActive
        };

        _packageMapper.UpdateEntity(updateRequest, package);
        await _packageRepository.UpdateAsync(package, cancellationToken);
        return true;
    }
}
