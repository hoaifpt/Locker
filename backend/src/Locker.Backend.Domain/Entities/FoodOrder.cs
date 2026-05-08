namespace Locker.Backend.Domain.Entities;

public class FoodOrder : BaseEntity
{
    public string TransactionId { get; set; } = string.Empty;
    public string UserId { get; set; } = string.Empty;
    public string RestaurantName { get; set; } = string.Empty;
    public string ShipperId { get; set; } = string.Empty;
    public List<OrderItem> Items { get; set; } = new();
    public decimal FoodTotal { get; set; }
}

public class OrderItem
{
    public string Name { get; set; } = string.Empty;
    public int Quantity { get; set; } = 1;
    public decimal Price { get; set; }
}