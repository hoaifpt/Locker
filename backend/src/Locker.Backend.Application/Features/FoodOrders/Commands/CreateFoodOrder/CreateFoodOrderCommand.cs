using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Models;
using Locker.Backend.Domain.Entities;
using Locker.Backend.Domain.Enums;
using MediatR;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.FoodOrders.Commands.CreateFoodOrder;

public class CreateFoodOrderItemRequest
{
    public Guid MenuItemId { get; set; }
    public int Quantity { get; set; }
    public string? Notes { get; set; }
}

public record CreateFoodOrderCommand(
    Guid UserId,
    Guid RestaurantId,
    Guid LockerId,
    int SlotIndex,
    List<CreateFoodOrderItemRequest> Items,
    string? DeliveryNotes) : IRequest<FoodOrderDto?>;

public class CreateFoodOrderCommandHandler : IRequestHandler<CreateFoodOrderCommand, FoodOrderDto?>
{
    private readonly IFoodOrderRepository _orderRepository;
    private readonly IMenuItemRepository _menuItemRepository;
    private readonly ILockerRepository _lockerRepository;
    private readonly IPaymentRepository _paymentRepository;

    public CreateFoodOrderCommandHandler(
        IFoodOrderRepository orderRepository,
        IMenuItemRepository menuItemRepository,
        ILockerRepository lockerRepository,
        IPaymentRepository paymentRepository)
    {
        _orderRepository = orderRepository;
        _menuItemRepository = menuItemRepository;
        _lockerRepository = lockerRepository;
        _paymentRepository = paymentRepository;
    }

    public async Task<FoodOrderDto?> Handle(CreateFoodOrderCommand request, CancellationToken cancellationToken)
    {
        var locker = await _lockerRepository.GetByIdAsync(request.LockerId, cancellationToken);
        if (locker == null) return null;

        var slot = locker.Slots.FirstOrDefault(s => s.Index == request.SlotIndex);
        if (slot == null || slot.Status != LockerSlotStatus.Available)
            return null;

        decimal totalAmount = 0;
        var orderItems = new List<FoodOrderItem>();

        foreach (var reqItem in request.Items)
        {
            var menu = await _menuItemRepository.GetByIdAsync(reqItem.MenuItemId, cancellationToken);
            if (menu == null || !menu.IsAvailable || menu.RestaurantId != request.RestaurantId)
                return null;

            totalAmount += menu.Price * reqItem.Quantity;
            orderItems.Add(new FoodOrderItem
            {
                MenuItemId = menu.Id,
                Name = menu.Name,
                Quantity = reqItem.Quantity,
                UnitPrice = menu.Price,
                Notes = reqItem.Notes
            });
        }

        var order = new FoodOrder
        {
            UserId = request.UserId,
            RestaurantId = request.RestaurantId,
            LockerId = request.LockerId,
            SlotIndex = request.SlotIndex,
            Items = orderItems,
            TotalAmount = totalAmount,
            Status = FoodOrderStatus.PaymentRequired,
            DeliveryNotes = request.DeliveryNotes
        };

        await _orderRepository.CreateAsync(order, cancellationToken);

        var payment = new Payment
        {
            BookingId = order.Id,
            UserId = request.UserId,
            Amount = totalAmount,
            Method = "Pending",
            Status = PaymentStatus.Pending,
            CreatedAt = DateTime.UtcNow
        };

        await _paymentRepository.CreateAsync(payment, cancellationToken);
        order.PaymentId = payment.Id;
        await _orderRepository.UpdateAsync(order, cancellationToken);

        slot.Status = LockerSlotStatus.Pending;
        await _lockerRepository.UpdateAsync(locker, cancellationToken);

        return new FoodOrderDto
        {
            Id = order.Id,
            RestaurantId = order.RestaurantId,
            LockerId = order.LockerId,
            SlotIndex = order.SlotIndex,
            TotalAmount = order.TotalAmount,
            Status = order.Status,
            DeliveryNotes = order.DeliveryNotes,
            CreatedAt = order.CreatedAt,
            Items = order.Items.Select(i => new FoodOrderItemDto
            {
                MenuItemId = i.MenuItemId,
                Name = i.Name,
                Quantity = i.Quantity,
                UnitPrice = i.UnitPrice,
                Notes = i.Notes
            }).ToList()
        };
    }
}
