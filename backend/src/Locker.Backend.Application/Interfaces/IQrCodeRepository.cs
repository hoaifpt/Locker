using Locker.Backend.Domain.Entities;

namespace Locker.Backend.Application.Interfaces;

public interface IQrCodeRepository : IGenericRepository<QrCode>
{
    Task<QrCode?> GetValidCodeAsync(string code, CancellationToken cancellationToken);
}