using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Models;
using MediatR;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.SendReceiveOrders.Queries.GetById;

public record GetByIdQuery(Guid OrderId, Guid UserId) : IRequest<SendReceiveOrderDto?>;

public class GetByIdQueryHandler : IRequestHandler<GetByIdQuery, SendReceiveOrderDto?>
{
    private readonly ISendReceiveOrderRepository _repository;

    public GetByIdQueryHandler(ISendReceiveOrderRepository repository)
    {
        _repository = repository;
    }

    public async Task<SendReceiveOrderDto?> Handle(GetByIdQuery request, CancellationToken cancellationToken)
    {
        var order = await _repository.GetByIdAsync(request.OrderId, cancellationToken);
        if (order == null || order.SenderId != request.UserId)
            return null;

        return new SendReceiveOrderDto
        {
            Id = order.Id,
            SenderId = order.SenderId,
            ReceiverPhone = order.ReceiverPhone,
            LockerId = order.LockerId,
            SlotIndex = order.SlotIndex,
            Status = order.Status,
            Notes = order.Notes,
            CreatedAt = order.CreatedAt
        };
    }
}
