using Locker.Backend.Domain.Enums;

namespace Locker.Backend.Domain.Entities;

public class Booking : BaseEntity
{
    public Guid UserId { get; set; }
    public Guid LockerId { get; set; }
    public int SlotIndex { get; set; }
    public Guid PackageId { get; set; }
    public string MobileNumber { get; set; } = string.Empty;
    public string PinHash { get; set; } = string.Empty;
    public BookingStatus Status { get; set; } = BookingStatus.Pending;
    public decimal TotalAmount { get; set; }
    public Guid? PaymentId { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? StartedAt { get; set; }
    public DateTime? CompletedAt { get; set; }
}
