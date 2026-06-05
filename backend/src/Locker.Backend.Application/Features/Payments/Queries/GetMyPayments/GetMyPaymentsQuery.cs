using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Mapping;
using Locker.Backend.Application.Models;
using MediatR;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.Payments.Queries.GetMyPayments;

public record GetMyPaymentsQuery(Guid UserId) : IRequest<List<PaymentDto>>;

public class GetMyPaymentsQueryHandler : IRequestHandler<GetMyPaymentsQuery, List<PaymentDto>>
{
    private readonly IPaymentRepository _paymentRepository;
    private readonly PaymentMapper _paymentMapper;

    public GetMyPaymentsQueryHandler(IPaymentRepository paymentRepository, PaymentMapper paymentMapper)
    {
        _paymentRepository = paymentRepository;
        _paymentMapper = paymentMapper;
    }

    public async Task<List<PaymentDto>> Handle(GetMyPaymentsQuery request, CancellationToken cancellationToken)
    {
        var payments = await _paymentRepository.GetByUserIdAsync(request.UserId, cancellationToken);
        return payments.Select(_paymentMapper.Map).ToList();
    }
}
