namespace Locker.Backend.Application.Models;

public class PaymentStatusChangedEvent
{
    public Guid PaymentId { get; init; }
    public decimal Amount { get; init; }
    public string Status { get; init; } = string.Empty;
    public DateTime? PaidAt { get; init; }
    public string? TransactionId { get; init; }
}
