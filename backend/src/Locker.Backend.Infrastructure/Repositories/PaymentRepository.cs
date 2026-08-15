using Locker.Backend.Application.Interfaces;
using Locker.Backend.Domain.Entities;
using Locker.Backend.Domain.Enums;
using Locker.Backend.Infrastructure.Mongo;
using MongoDB.Driver;

namespace Locker.Backend.Infrastructure.Repositories;

public class PaymentRepository : GenericRepository<Payment>, IPaymentRepository
{
    public PaymentRepository(MongoContext context)
        : base(context.Database.GetCollection<Payment>(
            context.Settings.PaymentsCollection))
    {
    }

    public async Task<Payment?> GetByBookingIdAsync(
        Guid bookingId,
        CancellationToken cancellationToken)
    {
        var cursor = await _collection.FindAsync(
            p => p.BookingId == bookingId,
            cancellationToken: cancellationToken);

        return await cursor.FirstOrDefaultAsync(cancellationToken);
    }

    public async Task<List<Payment>> GetByUserIdAsync(
        Guid userId,
        CancellationToken cancellationToken)
    {
        var cursor = await _collection.FindAsync(
            p => p.UserId == userId,
            cancellationToken: cancellationToken);

        return await cursor.ToListAsync(cancellationToken);
    }

    public async Task<Payment?> GetBySepayCodeAsync(
        string sepayCode,
        CancellationToken cancellationToken)
    {
        var cursor = await _collection.FindAsync(
            p => p.SepayCode == sepayCode,
            cancellationToken: cancellationToken);

        return await cursor.FirstOrDefaultAsync(cancellationToken);
    }

    public async Task<Payment?> TryCompletePendingAsync(
        Guid paymentId,
        string transactionId,
        DateTime paidAt,
        CancellationToken cancellationToken)
    {
        var filter = Builders<Payment>.Filter.And(
            Builders<Payment>.Filter.Eq(x => x.Id, paymentId),
            Builders<Payment>.Filter.Eq(x => x.Status, PaymentStatus.Pending));

        var update = Builders<Payment>.Update
            .Set(x => x.Status, PaymentStatus.Completed)
            .Set(x => x.TransactionId, transactionId)
            .Set(x => x.PaidAt, paidAt);

        return await _collection.FindOneAndUpdateAsync(
            filter,
            update,
            new FindOneAndUpdateOptions<Payment>
            {
                ReturnDocument = ReturnDocument.After,
            },
            cancellationToken);
    }

    public async Task<Payment?> TryCancelPendingAsync(
        Guid paymentId,
        CancellationToken cancellationToken)
    {
        var filter = Builders<Payment>.Filter.And(
            Builders<Payment>.Filter.Eq(x => x.Id, paymentId),
            Builders<Payment>.Filter.Eq(x => x.Status, PaymentStatus.Pending));

        var update = Builders<Payment>.Update
            .Set(x => x.Status, PaymentStatus.Cancelled);

        return await _collection.FindOneAndUpdateAsync(
            filter,
            update,
            new FindOneAndUpdateOptions<Payment>
            {
                ReturnDocument = ReturnDocument.After,
            },
            cancellationToken);
    }
}
