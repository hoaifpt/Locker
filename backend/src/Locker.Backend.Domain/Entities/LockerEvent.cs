using System;

namespace Locker.Backend.Domain.Entities;

public class LockerEvent : BaseEntity
{
    public Guid LockerId { get; set; }
    public int SlotIndex { get; set; }
    public Guid? UserId { get; set; }
    public string EventType { get; set; } = string.Empty; // "Open", "Close", "Intrusion", "Maintenance"
    public string? ReferenceId { get; set; } // OrderId, BookingId
    public string? Notes { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
