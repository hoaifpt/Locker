using Locker.Backend.Application.Models;
using Locker.Backend.Domain.Entities;

namespace Locker.Backend.Application.Mapping;

public class PaymentMapper : IMapper<Payment, PaymentDto>
{
    public PaymentDto Map(Payment source) => new()
    {
        Id = source.Id,
        BookingId = source.BookingId,
        UserId = source.UserId,
        Amount = source.Amount,
        Status = source.Status,
        Method = source.Method,
        TransactionId = source.TransactionId,
        CreatedAt = source.CreatedAt,
        PaidAt = source.PaidAt
    };
}
