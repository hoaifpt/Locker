using Locker.Backend.Application.Interfaces;
using Locker.Backend.Domain.Entities;
using Locker.Backend.Domain.Enums;
using MediatR;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.Wallet.Commands.Transfer;

public record TransferCommand(Guid SenderId, Guid ReceiverId, decimal Amount, string? Note) : IRequest<bool>;

public class TransferCommandHandler : IRequestHandler<TransferCommand, bool>
{
    private readonly IWalletTransactionRepository _repository;

    public TransferCommandHandler(IWalletTransactionRepository repository)
    {
        _repository = repository;
    }

    public async Task<bool> Handle(TransferCommand request, CancellationToken cancellationToken)
    {
        var balance = await _repository.GetBalanceAsync(request.SenderId, cancellationToken);
        if (balance < request.Amount)
            return false;

        var now = DateTime.UtcNow;
        var senderTransaction = new WalletTransaction
        {
            UserId = request.SenderId,
            RelatedUserId = request.ReceiverId,
            Amount = request.Amount,
            Type = TransactionType.Transfer,
            Status = TransactionStatus.Completed,
            Description = request.Note ?? "Wallet Transfer",
            CreatedAt = now,
            UpdatedAt = now
        };

        var receiverTransaction = new WalletTransaction
        {
            UserId = request.ReceiverId,
            RelatedUserId = request.SenderId,
            Amount = request.Amount,
            Type = TransactionType.Transfer,
            Status = TransactionStatus.Completed,
            Description = request.Note ?? "Wallet Transfer",
            CreatedAt = now,
            UpdatedAt = now
        };

        await _repository.CreateAsync(senderTransaction, cancellationToken);
        await _repository.CreateAsync(receiverTransaction, cancellationToken);
        return true;
    }
}
