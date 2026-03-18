using Locker.Backend.Domain.Entities;
using Locker.Backend.Application.Models;

namespace Locker.Backend.Application.Mapping;

public class OrderMapper : IMapper<Order, OrderDto>
{
    public OrderDto Map(Order source)
    {
        return new OrderDto
        {
            Id = source.Id,
            UserId = source.UserId,
            LockerId = source.LockerId,
            SlotIndex = source.SlotIndex,
            PackageId = source.PackageId,
            Status = source.Status,
            CheckInTime = source.CheckInTime,
            CheckOutTime = source.CheckOutTime,
            DurationHours = source.DurationHours,
            BaseRate = source.BaseRate,
            Subtotal = source.Subtotal,
            Taxes = source.Taxes,
            Discount = source.Discount,
            TotalAmount = source.TotalAmount,
            PaymentId = source.PaymentId,
            MobileNumber = source.MobileNumber,
            CancellationReason = source.CancellationReason,
            Notes = source.Notes,
            CreatedAt = source.CreatedAt,
            ReservedAt = source.ReservedAt,
            PaidAt = source.PaidAt,
            StartedAt = source.StartedAt,
            CompletedAt = source.CompletedAt,
            CancelledAt = source.CancelledAt
        };
    }

    public OrderSummaryDto MapToSummary(Order source)
    {
        return new OrderSummaryDto
        {
            Id = source.Id,
            LockerId = source.LockerId,
            SlotIndex = source.SlotIndex,
            Status = source.Status,
            TotalAmount = source.TotalAmount,
            CheckInTime = source.CheckInTime,
            CheckOutTime = source.CheckOutTime,
            CreatedAt = source.CreatedAt
        };
    }
}
