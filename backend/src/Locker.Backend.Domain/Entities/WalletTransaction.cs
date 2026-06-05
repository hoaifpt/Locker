using Locker.Backend.Domain.Enums;
using System;

namespace Locker.Backend.Domain.Entities;

public class WalletTransaction : BaseEntity
{
    public Guid UserId { get; set; }
    public decimal Amount { get; set; }
    public TransactionType Type { get; set; }
    public TransactionStatus Status { get; set; }
    public string? Description { get; set; }
    public string? ReferenceId { get; set; } // OrderId, PaymentId
    public Guid? RelatedUserId { get; set; } // Receiver in Transfer
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
}
