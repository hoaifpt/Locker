using Locker.Backend.Domain.Enums;
using System;

namespace Locker.Backend.Domain.Entities;

public class SendReceiveOrder : BaseEntity
{
    public Guid SenderId { get; set; }
    public Guid? ReceiverId { get; set; }
    public string ReceiverPhone { get; set; } = string.Empty;
    
    public Guid LockerId { get; set; }
    public int SlotIndex { get; set; }
    
    public string PinHash { get; set; } = string.Empty;
    
    public SendReceiveStatus Status { get; set; }
    
    public string? Notes { get; set; }
    
    public DateTime? DepositedAt { get; set; }
    public DateTime? ReceivedAt { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
