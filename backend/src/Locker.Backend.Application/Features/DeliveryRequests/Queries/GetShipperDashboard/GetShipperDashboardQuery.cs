using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Models;
using Locker.Backend.Domain.Enums;
using MediatR;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.DeliveryRequests.Queries.GetShipperDashboard;

public record GetShipperDashboardQuery(Guid UserId) : IRequest<ShipperDashboardDto>;

public class GetShipperDashboardQueryHandler : IRequestHandler<GetShipperDashboardQuery, ShipperDashboardDto>
{
    private readonly IDeliveryRequestRepository _deliveryRepository;
    private readonly ILockerRepository _lockerRepository;

    public GetShipperDashboardQueryHandler(
        IDeliveryRequestRepository deliveryRepository,
        ILockerRepository lockerRepository)
    {
        _deliveryRepository = deliveryRepository;
        _lockerRepository = lockerRepository;
    }

    public async Task<ShipperDashboardDto> Handle(GetShipperDashboardQuery request, CancellationToken cancellationToken)
    {
        // Get today's deliveries for this shipper
        var todayStart = DateTime.UtcNow.Date;
        var todayDeliveries = await _deliveryRepository.FindAsync(
            x => x.UserId == request.UserId && x.CreatedAt >= todayStart,
            cancellationToken);

        var deliveredCount = todayDeliveries.Count(x => x.Status == DeliveryStatus.DeliveredToLocker || x.Status == DeliveryStatus.Completed);
        var remainingCount = todayDeliveries.Count(x => x.Status == DeliveryStatus.Pending);

        // Get Lockers
        var allLockers = await _lockerRepository.GetAllAsync(cancellationToken);
        
        var availableLockers = allLockers
            .Where(l => l.Slots.Any(s => s.Status == LockerSlotStatus.Available))
            .Take(3)
            .Select(l => new AvailableLockerDto
            {
                Id = l.Id,
                Name = l.Name,
                Address = l.Location,
                AvailableSlots = l.Slots.Count(s => s.Status == LockerSlotStatus.Available),
                TravelTime = "Mock time", // Mocking external API distance
                Distance = "Mock dist",
                IsNearest = true
            }).ToList();

        // Orders to process
        var ordersToProcess = todayDeliveries
            .Where(x => x.Status == DeliveryStatus.Pending)
            .Select(x => {
                var locker = allLockers.FirstOrDefault(l => l.Id == x.LockerId);
                return new OrderToProcessDto
                {
                    OrderId = x.Id,
                    Type = "GIAO NGAY", // Mock order type
                    Distance = "2.5km", // Mock distance
                    LocationName = locker?.Name ?? "Unknown Locker",
                    SlotInfo = $"Tủ {x.SlotIndex}",
                    Code = x.TrackingCode
                };
            }).ToList();

        var dashboard = new ShipperDashboardDto
        {
            Performance = new ShipperPerformanceDto
            {
                DeliveredCount = deliveredCount,
                RemainingCount = remainingCount,
                TotalKm = 0, // Mock calculation
                UpdatedAt = DateTime.UtcNow.ToString("HH:mm")
            },
            AvailableLockers = availableLockers,
            OrdersToProcess = ordersToProcess
        };

        return dashboard;
    }
}
