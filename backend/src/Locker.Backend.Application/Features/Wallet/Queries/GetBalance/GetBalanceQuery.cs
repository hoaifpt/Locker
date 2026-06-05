using Locker.Backend.Application.Interfaces;
using MediatR;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.Wallet.Queries.GetBalance;

public record GetBalanceQuery(Guid UserId) : IRequest<decimal>;

public class GetBalanceQueryHandler : IRequestHandler<GetBalanceQuery, decimal>
{
    private readonly IWalletTransactionRepository _repository;

    public GetBalanceQueryHandler(IWalletTransactionRepository repository)
    {
        _repository = repository;
    }

    public async Task<decimal> Handle(GetBalanceQuery request, CancellationToken cancellationToken)
    {
        return await _repository.GetBalanceAsync(request.UserId, cancellationToken);
    }
}
