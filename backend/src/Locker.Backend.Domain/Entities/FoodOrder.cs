using Locker.Backend.Domain.Enums;
using System;
using System.Collections.Generic;

namespace Locker.Backend.Domain.Entities;

public class FoodOrder : BaseEntity
{
    public Guid UserId { get; set; }
    public Guid RestaurantId { get; set; }
    public Guid LockerId { get; set; }
    public int SlotIndex { get; set; }
    
    public List<FoodOrderItem> Items { get; set; } = new();
    public decimal TotalAmount { get; set; }
    public Guid? PaymentId { get; set; }
    
    public FoodOrderStatus Status { get; set; }
    
    public string? DeliveryNotes { get; set; }
    public DateTime? DeliveredAt { get; set; }
    public DateTime? CompletedAt { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public bool IsDeleted { get; set; } = false;
}

public class FoodOrderItem
{
    public Guid MenuItemId { get; set; }
    public string Name { get; set; } = string.Empty;
    public int Quantity { get; set; }
    public decimal UnitPrice { get; set; }
    public string? Notes { get; set; }
}
