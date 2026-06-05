using Locker.Backend.Domain.Enums;

namespace Locker.Backend.Application.Models;

public class BookingDto
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public Guid LockerId { get; set; }
    public int SlotIndex { get; set; }
    public Guid PackageId { get; set; }
    public string MobileNumber { get; set; } = string.Empty;
    public BookingStatus Status { get; set; }
    public decimal TotalAmount { get; set; }
    public Guid? PaymentId { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? StartedAt { get; set; }
    public DateTime? CompletedAt { get; set; }
}

public class CreateBookingRequest
{
    public Guid LockerId { get; set; }
    public int SlotIndex { get; set; }
    public Guid PackageId { get; set; }
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
