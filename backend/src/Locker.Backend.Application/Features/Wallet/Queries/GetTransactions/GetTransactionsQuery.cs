using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Models;
using MediatR;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.Wallet.Queries.GetTransactions;

public record GetTransactionsQuery(Guid UserId) : IRequest<List<WalletTransactionDto>>;

public class GetTransactionsQueryHandler : IRequestHandler<GetTransactionsQuery, List<WalletTransactionDto>>
{
    private readonly IWalletTransactionRepository _repository;

    public GetTransactionsQueryHandler(IWalletTransactionRepository repository)
    {
        _repository = repository;
    }

    public async Task<List<WalletTransactionDto>> Handle(GetTransactionsQuery request, CancellationToken cancellationToken)
    {
        var transactions = await _repository.GetByUserIdAsync(request.UserId, cancellationToken);
        return transactions.Select(t => new WalletTransactionDto
        {
            Id = t.Id,
            Amount = t.Amount,
            Type = t.Type,
            Status = t.Status,
            Description = t.Description,
            CreatedAt = t.CreatedAt
        }).ToList();
    }
}
