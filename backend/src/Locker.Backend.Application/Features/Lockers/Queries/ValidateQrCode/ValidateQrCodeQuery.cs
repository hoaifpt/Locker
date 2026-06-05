using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Models;
using MediatR;
using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.Lockers.Queries.ValidateQrCode;

public record ValidateQrCodeQuery(string QrCode) : IRequest<QrScanResultDto?>;

public class ValidateQrCodeQueryHandler : IRequestHandler<ValidateQrCodeQuery, QrScanResultDto?>
{
    private readonly ILockerRepository _lockerRepository;

    public ValidateQrCodeQueryHandler(ILockerRepository lockerRepository)
    {
        _lockerRepository = lockerRepository;
    }

    public async Task<QrScanResultDto?> Handle(ValidateQrCodeQuery request, CancellationToken cancellationToken)
    {
        var lockers = await _lockerRepository.GetAllAsync(cancellationToken);
        var normalizedQrCode = request.QrCode.Trim().ToLowerInvariant();

        var locker = lockers.FirstOrDefault(l =>
            l.Id.ToString().Equals(normalizedQrCode, StringComparison.OrdinalIgnoreCase) ||
            l.Name.Equals(normalizedQrCode, StringComparison.OrdinalIgnoreCase));

        if (locker == null)
        {
            return null;
        }

        return new QrScanResultDto
        {
            Id = Guid.NewGuid(),
            QrCode = request.QrCode,
            LockerId = locker.Id,
            LockerCode = locker.Name,
            ScannedAt = DateTime.UtcNow,
            IsValid = true,
        };
    }
}
