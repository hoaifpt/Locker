using Locker.Backend.Domain.Enums;

namespace Locker.Backend.Application.Models;

public class PaymentDto
{
    public string Id { get; set; } = string.Empty;
    public string BookingId { get; set; } = string.Empty;
    public string UserId { get; set; } = string.Empty;
    public decimal Amount { get; set; }
    public PaymentStatus Status { get; set; }
    public string Method { get; set; } = string.Empty;
    public string? TransactionId { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? PaidAt { get; set; }
}

public class CreatePaymentRequest
{
    public string BookingId { get; set; } = string.Empty;
    public string Method { get; set; } = string.Empty;
}

public class CompletePaymentRequest
{
    public string TransactionId { get; set; } = string.Empty;
}
