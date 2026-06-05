using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Mapping;
using Locker.Backend.Application.Models;
using MediatR;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.Payments.Queries.GetPaymentById;

public record GetPaymentByIdQuery(Guid Id) : IRequest<PaymentDto?>;

public class GetPaymentByIdQueryHandler : IRequestHandler<GetPaymentByIdQuery, PaymentDto?>
{
    private readonly IPaymentRepository _paymentRepository;
    private readonly PaymentMapper _paymentMapper;

    public GetPaymentByIdQueryHandler(IPaymentRepository paymentRepository, PaymentMapper paymentMapper)
    {
        _paymentRepository = paymentRepository;
        _paymentMapper = paymentMapper;
    }

    public async Task<PaymentDto?> Handle(GetPaymentByIdQuery request, CancellationToken cancellationToken)
    {
        var payment = await _paymentRepository.GetByIdAsync(request.Id, cancellationToken);
        return payment == null ? null : _paymentMapper.Map(payment);
    }
}
