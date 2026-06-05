using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Models;
using Locker.Backend.Domain.Enums;
using MediatR;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.Orders.Queries.GetAvailableSlotsByLocker;

public record GetAvailableSlotsByLockerQuery(Guid LockerId, DateTime FromTime, DateTime ToTime) : IRequest<List<AvailableSlotDto>>;

public class GetAvailableSlotsByLockerQueryHandler : IRequestHandler<GetAvailableSlotsByLockerQuery, List<AvailableSlotDto>>
{
    private readonly ILockerRepository _lockerRepository;
    private readonly IPackageRepository _packageRepository;
    private readonly IOrderRepository _orderRepository;

    public GetAvailableSlotsByLockerQueryHandler(
        ILockerRepository lockerRepository,
        IPackageRepository packageRepository,
        IOrderRepository orderRepository)
    {
        _lockerRepository = lockerRepository;
        _packageRepository = packageRepository;
        _orderRepository = orderRepository;
    }

    public async Task<List<AvailableSlotDto>> Handle(GetAvailableSlotsByLockerQuery request, CancellationToken cancellationToken)
    {
        var locker = await _lockerRepository.GetByIdAsync(request.LockerId, cancellationToken);
        if (locker == null)
            return new List<AvailableSlotDto>();

        var availableSlots = new List<AvailableSlotDto>();
        var activePackages = await _packageRepository.GetActiveAsync(cancellationToken);
        var defaultPackage = activePackages.FirstOrDefault();

        if (defaultPackage == null)
            return availableSlots;

        foreach (var slot in locker.Slots.Where(s => s.Status == LockerSlotStatus.Available))
        {
            var conflicts = await _orderRepository.GetConflictingOrdersAsync(
                request.LockerId,
                slot.Index,
                request.FromTime,
                request.ToTime,
                cancellationToken);

            if (conflicts.Count == 0)
            {
                availableSlots.Add(new AvailableSlotDto
                {
                    LockerId = request.LockerId,
                    LockerName = locker.Name,
                    Location = locker.Location,
                    SlotIndex = slot.Index,
                    PackageSize = defaultPackage.Size,
                    PricePerHour = defaultPackage.PricePerHour
                });
            }
        }

        return availableSlots;
    }
}
