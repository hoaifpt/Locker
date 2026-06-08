using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Models;
using MediatR;
using System;
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
        var normalizedQrCode = request.QrCode.Trim();

        if (!Guid.TryParse(normalizedQrCode, out var lockerId))
        {
            return null;
        }

        var locker = await _lockerRepository.GetByIdAsync(lockerId, cancellationToken);
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

