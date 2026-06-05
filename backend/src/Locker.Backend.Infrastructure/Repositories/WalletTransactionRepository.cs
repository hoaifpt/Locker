using Locker.Backend.Application.Interfaces;
using Locker.Backend.Domain.Entities;
using Locker.Backend.Domain.Enums;
using Microsoft.Extensions.Configuration;
using MongoDB.Driver;
using Locker.Backend.Infrastructure.Mongo;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Infrastructure.Repositories;

public class WalletTransactionRepository : GenericRepository<WalletTransaction>, IWalletTransactionRepository
{
    public WalletTransactionRepository(MongoContext context)
        : base(context.Database.GetCollection<WalletTransaction>(context.Settings.WalletTransactionsCollection))
    {
    }

    public async Task<List<WalletTransaction>> GetByUserIdAsync(Guid userId, CancellationToken cancellationToken = default)
    {
        return await _collection.Find(x => x.UserId == userId)
            .SortByDescending(x => x.CreatedAt)
            .ToListAsync(cancellationToken);
    }

    public async Task<decimal> GetBalanceAsync(Guid userId, CancellationToken cancellationToken = default)
    {
        var transactions = await GetByUserIdAsync(userId, cancellationToken);
        
        // Calculate balance: (TopUp + Refund) - (Payment + TransferOut) + (TransferIn)
        var balance = transactions
            .Where(t => t.Status == TransactionStatus.Completed)
            .Sum(t => 
            {
                if (t.Type == TransactionType.TopUp || t.Type == TransactionType.Refund)
                    return t.Amount;
                if (t.Type == TransactionType.Payment)
                    return -t.Amount;
                if (t.Type == TransactionType.Transfer)
                {
                    if (t.UserId == userId) return -t.Amount; // Sent
                    if (t.RelatedUserId == userId) return t.Amount; // Received
                }
                return 0;
            });
            
        // also count transfers where this user is the receiver
        var receivedTransfers = await _collection.Find(x => x.RelatedUserId == userId && x.Type == TransactionType.Transfer && x.Status == TransactionStatus.Completed)
            .ToListAsync(cancellationToken);
            
        return balance + receivedTransfers.Sum(x => x.Amount);
    }
}
