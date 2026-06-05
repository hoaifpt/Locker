using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Mapping;
using Locker.Backend.Application.Models;
using MediatR;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.Payments.Queries.GetPaymentByBookingId;

public record GetPaymentByBookingIdQuery(Guid BookingId) : IRequest<PaymentDto?>;

public class GetPaymentByBookingIdQueryHandler : IRequestHandler<GetPaymentByBookingIdQuery, PaymentDto?>
{
    private readonly IPaymentRepository _paymentRepository;
    private readonly PaymentMapper _paymentMapper;

    public GetPaymentByBookingIdQueryHandler(IPaymentRepository paymentRepository, PaymentMapper paymentMapper)
    {
        _paymentRepository = paymentRepository;
        _paymentMapper = paymentMapper;
    }

    public async Task<PaymentDto?> Handle(GetPaymentByBookingIdQuery request, CancellationToken cancellationToken)
    {
        var payment = await _paymentRepository.GetByBookingIdAsync(request.BookingId, cancellationToken);
        return payment == null ? null : _paymentMapper.Map(payment);
    }
}
