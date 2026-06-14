namespace Locker.Backend.Domain.Enums;

public enum FoodOrderStatus
{
    PaymentRequired,
    Pending,
    Preparing,
    Delivering,
    DeliveredToLocker,
    Completed,
    Cancelled
}
