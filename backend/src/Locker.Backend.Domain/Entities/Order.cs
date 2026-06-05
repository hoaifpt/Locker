using Locker.Backend.Domain.Enums;

namespace Locker.Backend.Domain.Entities;

public class Order : BaseEntity
{
    public Guid UserId { get; set; }
    public Guid LockerId { get; set; }
    public int SlotIndex { get; set; }
    public Guid PackageId { get; set; }

    public OrderStatus Status { get; set; } = OrderStatus.Initiated;

    // Reservation Details
    public DateTime CheckInTime { get; set; }
    public DateTime CheckOutTime { get; set; }
    public int DurationHours { get; set; }

    // Pricing
    public decimal BaseRate { get; set; }
    public decimal Subtotal { get; set; }
    public decimal Taxes { get; set; }
    public decimal Discount { get; set; }
    public decimal TotalAmount { get; set; }

    // Payment
    public Guid? PaymentId { get; set; }

    // Access
    public string PinHash { get; set; } = string.Empty;
    public string MobileNumber { get; set; } = string.Empty;

    // Metadata
    public string? CancellationReason { get; set; }
    public string? Notes { get; set; }

    // Timestamps (UTC)
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? ReservedAt { get; set; }
    public DateTime? PaidAt { get; set; }
    public DateTime? StartedAt { get; set; }
    public DateTime? CompletedAt { get; set; }
    public DateTime? CancelledAt { get; set; }

    // For concurrency control
    public int Version { get; set; } = 1;
}
