using Locker.Backend.Domain.Entities;

namespace Locker.Backend.Application.Interfaces;

public interface IPaymentRepository
{
    Task<Payment?> GetByIdAsync(string id, CancellationToken cancellationToken);
    Task<Payment?> GetByBookingIdAsync(string bookingId, CancellationToken cancellationToken);
    Task<List<Payment>> GetAllAsync(CancellationToken cancellationToken);
    Task<List<Payment>> GetByUserIdAsync(string userId, CancellationToken cancellationToken);
    Task CreateAsync(Payment payment, CancellationToken cancellationToken);
    Task UpdateAsync(Payment payment, CancellationToken cancellationToken);
}
