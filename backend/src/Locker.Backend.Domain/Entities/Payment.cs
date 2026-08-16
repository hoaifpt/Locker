using Locker.Backend.Domain.Enums;

namespace Locker.Backend.Domain.Entities;

public class Payment : BaseEntity
{
    public Guid BookingId { get; set; }
    public Guid OrderId { get; set; } 
    public Guid UserId { get; set; }
    public decimal Amount { get; set; }
    public PaymentStatus Status { get; set; } = PaymentStatus.Pending;
    public string Method { get; set; } = string.Empty;
    public string? TransactionId { get; set; }
    public string? SepayCode { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? PaidAt { get; set; }
}
