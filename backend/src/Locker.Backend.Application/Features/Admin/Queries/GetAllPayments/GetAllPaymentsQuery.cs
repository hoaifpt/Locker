using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Mapping;
using Locker.Backend.Application.Models;
using MediatR;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.Admin.Queries.GetAllPayments;

public record GetAllPaymentsQuery() : IRequest<List<PaymentDto>>;

public class GetAllPaymentsQueryHandler : IRequestHandler<GetAllPaymentsQuery, List<PaymentDto>>
{
    private readonly IPaymentRepository _paymentRepository;
    private readonly PaymentMapper _paymentMapper;

    public GetAllPaymentsQueryHandler(IPaymentRepository paymentRepository, PaymentMapper paymentMapper)
    {
        _paymentRepository = paymentRepository;
        _paymentMapper = paymentMapper;
    }

    public async Task<List<PaymentDto>> Handle(GetAllPaymentsQuery request, CancellationToken cancellationToken)
    {
        var payments = await _paymentRepository.GetAllAsync(cancellationToken);
        return payments.Select(_paymentMapper.Map).ToList();
    }
}
