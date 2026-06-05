using Locker.Backend.Application.Interfaces;
using MediatR;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.Packages.Commands.DeletePackage;

public record DeletePackageCommand(Guid Id) : IRequest<bool>;

public class DeletePackageCommandHandler : IRequestHandler<DeletePackageCommand, bool>
{
    private readonly IPackageRepository _packageRepository;

    public DeletePackageCommandHandler(IPackageRepository packageRepository)
    {
        _packageRepository = packageRepository;
    }

    public async Task<bool> Handle(DeletePackageCommand request, CancellationToken cancellationToken)
    {
        return await _packageRepository.SoftDeleteAsync(request.Id, cancellationToken);
    }
}
