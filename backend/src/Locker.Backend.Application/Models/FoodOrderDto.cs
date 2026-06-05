using Locker.Backend.Domain.Enums;
using System;
using System.Collections.Generic;

namespace Locker.Backend.Application.Models;

public class FoodOrderDto
{
    public Guid Id { get; set; }
    public Guid RestaurantId { get; set; }
    public Guid LockerId { get; set; }
    public int SlotIndex { get; set; }
    public List<FoodOrderItemDto> Items { get; set; } = new();
    public decimal TotalAmount { get; set; }
    public FoodOrderStatus Status { get; set; }
    public string? DeliveryNotes { get; set; }
    public DateTime CreatedAt { get; set; }
}

public class FoodOrderItemDto
{
    public Guid MenuItemId { get; set; }
    public string Name { get; set; } = string.Empty;
    public int Quantity { get; set; }
    public decimal UnitPrice { get; set; }
    public string? Notes { get; set; }
}
