using System;
using System.Collections.Generic;

namespace Locker.Backend.Application.Models;

public class UserDashboardDto
{
    public UserProfileSummaryDto User { get; set; } = new();
    public ActiveOrderSummaryDto? ActiveOrder { get; set; }
    public List<SuggestedLockerDto> SuggestedLockers { get; set; } = new();
    public List<BannerDto> PromotionalBanners { get; set; } = new();
}

public class UserProfileSummaryDto
{
    public string FullName { get; set; } = string.Empty;
    public string Location { get; set; } = string.Empty;
    public string AvatarUrl { get; set; } = string.Empty;
}

public class ActiveOrderSummaryDto
{
    public string OrderCode { get; set; } = string.Empty;
    public string LockerName { get; set; } = string.Empty;
    public string Address { get; set; } = string.Empty;
    public string RemainingTime { get; set; } = string.Empty;
    public string Status { get; set; } = string.Empty;
}

public class SuggestedLockerDto
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Distance { get; set; } = string.Empty;
    public int AvailableSlots { get; set; }
}

public class BannerDto
{
    public Guid Id { get; set; }
    public string ImageUrl { get; set; } = string.Empty;
    public string Title { get; set; } = string.Empty;
    public string ActionUrl { get; set; } = string.Empty;
}
