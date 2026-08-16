using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Mapping;
using Locker.Backend.Application.Models;
using MediatR;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.Admin.Queries.GetWalletTopUpSummary;

public record GetWalletTopUpSummaryQuery() : IRequest<WalletTopUpSummaryDto>;

public class GetWalletTopUpSummaryQueryHandler
    : IRequestHandler<GetWalletTopUpSummaryQuery, WalletTopUpSummaryDto>
{
    private readonly IWalletTransactionRepository _walletTransactionRepository;

    public GetWalletTopUpSummaryQueryHandler(IWalletTransactionRepository walletTransactionRepository)
    {
        _walletTransactionRepository = walletTransactionRepository;
    }

    public async Task<WalletTopUpSummaryDto> Handle(
        GetWalletTopUpSummaryQuery request,
        CancellationToken cancellationToken)
    {
        var total = await _walletTransactionRepository.GetTotalTopUpAmountAsync(cancellationToken);
        var topUps = await _walletTransactionRepository.GetTopUpsAsync(null, null, cancellationToken);

        return new WalletTopUpSummaryDto
        {
            TotalTopUpAmount = total,
            TopUpCount = topUps.Count,
        };
    }
}