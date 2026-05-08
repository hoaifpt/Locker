using Locker.Backend.Domain.Enums;

namespace Locker.Backend.Domain.Entities;

public class LockerSlot : BaseEntity
{
    public string LockerId { get; set; } = string.Empty;
    public int Index { get; set; }
    public string Size { get; set; } = "S"; // S, M, L
    public LockerSlotStatus Status { get; set; } = LockerSlotStatus.Available;
    public string? ActiveTransactionId { get; set; }
    
    // For backward compatibility during migration from old Booking system
    public string? BookingId { get; set; }
}
