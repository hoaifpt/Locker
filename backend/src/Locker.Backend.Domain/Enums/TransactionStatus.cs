namespace Locker.Backend.Domain.Enums;

public enum TransactionStatus
{
    Pending,
    Paid,
    InProgress,
    Completed,
    Canceled,
    Failed
}