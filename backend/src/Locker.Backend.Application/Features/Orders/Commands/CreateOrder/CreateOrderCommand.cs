using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Models;
using Locker.Backend.Domain.Entities;
using Locker.Backend.Domain.Enums;
using MediatR;
using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using OrderEntity = Locker.Backend.Domain.Entities.Order;

namespace Locker.Backend.Application.Features.Orders.Commands.CreateOrder;

public record CreateOrderCommand(
    Guid UserId,
    Guid LockerId,
    int SlotIndex,
    Guid PackageId,
    DateTime CheckInTime,
    int DurationHours,
    string MobileNumber,
    string? Notes) : IRequest<OrderConfirmationDto?>;

public class CreateOrderCommandHandler : IRequestHandler<CreateOrderCommand, OrderConfirmationDto?>
{
    private readonly IOrderRepository _orderRepository;
    private readonly ILockerRepository _lockerRepository;
    private readonly IPackageRepository _packageRepository;

    private const int PaymentExpirationMinutes = 15;
    private const int MaxConcurrentOrders = 5;
    private const int MaxDurationHours = 7 * 24; // 7 days
    private const int MinDurationHours = 1;

    public CreateOrderCommandHandler(
        IOrderRepository orderRepository,
        ILockerRepository lockerRepository,
        IPackageRepository packageRepository)
    {
        _orderRepository = orderRepository;
        _lockerRepository = lockerRepository;
        _packageRepository = packageRepository;
    }

    public async Task<OrderConfirmationDto?> Handle(CreateOrderCommand request, CancellationToken cancellationToken)
    {
        var locker = await _lockerRepository.GetByIdAsync(request.LockerId, cancellationToken);
        if (locker == null)
            return null;

        var slot = locker.Slots.FirstOrDefault(s => s.Index == request.SlotIndex);
        if (slot == null || slot.Status != LockerSlotStatus.Available)
            return null;

        var package = await _packageRepository.GetByIdAsync(request.PackageId, cancellationToken);
        if (package == null || !package.IsActive)
            return null;

        if (request.DurationHours < MinDurationHours || request.DurationHours > MaxDurationHours)
            return null;

        var checkOutTime = request.CheckInTime.AddHours(request.DurationHours);

        var conflictingOrders = await _orderRepository.GetConflictingOrdersAsync(
            request.LockerId,
            request.SlotIndex,
            request.CheckInTime,
            checkOutTime,
            cancellationToken);

        if (conflictingOrders.Count > 0)
            return null;

        var activeUserOrders = await _orderRepository.GetByUserIdAndStatusAsync(
            request.UserId,
            OrderStatus.Active,
            cancellationToken);

        if (activeUserOrders.Count >= MaxConcurrentOrders)
            return null;

        var subtotal = package.PricePerHour * request.DurationHours;
        var taxes = subtotal * 0.1m; // 10% tax
        var discount = 0m;

        var totalAmount = subtotal + taxes - discount;

        var order = new OrderEntity
        {
            UserId = request.UserId,
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
}
