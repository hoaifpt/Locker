using Locker.Backend.Application.Models;
using Locker.Backend.Domain.Entities;

namespace Locker.Backend.Application.Mapping;

public class BookingMapper : IMapper<Booking, BookingDto>
{
    public BookingDto Map(Booking source) => new()
    {
        Id = source.Id,
        UserId = source.UserId,
        LockerId = source.LockerId,
        SlotIndex = source.SlotIndex,
        PackageId = source.PackageId,
        MobileNumber = source.MobileNumber,
        Status = source.Status,
        TotalAmount = source.TotalAmount,
        PaymentId = source.PaymentId,
        CreatedAt = source.CreatedAt,
        StartedAt = source.StartedAt,
        CompletedAt = source.CompletedAt
    };
}
