namespace Locker.Backend.Domain.Enums;

public enum OrderStatus
{
    Initiated = 0,      // Vừa khởi tạo
    Reserved = 1,       // Đã giữ chỗ
    Paid = 2,           // Đã thanh toán
    Active = 3,         // Đang sử dụng
    Completed = 4,      // Hoàn thành
    Cancelled = 5       // Đã hủy
}
