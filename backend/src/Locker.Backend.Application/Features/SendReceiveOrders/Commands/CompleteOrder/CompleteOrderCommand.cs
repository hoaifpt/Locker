using Locker.Backend.Application.Interfaces;
using Locker.Backend.Domain.Enums;
using MediatR;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.SendReceiveOrders.Commands.CompleteOrder;

public record CompleteOrderCommand(Guid OrderId, Guid UserId) : IRequest<bool>;

public class CompleteOrderCommandHandler : IRequestHandler<CompleteOrderCommand, bool>
{
    private readonly ISendReceiveOrderRepository _repository;

    public CompleteOrderCommandHandler(ISendReceiveOrderRepository repository)
    {
        _repository = repository;
    }

    public async Task<bool> Handle(CompleteOrderCommand request, CancellationToken cancellationToken)
    {
        var order = await _repository.GetByIdAsync(request.OrderId, cancellationToken);
        if (order == null)
            return false;

        var isSender = order.SenderId == request.UserId;
        var isReceiver = order.ReceiverId.HasValue && order.ReceiverId.Value == request.UserId;
        if (!isSender && !isReceiver)
            return false;

        if (order.Status != SendReceiveStatus.Deposited)
            return false;

        order.Status = SendReceiveStatus.Received;
        order.ReceivedAt = DateTime.UtcNow;

        await _repository.UpdateAsync(order, cancellationToken);
        return true;
    }
}
