using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Mapping;
using Locker.Backend.Application.Models;
using Locker.Backend.Domain.Enums;
using MediatR;
using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.Orders.Commands.ConfirmOrder;

public record ConfirmOrderCommand(Guid OrderId, Guid UserId, string? Notes) : IRequest<OrderDto?>;

public class ConfirmOrderCommandHandler : IRequestHandler<ConfirmOrderCommand, OrderDto?>
{
    private readonly IOrderRepository _orderRepository;
    private readonly IPaymentRepository _paymentRepository;
    private readonly ILockerRepository _lockerRepository;
    private readonly OrderMapper _orderMapper;

    public ConfirmOrderCommandHandler(
        IOrderRepository orderRepository,
        IPaymentRepository paymentRepository,
        ILockerRepository lockerRepository,
        OrderMapper orderMapper)
    {
        _orderRepository = orderRepository;
        _paymentRepository = paymentRepository;
        _lockerRepository = lockerRepository;
        _orderMapper = orderMapper;
    }

    public async Task<OrderDto?> Handle(ConfirmOrderCommand request, CancellationToken cancellationToken)
    {
        var order = await _orderRepository.GetByIdAsync(request.OrderId, cancellationToken);
        if (order == null || order.UserId != request.UserId)
            return null;

        if (order.Status != OrderStatus.Initiated)
            return null;

        if (order.PaymentExpirationTime.HasValue && DateTime.UtcNow > order.PaymentExpirationTime.Value)
            return null;

        if (!order.PaymentId.HasValue)
            return null;

        var payment = await _paymentRepository.GetByIdAsync(order.PaymentId.Value, cancellationToken);
        if (payment == null || payment.Status != PaymentStatus.Completed)
            return null;

        order.Status = OrderStatus.Reserved;
        order.ReservedAt = DateTime.UtcNow;
        order.Notes = request.Notes ?? order.Notes;
        order.PaidAt = DateTime.UtcNow;

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
}
