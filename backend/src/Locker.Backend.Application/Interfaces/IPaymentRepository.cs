using Locker.Backend.Domain.Entities;

namespace Locker.Backend.Application.Interfaces;

public interface IPaymentRepository : IGenericRepository<Payment>
{
    Task<Payment?> GetByBookingIdAsync(
        Guid bookingId,
        CancellationToken cancellationToken);

    Task<List<Payment>> GetByUserIdAsync(
        Guid userId,
        CancellationToken cancellationToken);

    Task<Payment?> GetBySepayCodeAsync(
        string sepayCode,
        CancellationToken cancellationToken);
}