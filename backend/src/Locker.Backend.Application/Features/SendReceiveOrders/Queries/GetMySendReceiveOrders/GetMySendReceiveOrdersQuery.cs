using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Models;
using MediatR;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.SendReceiveOrders.Queries.GetMySendReceiveOrders;

public record GetMySendReceiveOrdersQuery(Guid UserId) : IRequest<List<SendReceiveOrderDto>>;

public class GetMySendReceiveOrdersQueryHandler : IRequestHandler<GetMySendReceiveOrdersQuery, List<SendReceiveOrderDto>>
{
    private readonly ISendReceiveOrderRepository _repository;

    public GetMySendReceiveOrdersQueryHandler(ISendReceiveOrderRepository repository)
    {
        _repository = repository;
    }

    public async Task<List<SendReceiveOrderDto>> Handle(GetMySendReceiveOrdersQuery request, CancellationToken cancellationToken)
    {
        var items = await _repository.GetBySenderIdAsync(request.UserId, cancellationToken);
        return items.Select(x => new SendReceiveOrderDto
        {
            Id = x.Id,
            SenderId = x.SenderId,
            ReceiverPhone = x.ReceiverPhone,
            LockerId = x.LockerId,
            SlotIndex = x.SlotIndex,
            Status = x.Status,
            Notes = x.Notes,
            CreatedAt = x.CreatedAt
        }).ToList();
    }
}
