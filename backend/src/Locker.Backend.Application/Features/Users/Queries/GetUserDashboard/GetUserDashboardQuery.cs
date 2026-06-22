using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Models;
using Locker.Backend.Domain.Enums;
using MediatR;
using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.Users.Queries.GetUserDashboard;

public record GetUserDashboardQuery(Guid UserId) : IRequest<UserDashboardDto>;

public class GetUserDashboardQueryHandler : IRequestHandler<GetUserDashboardQuery, UserDashboardDto>
{
    private readonly IIdentityService _identityService;
    private readonly IOrderRepository _orderRepository;
    private readonly ILockerRepository _lockerRepository;

    public GetUserDashboardQueryHandler(
        IIdentityService identityService,
        IOrderRepository orderRepository,
        ILockerRepository lockerRepository)
    {
        _identityService = identityService;
        _orderRepository = orderRepository;
        _lockerRepository = lockerRepository;
    }

    public async Task<UserDashboardDto> Handle(GetUserDashboardQuery request, CancellationToken cancellationToken)
    {
        var user = await _identityService.FindByIdAsync(request.UserId.ToString());
        
        var fullName = user?.FullName ?? "Người Dùng";
        if (string.IsNullOrWhiteSpace(fullName)) fullName = user?.UserName ?? "Người Dùng";

        // Find an active order
        var activeOrders = await _orderRepository.FindAsync(
            x => x.UserId == request.UserId && (x.Status == OrderStatus.Active || x.Status == OrderStatus.Reserved || x.Status == OrderStatus.Paid),
            cancellationToken);
        
        var activeOrder = activeOrders.OrderByDescending(x => x.CreatedAt).FirstOrDefault();
        ActiveOrderSummaryDto? activeOrderDto = null;

        var allLockers = await _lockerRepository.GetAllAsync(cancellationToken);

        if (activeOrder != null)
        {
            var lockerForOrder = allLockers.FirstOrDefault(l => l.Id == activeOrder.LockerId);
            
            string remainingTimeStr = "";
            if (activeOrder.CheckOutTime > DateTime.UtcNow)
            {
                var timeSpan = activeOrder.CheckOutTime - DateTime.UtcNow;
                remainingTimeStr = timeSpan.TotalHours > 1 
                    ? $"{(int)timeSpan.TotalHours:00}:{timeSpan.Minutes:00}" 
                    : $"{timeSpan.Minutes:00}:{timeSpan.Seconds:00}";
            }
            else
            {
                remainingTimeStr = "Hết hạn";
            }

            activeOrderDto = new ActiveOrderSummaryDto
            {
                OrderCode = $"Tủ {lockerForOrder?.Slots.FirstOrDefault(s => s.Index == activeOrder.SlotIndex)?.Size ?? "A"}-{activeOrder.SlotIndex:000}",
                LockerName = lockerForOrder?.Name ?? "Unknown Locker",
                Address = lockerForOrder?.Location ?? "",
                RemainingTime = remainingTimeStr,
                Status = activeOrder.Status == OrderStatus.Active ? "Đang hoạt động" : activeOrder.Status.ToString()
            };
        }

        // Suggested Lockers
        var suggestedLockers = allLockers
            .Where(l => l.Slots.Any(s => s.Status == LockerSlotStatus.Available))
            .Take(3)
            .Select(l => new SuggestedLockerDto
            {
                Id = l.Id,
                Name = l.Name,
                Distance = "450m", // Mock distance
                AvailableSlots = l.Slots.Count(s => s.Status == LockerSlotStatus.Available)
            }).ToList();

        var dashboard = new UserDashboardDto
        {
            User = new UserProfileSummaryDto
            {
                FullName = $"Xin chào, {fullName}!",
                Location = "Hồ Chí Minh", // Mock location
                AvatarUrl = "" // Empty avatar for now
            },
            ActiveOrder = activeOrderDto,
            SuggestedLockers = suggestedLockers,
            PromotionalBanners = new System.Collections.Generic.List<BannerDto>()
        };

        return dashboard;
    }
}
