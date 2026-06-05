using Locker.Backend.Application.Interfaces;
using Locker.Backend.Domain.Entities;
using Locker.Backend.Domain.Enums;
using MediatR;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.Wallet.Commands.TopUp;

public record TopUpCommand(Guid UserId, decimal Amount, string? ReferenceId) : IRequest<bool>;

public class TopUpCommandHandler : IRequestHandler<TopUpCommand, bool>
{
    private readonly IWalletTransactionRepository _repository;

    public TopUpCommandHandler(IWalletTransactionRepository repository)
    {
        _repository = repository;
    }

    public async Task<bool> Handle(TopUpCommand request, CancellationToken cancellationToken)
    {
        var transaction = new WalletTransaction
        {
            UserId = request.UserId,
            Amount = request.Amount,
            Type = TransactionType.TopUp,
            Status = TransactionStatus.Completed, // Assume successful for now, integrate with payment gateway later
            Description = "Wallet Top Up",
            ReferenceId = request.ReferenceId,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        await _repository.CreateAsync(transaction, cancellationToken);
        return true;
    }
}
