using Locker.Backend.Application.Interfaces;
using Locker.Backend.Domain.Enums;
using MediatR;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.Orders.Commands.LinkPayment;

public record LinkPaymentCommand(Guid OrderId, Guid PaymentId) : IRequest<bool>;

public class LinkPaymentCommandHandler : IRequestHandler<LinkPaymentCommand, bool>
{
    private readonly IOrderRepository _orderRepository;
    private readonly IPaymentRepository _paymentRepository;

    public LinkPaymentCommandHandler(IOrderRepository orderRepository, IPaymentRepository paymentRepository)
    {
        _orderRepository = orderRepository;
        _paymentRepository = paymentRepository;
    }

    public async Task<bool> Handle(LinkPaymentCommand request, CancellationToken cancellationToken)
    {
        var order = await _orderRepository.GetByIdAsync(request.OrderId, cancellationToken);
        if (order == null) return false;

        var payment = await _paymentRepository.GetByIdAsync(request.PaymentId, cancellationToken);
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
}
