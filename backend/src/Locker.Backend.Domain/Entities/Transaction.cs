using Locker.Backend.Domain.Enums;

namespace Locker.Backend.Domain.Entities;

public class Transaction : BaseEntity
{
    public string UserId { get; set; } = string.Empty;
    public string LockerId { get; set; } = string.Empty;
    public string SlotId { get; set; } = string.Empty;
    public TransactionType Type { get; set; }
    public TransactionStatus Status { get; set; } = TransactionStatus.Pending;
    public string? PackageId { get; set; } // Reference if it's SendReceivePackage
    public string? ReceiverIdentifier { get; set; } // Phone or email of receiver
    public string SenderPinHash { get; set; } = string.Empty;
    public string ReceiverPinHash { get; set; } = string.Empty;
    public decimal TotalAmount { get; set; }
    public string? PaymentId { get; set; }
    
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? StartedAt { get; set; }
    public DateTime? CompletedAt { get; set; }
    public DateTime? ExpiredAt { get; set; }
}