using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Models;
using Locker.Backend.Domain.Entities;
using Locker.Backend.Domain.Enums;
using MediatR;
using System;
using System.Security.Cryptography;
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
    private readonly ILockerEventRepository _lockerEventRepository;
    private readonly ILockerRepository _lockerRepository;
    private readonly IRealtimeNotificationService _notificationService;
    private readonly IIdentityService _identityService;

    public CreateDeliveryRequestCommandHandler(
        IDeliveryRequestRepository repository,
        ILockerEventRepository lockerEventRepository,
        ILockerRepository lockerRepository,
        IRealtimeNotificationService notificationService,
        IIdentityService identityService)
    {
        _repository = repository;
        _lockerEventRepository = lockerEventRepository;
        _lockerRepository = lockerRepository;
        _notificationService = notificationService;
        _identityService = identityService;
    }

    public async Task<DeliveryRequestDto?> Handle(CreateDeliveryRequestCommand request, CancellationToken cancellationToken)
    {
        var item = new DeliveryRequest
        {
            UserId = request.UserId,
            SenderName = request.SenderName,
            ReceiverPhone = request.ReceiverPhone,
            LockerId = request.LockerId,
            SlotIndex = request.SlotIndex,
            PackageSize = request.PackageSize,
            TrackingCode = $"TRK-{DateTime.UtcNow:yyyyMMddHHmmss}-{RandomNumberGenerator.GetInt32(1000, 10000)}",
            Status = DeliveryStatus.Pending
        };

        var reserved = await _lockerRepository.TryReserveSlotAsync(item.LockerId, item.SlotIndex, item.Id, cancellationToken);
        if (!reserved)
            return null;

        await _repository.CreateAsync(item, cancellationToken);
        await _lockerEventRepository.CreateAsync(new LockerEvent
        {
            LockerId = item.LockerId,
            SlotIndex = item.SlotIndex,
            UserId = item.UserId,
            EventType = "DeliveryRequestCreated",
            ReferenceId = item.Id.ToString(),
            Notes = item.TrackingCode
        }, cancellationToken);

        // Gửi thông báo cho người nhận nếu tìm thấy trong hệ thống
        var receiver = await _identityService.FindByPhoneNumberAsync(request.ReceiverPhone);
        if (receiver != null)
        {
            await _notificationService.NotifyUserAsync(
                receiver.Id,
                "Kiện hàng mới",
                $"Bạn có một kiện hàng mới từ {request.SenderName} tại tủ {item.LockerId}",
                cancellationToken);
        }

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
