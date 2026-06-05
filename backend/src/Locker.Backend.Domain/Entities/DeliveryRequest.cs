using Locker.Backend.Domain.Enums;
using System;

namespace Locker.Backend.Domain.Entities;

public class DeliveryRequest : BaseEntity
{
    public Guid UserId { get; set; }
    
    public string SenderName { get; set; } = string.Empty;
    public string ReceiverPhone { get; set; } = string.Empty;
    
    public Guid LockerId { get; set; }
    public int SlotIndex { get; set; }
    public string PackageSize { get; set; } = string.Empty;
    
    public string TrackingCode { get; set; } = string.Empty;
    
    public DeliveryStatus Status { get; set; }
    
    public DateTime? DeliveredAt { get; set; }
    public DateTime? CompletedAt { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
