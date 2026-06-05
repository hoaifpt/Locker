using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Models;
using MediatR;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.DeliveryRequests.Queries.GetMyDeliveryRequests;

public record GetMyDeliveryRequestsQuery(Guid UserId) : IRequest<List<DeliveryRequestDto>>;

public class GetMyDeliveryRequestsQueryHandler : IRequestHandler<GetMyDeliveryRequestsQuery, List<DeliveryRequestDto>>
{
    private readonly IDeliveryRequestRepository _repository;

    public GetMyDeliveryRequestsQueryHandler(IDeliveryRequestRepository repository)
    {
        _repository = repository;
    }

    public async Task<List<DeliveryRequestDto>> Handle(GetMyDeliveryRequestsQuery request, CancellationToken cancellationToken)
    {
        var items = await _repository.GetByUserIdAsync(request.UserId, cancellationToken);
        return items.Select(x => new DeliveryRequestDto
        {
            Id = x.Id,
            UserId = x.UserId,
            SenderName = x.SenderName,
            ReceiverPhone = x.ReceiverPhone,
            LockerId = x.LockerId,
            SlotIndex = x.SlotIndex,
            PackageSize = x.PackageSize,
            TrackingCode = x.TrackingCode,
            Status = x.Status,
            CreatedAt = x.CreatedAt
        }).ToList();
    }
}
