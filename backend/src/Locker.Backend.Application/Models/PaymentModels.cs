using Locker.Backend.Domain.Enums;

namespace Locker.Backend.Application.Models;

public class PaymentDto
{
    public Guid Id { get; set; }
    public Guid BookingId { get; set; }
    public Guid OrderId { get; set; }
    public Guid UserId { get; set; }
    public decimal Amount { get; set; }
    public PaymentStatus Status { get; set; }
    public string Method { get; set; } = string.Empty;
    public string? TransactionId { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? PaidAt { get; set; }
}

public class CreatePaymentRequest
{
    public Guid BookingId { get; set; }
    public string Method { get; set; } = string.Empty;
}

public class CompletePaymentRequest
{
    public string TransactionId { get; set; } = string.Empty;
}

public class PaymentWebhookRequest
{
    public Guid PaymentId { get; set; }
    public string TransactionId { get; set; } = string.Empty;
    public bool IsSuccess { get; set; }
}
