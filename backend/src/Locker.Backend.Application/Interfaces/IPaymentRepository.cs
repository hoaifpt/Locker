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

    /// <summary>
    /// Atomically transitions a payment from <see cref="PaymentStatus.Pending"/> to
    /// <see cref="PaymentStatus.Completed"/>. Returns the updated payment when this
    /// caller owned the transition; returns <c>null</c> when another concurrent caller
    /// has already completed the payment.
    /// </summary>
    Task<Payment?> TryCompletePendingAsync(
        Guid paymentId,
        string transactionId,
        DateTime paidAt,
        CancellationToken cancellationToken);
}