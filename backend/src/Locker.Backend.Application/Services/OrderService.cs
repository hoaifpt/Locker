using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Mapping;
using Locker.Backend.Application.Models;
using Locker.Backend.Domain.Entities;
using Locker.Backend.Domain.Enums;

namespace Locker.Backend.Application.Services;

public class OrderService
{
    private readonly IOrderRepository _orderRepository;
    private readonly ILockerRepository _lockerRepository;
    private readonly IPackageRepository _packageRepository;
    private readonly IPaymentRepository _paymentRepository;
    private readonly IPasswordHasher _passwordHasher;
    private readonly OrderMapper _orderMapper;

    // Business rule constants
    private const int PaymentExpirationMinutes = 15;
    private const int TransitionBufferMinutes = 10;
    private const int MaxConcurrentOrders = 5;
    private const int MaxDurationHours = 7 * 24; // 7 days
    private const int MinDurationHours = 1;

    public OrderService(
        IOrderRepository orderRepository,
        ILockerRepository lockerRepository,
        IPackageRepository packageRepository,
        IPaymentRepository paymentRepository,
        IPasswordHasher passwordHasher,
        OrderMapper orderMapper)
    {
        _orderRepository = orderRepository;
        _lockerRepository = lockerRepository;
        _packageRepository = packageRepository;
        _paymentRepository = paymentRepository;
        _passwordHasher = passwordHasher;
        _orderMapper = orderMapper;
    }

    #region Retrieve Operations

    /// <summary>
    /// Lấy đơn hàng theo ID
    /// </summary>
    public async Task<OrderDto?> GetByIdAsync(string id, CancellationToken cancellationToken)
    {
        var order = await _orderRepository.GetByIdAsync(id, cancellationToken);
        return order == null ? null : _orderMapper.Map(order);
    }

    /// <summary>
    /// Lấy danh sách đơn hàng của người dùng
    /// </summary>
    public async Task<List<OrderSummaryDto>> GetMyOrdersAsync(string userId, OrderStatus? status, CancellationToken cancellationToken)
    {
        List<Order> orders;

        if (status.HasValue)
        {
            orders = await _orderRepository.GetByUserIdAndStatusAsync(userId, status.Value, cancellationToken);
        }
        else
        {
            orders = await _orderRepository.GetByUserIdAsync(userId, cancellationToken);
        }

        return orders.Select(_orderMapper.MapToSummary).ToList();
    }

    /// <summary>
    /// Lấy tất cả đơn hàng (Admin)
    /// </summary>
    public async Task<List<OrderDto>> GetAllOrdersAsync(CancellationToken cancellationToken)
    {
        var orders = await _orderRepository.GetAllAsync(cancellationToken);
        return orders.Select(_orderMapper.Map).ToList();
    }

    #endregion

    #region Payment Link

    public async Task<bool> LinkPaymentAsync(string orderId, string paymentId, CancellationToken cancellationToken)
    {
        var order = await _orderRepository.GetByIdAsync(orderId, cancellationToken);
        if (order == null) return false;

        var payment = await _paymentRepository.GetByIdAsync(paymentId, cancellationToken);
        if (payment == null) return false;

        order.PaymentId = payment.Id;
        if (payment.Status == PaymentStatus.Completed)
        {
            order.Status = OrderStatus.Paid;
            order.PaidAt = payment.PaidAt ?? DateTime.UtcNow;
        }

        await _orderRepository.UpdateAsync(order, cancellationToken);
        return true;
    }

    #endregion

    #region Create & Reserve

    /// <summary>
    /// Bước 1: Khởi tạo đơn hàng và giữ chỗ
    /// Kiểm tra tất cả điều kiện, tính giá, và tạo Order mới
    /// </summary>
    public async Task<OrderConfirmationDto?> CreateAsync(
        string userId,
        CreateOrderRequest request,
        CancellationToken cancellationToken)
    {
        // Validation: Kiểm tra locker có tồn tại không
        var locker = await _lockerRepository.GetByIdAsync(request.LockerId, cancellationToken);
        if (locker == null)
            return null;

        // Validation: Kiểm tra slot tồn tại và có trống không
        var slot = locker.Slots.FirstOrDefault(s => s.Index == request.SlotIndex);
        if (slot == null || slot.Status != LockerSlotStatus.Available)
            return null;

        // Validation: Kiểm tra package tồn tại và đang hoạt động
        var package = await _packageRepository.GetByIdAsync(request.PackageId, cancellationToken);
        if (package == null || !package.IsActive)
            return null;

        // Validation: Kiểm tra thời gian hợp lệ
        if (request.DurationHours < MinDurationHours || request.DurationHours > MaxDurationHours)
            return null;

        var checkOutTime = request.CheckInTime.AddHours(request.DurationHours);

        // Validation: Kiểm tra slot không có đơn hàng xung đột
        var conflictingOrders = await _orderRepository.GetConflictingOrdersAsync(
            request.LockerId,
            request.SlotIndex,
            request.CheckInTime,
            checkOutTime,
            cancellationToken);

        if (conflictingOrders.Count > 0)
            return null;

        // Validation: Kiểm tra người dùng không vượt quá số đơn đặt hàng đồng thời
        var activeUserOrders = await _orderRepository.GetByUserIdAndStatusAsync(
            userId,
            OrderStatus.Active,
            cancellationToken);

        if (activeUserOrders.Count >= MaxConcurrentOrders)
            return null;

        // Tính giá
        var subtotal = package.PricePerHour * request.DurationHours;
        var taxes = subtotal * 0.1m; // 10% tax
        var discount = 0m;

        // TODO: Áp dụng mã khuyến mãi nếu có

        var totalAmount = subtotal + taxes - discount;

        // Tạo Order mới
        var order = new Order
        {
            UserId = userId,
            LockerId = request.LockerId,
            SlotIndex = request.SlotIndex,
            PackageId = request.PackageId,
            MobileNumber = request.MobileNumber,
            Status = OrderStatus.Initiated,
            CheckInTime = request.CheckInTime,
            CheckOutTime = checkOutTime,
            DurationHours = request.DurationHours,
            BaseRate = package.PricePerHour,
            Subtotal = subtotal,
            Taxes = taxes,
            Discount = discount,
            TotalAmount = totalAmount,
            Notes = request.Notes,
            CreatedAt = DateTime.UtcNow
        };

        // Cập nhật trạng thái slot thành Pending
        slot.Status = LockerSlotStatus.Pending;
        slot.BookingId = order.Id;

        await _orderRepository.CreateAsync(order, cancellationToken);
        await _lockerRepository.UpdateAsync(locker, cancellationToken);

        var expirationTime = DateTime.UtcNow.AddMinutes(PaymentExpirationMinutes);

        return new OrderConfirmationDto
        {
            OrderId = order.Id,
            Status = order.Status,
            TotalAmount = order.TotalAmount,
            CheckInTime = order.CheckInTime,
            CheckOutTime = order.CheckOutTime,
            ExpirationTime = expirationTime,
            Message = $"Vui lòng thanh toán trước {expirationTime:dd/MM/yyyy HH:mm}"
        };
    }

    #endregion

    #region Confirm & Payment

    /// <summary>
    /// Bước 2: Xác nhận giữ chỗ (sau khi thanh toán thành công)
    /// </summary>
    public async Task<OrderDto?> ConfirmAsync(
        string orderId,
        string userId,
        ConfirmOrderRequest request,
        CancellationToken cancellationToken)
    {
        var order = await _orderRepository.GetByIdAsync(orderId, cancellationToken);
        if (order == null || order.UserId != userId)
            return null;

        if (order.Status != OrderStatus.Initiated)
            return null;

        // Kiểm tra payment đã complete
        if (string.IsNullOrEmpty(order.PaymentId))
            return null;

        var payment = await _paymentRepository.GetByIdAsync(order.PaymentId, cancellationToken);
        if (payment == null || payment.Status != PaymentStatus.Completed)
            return null;

        // Cập nhật trạng thái Order
        order.Status = OrderStatus.Reserved;
        order.ReservedAt = DateTime.UtcNow;
        order.Notes = request.Notes ?? order.Notes;
        order.PaidAt = DateTime.UtcNow;

        // Cập nhật slot theo model slot hiện tại
        var locker = await _lockerRepository.GetByIdAsync(order.LockerId, cancellationToken);
        if (locker == null)
            return null;

        var slot = locker.Slots.FirstOrDefault(s => s.Index == order.SlotIndex);
        if (slot == null)
            return null;

        slot.Status = LockerSlotStatus.Pending;
        slot.BookingId = order.Id;

        await _orderRepository.UpdateAsync(order, cancellationToken);
        await _lockerRepository.UpdateAsync(locker, cancellationToken);

        return _orderMapper.Map(order);
    }

    /// <summary>
    /// Bước 3: Đặt mã PIN để mở khoang (sau khi thanh toán)
    /// </summary>
    public async Task<bool> SetPinAsync(
        string orderId,
        string userId,
        SetOrderPinRequest request,
        CancellationToken cancellationToken)
    {
        var order = await _orderRepository.GetByIdAsync(orderId, cancellationToken);
        if (order == null || order.UserId != userId)
            return false;

        // Only allow PIN setting for Reserved orders (after payment)
        if (order.Status != OrderStatus.Reserved)
            return false;

        // Hash the PIN
        order.PinHash = _passwordHasher.Hash(request.Pin);

        await _orderRepository.UpdateAsync(order, cancellationToken);
        return true;
    }

    #endregion

    #region Activate & Access

    /// <summary>
    /// Bước 4: Kích hoạt đơn hàng (người dùng đến lấy hàng)
    /// </summary>
    public async Task<OrderDto?> ActivateAsync(
        string orderId,
        string userId,
        CancellationToken cancellationToken)
    {
        var order = await _orderRepository.GetByIdAsync(orderId, cancellationToken);
        if (order == null || order.UserId != userId)
            return null;

        // Can only activate Reserved or Paid orders
        if (order.Status != OrderStatus.Reserved && order.Status != OrderStatus.Paid)
            return null;

        // Kiểm tra CheckInTime có hợp lệ không (cho phép 30 phút sớm)
        var now = DateTime.UtcNow;
        if (now < order.CheckInTime.AddMinutes(-30))
            return null; // Quá sớm

        if (now > order.CheckOutTime)
            return null; // Quá muộn

        order.Status = OrderStatus.Active;
        order.StartedAt = now;

        // Cập nhật slot thành Occupied
        var locker = await _lockerRepository.GetByIdAsync(order.LockerId, cancellationToken);
        if (locker == null)
            return null;

        var slot = locker.Slots.FirstOrDefault(s => s.Index == order.SlotIndex);
        if (slot == null)
            return null;

        slot.Status = LockerSlotStatus.Active;

        await _orderRepository.UpdateAsync(order, cancellationToken);
        await _lockerRepository.UpdateAsync(locker, cancellationToken);

        // TODO: Gửi lệnh MQTT mở khoang

        return _orderMapper.Map(order);
    }

    #endregion

    #region Complete

    /// <summary>
    /// Bước 5: Hoàn thành đơn hàng (người dùng đã lấy hàng)
    /// </summary>
    public async Task<OrderDto?> CompleteAsync(
        string orderId,
        string userId,
        CompleteOrderRequest request,
        CancellationToken cancellationToken)
    {
        var order = await _orderRepository.GetByIdAsync(orderId, cancellationToken);
        if (order == null || order.UserId != userId)
            return null;

        if (order.Status != OrderStatus.Active)
            return null;

        order.Status = OrderStatus.Completed;
        order.CompletedAt = DateTime.UtcNow;
        order.Notes = request.Notes ?? order.Notes;

        // Cập nhật slot thành Available
        var locker = await _lockerRepository.GetByIdAsync(order.LockerId, cancellationToken);
        if (locker == null)
            return null;

        var slot = locker.Slots.FirstOrDefault(s => s.Index == order.SlotIndex);
        if (slot == null)
            return null;

        slot.Status = LockerSlotStatus.Available;
        slot.BookingId = null;

        await _orderRepository.UpdateAsync(order, cancellationToken);
        await _lockerRepository.UpdateAsync(locker, cancellationToken);

        // TODO: Gửi notification (Email/SMS/Push) về completion

        return _orderMapper.Map(order);
    }

    #endregion

    #region Cancel

    /// <summary>
    /// Hủy đơn hàng - áp dụng chính sách hoàn tiền
    /// </summary>
    public async Task<OrderDto?> CancelAsync(
        string orderId,
        string userId,
        CancelOrderRequest request,
        CancellationToken cancellationToken)
    {
        var order = await _orderRepository.GetByIdAsync(orderId, cancellationToken);
        if (order == null || order.UserId != userId)
            return null;

        // Không thể hủy đơn hàng đã hoàn thành hoặc đã hủy rồi
        if (order.Status == OrderStatus.Completed || order.Status == OrderStatus.Cancelled)
            return null;

        // Nếu đang sử dụng, không thể hủy
        if (order.Status == OrderStatus.Active)
            return null;

        order.Status = OrderStatus.Cancelled;
        order.CancelledAt = DateTime.UtcNow;
        order.CancellationReason = request.CancellationReason;

        // Giải phóng slot
        var locker = await _lockerRepository.GetByIdAsync(order.LockerId, cancellationToken);
        if (locker != null)
        {
            var slot = locker.Slots.FirstOrDefault(s => s.Index == order.SlotIndex);
            if (slot != null)
            {
                slot.Status = LockerSlotStatus.Available;
                slot.BookingId = null;
                await _lockerRepository.UpdateAsync(locker, cancellationToken);
            }
        }

        await _orderRepository.UpdateAsync(order, cancellationToken);

        // TODO: Tính toán hoàn tiền dựa trên chính sách
        // TODO: Gửi notification hủy

        return _orderMapper.Map(order);
    }

    #endregion

    #region Extend

    /// <summary>
    /// Gia hạn thêm thời gian cho đơn hàng (có tính phí bổ sung)
    /// </summary>
    public async Task<OrderDto?> ExtendAsync(
        string orderId,
        string userId,
        ExtendOrderRequest request,
        CancellationToken cancellationToken)
    {
        var order = await _orderRepository.GetByIdAsync(orderId, cancellationToken);
        if (order == null || order.UserId != userId)
            return null;

        // Chỉ có thể gia hạn khi đơn hàng đang Active hoặc Reserved
        if (order.Status != OrderStatus.Active && order.Status != OrderStatus.Reserved)
            return null;

        // Tính phí gia hạn
        var additionalFee = order.BaseRate * request.AdditionalHours;
        var oldCheckOutTime = order.CheckOutTime;

        order.CheckOutTime = order.CheckOutTime.AddHours(request.AdditionalHours);
        order.DurationHours += request.AdditionalHours;
        order.TotalAmount += additionalFee;

        await _orderRepository.UpdateAsync(order, cancellationToken);

        // TODO: Tạo payment mới cho phí gia hạn
        // TODO: Gửi notification về gia hạn

        return _orderMapper.Map(order);
    }

    #endregion

    #region Availability Check

    /// <summary>
    /// Kiểm tra các khoang trống có sẵn tại một vị trí và thời gian
    /// </summary>
    public async Task<List<AvailableSlotDto>> GetAvailableSlotsByLockerAsync(
        string lockerId,
        DateTime fromTime,
        DateTime toTime,
        CancellationToken cancellationToken)
    {
        var locker = await _lockerRepository.GetByIdAsync(lockerId, cancellationToken);
        if (locker == null)
            return new List<AvailableSlotDto>();

        var availableSlots = new List<AvailableSlotDto>();
        var activePackages = await _packageRepository.GetActiveAsync(cancellationToken);
        var defaultPackage = activePackages.FirstOrDefault();

        if (defaultPackage == null)
            return availableSlots;

        foreach (var slot in locker.Slots.Where(s => s.Status == LockerSlotStatus.Available))
        {
            // Kiểm tra slot có xung đột không
            var conflicts = await _orderRepository.GetConflictingOrdersAsync(
                lockerId,
                slot.Index,
                fromTime,
                toTime,
                cancellationToken);

            if (conflicts.Count == 0)
            {
                availableSlots.Add(new AvailableSlotDto
                {
                    LockerId = lockerId,
                    LockerName = locker.Name,
                    Location = locker.Location,
                    SlotIndex = slot.Index,
                    PackageSize = defaultPackage.Size,
                    PricePerHour = defaultPackage.PricePerHour
                });
            }
        }

        return availableSlots;
    }

    #endregion
}
