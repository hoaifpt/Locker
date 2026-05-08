using Locker.Backend.Application.Interfaces;
using Locker.Backend.Domain.Entities;
using Locker.Backend.Infrastructure.Mongo;
using MongoDB.Driver;

namespace Locker.Backend.Infrastructure.Repositories;

public class QrCodeRepository : GenericRepository<QrCode>, IQrCodeRepository
{
    public QrCodeRepository(MongoContext context)
        : base(context.Database.GetCollection<QrCode>(context.Settings.QrCodesCollection))
    {
    }

    public async Task<QrCode?> GetValidCodeAsync(string code, CancellationToken cancellationToken)
    {
        return await _collection.Find(x => x.Code == code && !x.IsUsed && x.ExpiresAt > DateTime.UtcNow)
                                .FirstOrDefaultAsync(cancellationToken);
    }
}