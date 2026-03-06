using Locker.Backend.Domain.Entities;

namespace Locker.Backend.Application.Interfaces;

public interface IPaymentRepository : IGenericRepository<Payment>
{
    Task<Payment?> GetByBookingIdAsync(string bookingId, CancellationToken cancellationToken);
    Task<List<Payment>> GetByUserIdAsync(string userId, CancellationToken cancellationToken);
}
