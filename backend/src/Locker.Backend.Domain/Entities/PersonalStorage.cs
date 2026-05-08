namespace Locker.Backend.Domain.Entities;

public class PersonalStorage : BaseEntity
{
    public string TransactionId { get; set; } = string.Empty;
    public string UserId { get; set; } = string.Empty;
    public DateTime ExpectedEndTime { get; set; }
    public bool IsOverdue { get; set; } = false;
    public decimal OverdueFee { get; set; } = 0;
}