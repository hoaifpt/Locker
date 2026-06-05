using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Models;
using Locker.Backend.Domain.Entities;
using Locker.Backend.Domain.Enums;
using MediatR;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.DeliveryRequests.Commands.CreateDeliveryRequest;

public record CreateDeliveryRequestCommand(
    Guid UserId,
    string SenderName,
    string ReceiverPhone,
    Guid LockerId,
    int SlotIndex,
    string PackageSize) : IRequest<DeliveryRequestDto?>;

public class CreateDeliveryRequestCommandHandler : IRequestHandler<CreateDeliveryRequestCommand, DeliveryRequestDto?>
{
    private readonly IDeliveryRequestRepository _repository;

    public CreateDeliveryRequestCommandHandler(IDeliveryRequestRepository repository)
    {
        _repository = repository;
    }

    public async Task<DeliveryRequestDto?> Handle(CreateDeliveryRequestCommand request, CancellationToken cancellationToken)
    {
        var trackingCode = $"TRK-{DateTime.UtcNow:yyyyMMddHHmmss}-{new Random().Next(1000, 9999)}";

        var item = new DeliveryRequest
        {
            UserId = request.UserId,
            SenderName = request.SenderName,
            ReceiverPhone = request.ReceiverPhone,
            LockerId = request.LockerId,
            SlotIndex = request.SlotIndex,
            PackageSize = request.PackageSize,
            TrackingCode = trackingCode,
            Status = DeliveryStatus.Pending
        };

        await _repository.CreateAsync(item, cancellationToken);

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
