using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Models;
using MediatR;
using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.Wallet.Queries.GetOverview;

public record GetOverviewQuery(Guid UserId) : IRequest<WalletOverviewDto>;

public class GetOverviewQueryHandler : IRequestHandler<GetOverviewQuery, WalletOverviewDto>
{
    private readonly IWalletTransactionRepository _repository;

    public GetOverviewQueryHandler(IWalletTransactionRepository repository)
    {
        _repository = repository;
    }

    public async Task<WalletOverviewDto> Handle(GetOverviewQuery request, CancellationToken cancellationToken)
    {
        var balance = await _repository.GetBalanceAsync(request.UserId, cancellationToken);
        var transactions = await _repository.GetByUserIdAsync(request.UserId, cancellationToken);
        
        return new WalletOverviewDto
        {
            Balance = balance,
            RecentTransactionsCount = transactions.Count(t => t.CreatedAt >= DateTime.UtcNow.AddDays(-30))
        };
    }
}
