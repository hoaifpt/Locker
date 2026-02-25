using Locker.Backend.Domain.Enums;

namespace Locker.Backend.Application.Models;

public class BookingDto
{
    public string Id { get; set; } = string.Empty;
    public string UserId { get; set; } = string.Empty;
    public string LockerId { get; set; } = string.Empty;
    public int SlotIndex { get; set; }
    public string PackageId { get; set; } = string.Empty;
    public string MobileNumber { get; set; } = string.Empty;
    public BookingStatus Status { get; set; }
    public decimal TotalAmount { get; set; }
    public string? PaymentId { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? StartedAt { get; set; }
    public DateTime? CompletedAt { get; set; }
}

public class CreateBookingRequest
{
    public string LockerId { get; set; } = string.Empty;
    public int SlotIndex { get; set; }
    public string PackageId { get; set; } = string.Empty;
    public string MobileNumber { get; set; } = string.Empty;
}

public class SetPinRequest
{
    public string Pin { get; set; } = string.Empty;
}

public class VerifyPinRequest
{
    public string Pin { get; set; } = string.Empty;
}
