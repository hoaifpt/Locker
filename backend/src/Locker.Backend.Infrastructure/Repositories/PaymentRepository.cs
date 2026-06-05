using Locker.Backend.Application.Interfaces;
using Locker.Backend.Domain.Entities;
using Locker.Backend.Infrastructure.Mongo;
using MongoDB.Driver;

namespace Locker.Backend.Infrastructure.Repositories;

public class PaymentRepository : GenericRepository<Payment>, IPaymentRepository
{
    public PaymentRepository(MongoContext context)
        : base(context.Database.GetCollection<Payment>(context.Settings.PaymentsCollection))
    {
    }

    public async Task<Payment?> GetByBookingIdAsync(Guid bookingId, CancellationToken cancellationToken)
    {
        var cursor = await _collection.FindAsync(p => p.BookingId == bookingId, cancellationToken: cancellationToken);
        return await cursor.FirstOrDefaultAsync(cancellationToken);
    }

    public async Task<List<Payment>> GetByUserIdAsync(Guid userId, CancellationToken cancellationToken)
    {
        var cursor = await _collection.FindAsync(p => p.UserId == userId, cancellationToken: cancellationToken);
        return await cursor.ToListAsync(cancellationToken);
    }
}
