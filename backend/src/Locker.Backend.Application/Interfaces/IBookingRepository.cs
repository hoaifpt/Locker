using Locker.Backend.Domain.Entities;
using Locker.Backend.Domain.Enums;

namespace Locker.Backend.Application.Interfaces;

public interface IBookingRepository : IGenericRepository<Booking>
{
    Task<List<Booking>> GetByUserIdAsync(Guid userId, CancellationToken cancellationToken);
    Task<List<Booking>> GetByStatusAsync(BookingStatus status, CancellationToken cancellationToken);
    Task<Booking?> GetActiveBySlotAsync(Guid lockerId, int slotIndex, CancellationToken cancellationToken);
}
