using Locker.Backend.Domain.Entities;
using Locker.Backend.Domain.Enums;
using Locker.Backend.Application.Interfaces; // Đảm bảo đã import IGenericRepository

namespace Locker.Backend.Application.Interfaces;

public interface IBookingRepository : IGenericRepository<Booking>
{
    // Các hàm cũ của bạn
    Task<List<Booking>> GetByUserIdAsync(Guid userId, CancellationToken cancellationToken);
    Task<List<Booking>> GetByStatusAsync(BookingStatus status, CancellationToken cancellationToken);
    Task<Booking?> GetActiveBySlotAsync(Guid lockerId, int slotIndex, CancellationToken cancellationToken);
    
    // THÊM HÀM NÀY VÀO ĐÂY:
    Task AddAsync(Booking booking, CancellationToken cancellationToken);
}