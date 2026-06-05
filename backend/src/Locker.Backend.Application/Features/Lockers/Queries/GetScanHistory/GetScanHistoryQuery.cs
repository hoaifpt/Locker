using Locker.Backend.Application.Models;
using MediatR;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.Lockers.Queries.GetScanHistory;

public record GetScanHistoryQuery() : IRequest<List<QrScanResultDto>>;

public class GetScanHistoryQueryHandler : IRequestHandler<GetScanHistoryQuery, List<QrScanResultDto>>
{
    public Task<List<QrScanResultDto>> Handle(GetScanHistoryQuery request, CancellationToken cancellationToken)
    {
        return Task.FromResult(new List<QrScanResultDto>());
    }
}
