using Locker.Backend.Application.Interfaces;
using Locker.Backend.Domain.Entities;
using Locker.Backend.Domain.Enums;
using Locker.Backend.Infrastructure.Mongo;
using MongoDB.Driver;

namespace Locker.Backend.Infrastructure.Repositories;

public class BookingRepository : GenericRepository<Booking>, IBookingRepository
{
    public BookingRepository(MongoContext context)
        : base(context.Database.GetCollection<Booking>(context.Settings.BookingsCollection))
    {
    }

    public async Task<List<Booking>> GetByUserIdAsync(Guid userId, CancellationToken cancellationToken)
    {
        var cursor = await _collection.FindAsync(b => b.UserId == userId, cancellationToken: cancellationToken);
        return await cursor.ToListAsync(cancellationToken);
    }

    public async Task<List<Booking>> GetByStatusAsync(BookingStatus status, CancellationToken cancellationToken)
    {
        var cursor = await _collection.FindAsync(b => b.Status == status, cancellationToken: cancellationToken);
        return await cursor.ToListAsync(cancellationToken);
    }

    public async Task<Booking?> GetActiveBySlotAsync(Guid lockerId, int slotIndex, CancellationToken cancellationToken)
    {
        var cursor = await _collection.FindAsync(
            b => b.LockerId == lockerId && b.SlotIndex == slotIndex &&
                 (b.Status == BookingStatus.Pending || b.Status == BookingStatus.Active),
            cancellationToken: cancellationToken);
        return await cursor.FirstOrDefaultAsync(cancellationToken);
    }

    public async Task AddAsync(Booking booking, CancellationToken cancellationToken)
    {
        // Nếu bạn dùng MongoDB (Collection là _collection):
        await _collection.InsertOneAsync(booking, null, cancellationToken);

        // HOẶC nếu bạn đang dùng Entity Framework (Context là _context):
        // await _context.Bookings.AddAsync(booking, cancellationToken);
    }
}
