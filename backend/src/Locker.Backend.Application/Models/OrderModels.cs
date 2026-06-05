using Locker.Backend.Domain.Enums;

namespace Locker.Backend.Application.Models;

/// <summary>
/// Response DTO cho Order - hiển thị đầy đủ thông tin đơn hàng
/// </summary>
public class OrderDto
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public Guid LockerId { get; set; }
    public int SlotIndex { get; set; }
    public Guid PackageId { get; set; }

    public OrderStatus Status { get; set; }

    // Reservation Details
    public DateTime CheckInTime { get; set; }
    public DateTime CheckOutTime { get; set; }
    public int DurationHours { get; set; }

    // Pricing
    public decimal BaseRate { get; set; }
    public decimal Subtotal { get; set; }
    public decimal Taxes { get; set; }
    public decimal Discount { get; set; }
    public decimal TotalAmount { get; set; }

    // Payment
    public Guid? PaymentId { get; set; }

    // Mobile
    public string MobileNumber { get; set; } = string.Empty;

    // Metadata
    public string? CancellationReason { get; set; }
    public string? Notes { get; set; }

    // Timestamps
    public DateTime CreatedAt { get; set; }
    public DateTime? ReservedAt { get; set; }
    public DateTime? PaidAt { get; set; }
    public DateTime? StartedAt { get; set; }
    public DateTime? CompletedAt { get; set; }
    public DateTime? CancelledAt { get; set; }
}

/// <summary>
/// Tóm tắt nhanh thông tin đơn hàng (dùng cho danh sách)
/// </summary>
public class OrderSummaryDto
{
    public Guid Id { get; set; }
    public Guid LockerId { get; set; }
    public int SlotIndex { get; set; }
    public OrderStatus Status { get; set; }
    public decimal TotalAmount { get; set; }
    public DateTime CheckInTime { get; set; }
    public DateTime CheckOutTime { get; set; }
    public DateTime CreatedAt { get; set; }
}

/// <summary>
/// Request tạo đơn hàng mới (bước 1: Khởi tạo)
/// </summary>
public class CreateOrderRequest
{
    public Guid LockerId { get; set; }
    public int SlotIndex { get; set; }
    public Guid PackageId { get; set; }
    public string MobileNumber { get; set; } = string.Empty;
    public DateTime CheckInTime { get; set; }
    public int DurationHours { get; set; }
    public string? CouponCode { get; set; }
    public string? Notes { get; set; }
}

/// <summary>
/// Request xác nhận giữ chỗ sau khi thanh toán (bước 2)
/// </summary>
public class ConfirmOrderRequest
{
    public string? Notes { get; set; }
}

/// <summary>
/// Request kích hoạt/bắt đầu sử dụng (bước 4)
/// </summary>
public class ActivateOrderRequest
{
    public string AccountNumber { get; set; } = string.Empty;
}

/// <summary>
/// Request hoàn thành đơn hàng (bước 5)
/// </summary>
public class CompleteOrderRequest
{
    public string? Notes { get; set; }
}

/// <summary>
/// Request hủy đơn hàng
/// </summary>
public class CancelOrderRequest
{
    public string? CancellationReason { get; set; }
}

/// <summary>
/// Request gia hạn thêm thời gian cho đơn hàng
/// </summary>
public class ExtendOrderRequest
{
    public int AdditionalHours { get; set; }
}

/// <summary>
/// Request xác nhận thanh toán cho đơn hàng (bước 3)
/// </summary>
public class SetOrderPinRequest
{
    public string Pin { get; set; } = string.Empty;
}

/// <summary>
/// DTO hiển thị các khoang trống có sẵn
/// </summary>
public class AvailableSlotDto
{
    public Guid LockerId { get; set; }
    public string LockerName { get; set; } = string.Empty;
    public string Location { get; set; } = string.Empty;
    public int SlotIndex { get; set; }
    public string PackageSize { get; set; } = string.Empty;
    public decimal PricePerHour { get; set; }
}

/// <summary>
/// DTO xác nhận mỗi bước trong quy trình đặt hàng
/// </summary>
public class OrderConfirmationDto
{
    public Guid OrderId { get; set; }
    public OrderStatus Status { get; set; }
    public decimal TotalAmount { get; set; }
    public DateTime CheckInTime { get; set; }
    public DateTime CheckOutTime { get; set; }
    public DateTime ExpirationTime { get; set; } // Thời hạn thanh toán
    public string? Message { get; set; }
}
