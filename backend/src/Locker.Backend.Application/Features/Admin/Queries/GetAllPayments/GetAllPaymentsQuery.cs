using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Mapping;
using Locker.Backend.Application.Models;
using MediatR;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.Admin.Queries.GetAllPayments;

public record GetAllPaymentsQuery(
    int PageNumber = 1,
    int PageSize = 50,
    DateTime? DateFrom = null,
    DateTime? DateTo = null) : IRequest<PaginatedResult<PaymentDto>>;

public class GetAllPaymentsQueryHandler : IRequestHandler<GetAllPaymentsQuery, PaginatedResult<PaymentDto>>
{
    private const int MaxPageSize = 200;

    private readonly IPaymentRepository _paymentRepository;
    private readonly PaymentMapper _paymentMapper;

    public GetAllPaymentsQueryHandler(IPaymentRepository paymentRepository, PaymentMapper paymentMapper)
    {
        _paymentRepository = paymentRepository;
        _paymentMapper = paymentMapper;
    }

    public async Task<PaginatedResult<PaymentDto>> Handle(GetAllPaymentsQuery request, CancellationToken cancellationToken)
    {
        var pageNumber = request.PageNumber < 1 ? 1 : request.PageNumber;
        var pageSize = request.PageSize < 1 ? 50 : request.PageSize > MaxPageSize ? MaxPageSize : request.PageSize;

        var payments = await _paymentRepository.GetAllAsync(cancellationToken);

        IEnumerable<Domain.Entities.Payment> filtered = payments;

        if (request.DateFrom.HasValue)
            filtered = filtered.Where(x => x.CreatedAt >= request.DateFrom.Value);

        if (request.DateTo.HasValue)
            filtered = filtered.Where(x => x.CreatedAt <= request.DateTo.Value);

        var ordered = filtered.OrderByDescending(x => x.CreatedAt).ToList();
        var totalCount = ordered.Count;

        var items = ordered
            .Skip((pageNumber - 1) * pageSize)
            .Take(pageSize)
            .Select(_paymentMapper.Map)
            .ToList();

        return new PaginatedResult<PaymentDto>
        {
            Items = items,
            TotalCount = totalCount,
            PageNumber = pageNumber,
            PageSize = pageSize
        };
    }
}
