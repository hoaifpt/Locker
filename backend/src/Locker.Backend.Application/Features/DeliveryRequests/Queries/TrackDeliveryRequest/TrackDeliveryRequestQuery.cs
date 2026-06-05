using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Models;
using MediatR;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.DeliveryRequests.Queries.TrackDeliveryRequest;

public record TrackDeliveryRequestQuery(string TrackingCode) : IRequest<DeliveryRequestDto?>;

public class TrackDeliveryRequestQueryHandler : IRequestHandler<TrackDeliveryRequestQuery, DeliveryRequestDto?>
{
    private readonly IDeliveryRequestRepository _repository;

    public TrackDeliveryRequestQueryHandler(IDeliveryRequestRepository repository)
    {
        _repository = repository;
    }

    public async Task<DeliveryRequestDto?> Handle(TrackDeliveryRequestQuery request, CancellationToken cancellationToken)
    {
        var item = await _repository.GetByTrackingCodeAsync(request.TrackingCode, cancellationToken);
        if (item == null) return null;
        
        return new DeliveryRequestDto
        {
            Id = item.Id,
            UserId = item.UserId,
            SenderName = item.SenderName,
            ReceiverPhone = item.ReceiverPhone,
            LockerId = item.LockerId,
            SlotIndex = item.SlotIndex,
            PackageSize = item.PackageSize,
            TrackingCode = item.TrackingCode,
            Status = item.Status,
            CreatedAt = item.CreatedAt
        };
    }
}
