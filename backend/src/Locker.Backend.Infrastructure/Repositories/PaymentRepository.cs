using Locker.Backend.Application.Interfaces;
using Locker.Backend.Domain.Entities;
using Locker.Backend.Infrastructure.Mongo;
using MongoDB.Driver;

namespace Locker.Backend.Infrastructure.Repositories;

public class PaymentRepository : IPaymentRepository
{
    private readonly IMongoCollection<Payment> _collection;

    public PaymentRepository(MongoContext context)
    {
        _collection = context.Database.GetCollection<Payment>(context.Settings.PaymentsCollection);
    }

    public async Task<Payment?> GetByIdAsync(string id, CancellationToken cancellationToken)
    {
        var cursor = await _collection.FindAsync(p => p.Id == id, cancellationToken: cancellationToken);
        return await cursor.FirstOrDefaultAsync(cancellationToken);
    }

    public async Task<Payment?> GetByBookingIdAsync(string bookingId, CancellationToken cancellationToken)
    {
        var cursor = await _collection.FindAsync(p => p.BookingId == bookingId, cancellationToken: cancellationToken);
        return await cursor.FirstOrDefaultAsync(cancellationToken);
    }

    public async Task<List<Payment>> GetAllAsync(CancellationToken cancellationToken)
    {
        var cursor = await _collection.FindAsync(_ => true, cancellationToken: cancellationToken);
        return await cursor.ToListAsync(cancellationToken);
    }

    public async Task<List<Payment>> GetByUserIdAsync(string userId, CancellationToken cancellationToken)
    {
        var cursor = await _collection.FindAsync(p => p.UserId == userId, cancellationToken: cancellationToken);
        return await cursor.ToListAsync(cancellationToken);
    }

    public Task CreateAsync(Payment payment, CancellationToken cancellationToken)
        => _collection.InsertOneAsync(payment, cancellationToken: cancellationToken);

    public Task UpdateAsync(Payment payment, CancellationToken cancellationToken)
        => _collection.ReplaceOneAsync(p => p.Id == payment.Id, payment, cancellationToken: cancellationToken);
}
