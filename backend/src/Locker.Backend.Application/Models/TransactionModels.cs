using Locker.Backend.Domain.Enums;

namespace Locker.Backend.Application.Models;

public class CreateTransactionRequest
{
    public string LockerId { get; set; } = string.Empty;
    public TransactionType Type { get; set; }
    
    // For SendReceivePackage
    public string? PackageId { get; set; }
    public string? ReceiverIdentifier { get; set; } // phone or email
    
    // For Storage
    public DateTime? ExpectedEndTime { get; set; }
    
    // For FoodDelivery
    public string? RestaurantName { get; set; }
    public List<OrderItemDto>? FoodItems { get; set; }
}

public class OrderItemDto
{
    public string Name { get; set; } = string.Empty;
    public int Quantity { get; set; } = 1;
    public decimal Price { get; set; }
}

public class TransactionDto
{
    public string Id { get; set; } = string.Empty;
    public string LockerId { get; set; } = string.Empty;
    public string SlotId { get; set; } = string.Empty;
    public TransactionType Type { get; set; }
    public TransactionStatus Status { get; set; }
    public decimal TotalAmount { get; set; }
    public DateTime CreatedAt { get; set; }
}