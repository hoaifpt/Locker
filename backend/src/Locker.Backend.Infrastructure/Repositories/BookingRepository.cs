using Locker.Backend.Application.Interfaces;
using Locker.Backend.Domain.Entities;
using Locker.Backend.Domain.Enums;
using Locker.Backend.Infrastructure.Mongo;
using MongoDB.Driver;

namespace Locker.Backend.Infrastructure.Repositories;

public class BookingRepository : IBookingRepository
{
    private readonly IMongoCollection<Booking> _collection;

    public BookingRepository(MongoContext context)
    {
        _collection = context.Database.GetCollection<Booking>(context.Settings.BookingsCollection);
    }

    public async Task<Booking?> GetByIdAsync(string id, CancellationToken cancellationToken)
    {
        var cursor = await _collection.FindAsync(b => b.Id == id, cancellationToken: cancellationToken);
        return await cursor.FirstOrDefaultAsync(cancellationToken);
    }

    public async Task<List<Booking>> GetAllAsync(CancellationToken cancellationToken)
    {
        var cursor = await _collection.FindAsync(_ => true, cancellationToken: cancellationToken);
        return await cursor.ToListAsync(cancellationToken);
    }

    public async Task<List<Booking>> GetByUserIdAsync(string userId, CancellationToken cancellationToken)
    {
        var cursor = await _collection.FindAsync(b => b.UserId == userId, cancellationToken: cancellationToken);
        return await cursor.ToListAsync(cancellationToken);
    }

    public async Task<List<Booking>> GetByStatusAsync(BookingStatus status, CancellationToken cancellationToken)
    {
        var cursor = await _collection.FindAsync(b => b.Status == status, cancellationToken: cancellationToken);
        return await cursor.ToListAsync(cancellationToken);
    }

    public async Task<Booking?> GetActiveBySlotAsync(string lockerId, int slotIndex, CancellationToken cancellationToken)
    {
        var cursor = await _collection.FindAsync(
            b => b.LockerId == lockerId && b.SlotIndex == slotIndex &&
                 (b.Status == BookingStatus.Pending || b.Status == BookingStatus.Active),
            cancellationToken: cancellationToken);
        return await cursor.FirstOrDefaultAsync(cancellationToken);
    }

    public Task CreateAsync(Booking booking, CancellationToken cancellationToken)
        => _collection.InsertOneAsync(booking, cancellationToken: cancellationToken);

    public Task UpdateAsync(Booking booking, CancellationToken cancellationToken)
        => _collection.ReplaceOneAsync(b => b.Id == booking.Id, booking, cancellationToken: cancellationToken);
}
