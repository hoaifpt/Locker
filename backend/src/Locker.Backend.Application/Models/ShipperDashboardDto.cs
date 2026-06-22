using System;
using System.Collections.Generic;

namespace Locker.Backend.Application.Models;

public class ShipperDashboardDto
{
    public ShipperPerformanceDto Performance { get; set; } = new();
    public List<AvailableLockerDto> AvailableLockers { get; set; } = new();
    public List<OrderToProcessDto> OrdersToProcess { get; set; } = new();
}

public class ShipperPerformanceDto
{
    public int DeliveredCount { get; set; }
    public int RemainingCount { get; set; }
    public int TotalKm { get; set; }
    public string UpdatedAt { get; set; } = string.Empty;
}

public class AvailableLockerDto
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Address { get; set; } = string.Empty;
    public int AvailableSlots { get; set; }
    public string TravelTime { get; set; } = string.Empty;
    public string Distance { get; set; } = string.Empty;
    public bool IsNearest { get; set; }
}

public class OrderToProcessDto
{
    public Guid OrderId { get; set; }
    public string Type { get; set; } = string.Empty;
    public string Distance { get; set; } = string.Empty;
    public string LocationName { get; set; } = string.Empty;
    public string SlotInfo { get; set; } = string.Empty;
    public string Code { get; set; } = string.Empty;
}
