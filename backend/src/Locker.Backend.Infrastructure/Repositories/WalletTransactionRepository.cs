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

    public async Task<List<WalletTransaction>> GetTopUpsAsync(
        DateTime? dateFrom,
        DateTime? dateTo,
        CancellationToken cancellationToken = default)
    {
        var filterBuilder = Builders<WalletTransaction>.Filter;
        var filters = new List<FilterDefinition<WalletTransaction>>
        {
            filterBuilder.Eq(x => x.Type, TransactionType.TopUp),
            filterBuilder.Eq(x => x.Status, TransactionStatus.Completed),
        };

        if (dateFrom.HasValue) filters.Add(filterBuilder.Gte(x => x.CreatedAt, dateFrom.Value));
        if (dateTo.HasValue) filters.Add(filterBuilder.Lte(x => x.CreatedAt, dateTo.Value));

        var combined = filterBuilder.And(filters);
        return await _collection.Find(combined)
            .SortByDescending(x => x.CreatedAt)
            .ToListAsync(cancellationToken);
    }

    public async Task<decimal> GetTotalTopUpAmountAsync(CancellationToken cancellationToken = default)
    {
        var pipeline = new[]
        {
            new MongoDB.Bson.BsonDocument("$match", new MongoDB.Bson.BsonDocument
            {
                { "type", (int)TransactionType.TopUp },
                { "status", (int)TransactionStatus.Completed },
            }),
            new MongoDB.Bson.BsonDocument("$group", new MongoDB.Bson.BsonDocument
            {
                { "_id", MongoDB.Bson.BsonNull.Value },
                { "total", new MongoDB.Bson.BsonDocument("$sum", "$amount") },
            }),
        };

        var result = await _collection
            .Aggregate<MongoDB.Bson.BsonDocument>(pipeline, cancellationToken: cancellationToken)
            .FirstOrDefaultAsync(cancellationToken);

        if (result == null || !result.Contains("total")) return 0m;
        return result["total"].ToDecimal();
    }

    public async Task<(decimal Amount, int Count)> GetTopUpStatsSinceAsync(
        DateTime startUtc,
        CancellationToken cancellationToken = default)
    {
        var pipeline = new[]
        {
            new MongoDB.Bson.BsonDocument("$match", new MongoDB.Bson.BsonDocument
            {
                { "type", (int)TransactionType.TopUp },
                { "status", (int)TransactionStatus.Completed },
                { "createdAt", new MongoDB.Bson.BsonDocument("$gte", startUtc) },
            }),
            new MongoDB.Bson.BsonDocument("$group", new MongoDB.Bson.BsonDocument
            {
                { "_id", MongoDB.Bson.BsonNull.Value },
                { "amount", new MongoDB.Bson.BsonDocument("$sum", "$amount") },
                { "count", new MongoDB.Bson.BsonDocument("$sum", 1) },
            }),
        };

        var result = await _collection
            .Aggregate<MongoDB.Bson.BsonDocument>(pipeline, cancellationToken: cancellationToken)
            .FirstOrDefaultAsync(cancellationToken);

        if (result == null) return (0m, 0);
        var amount = result.Contains("amount") ? result["amount"].ToDecimal() : 0m;
        var count = result.Contains("count") ? result["count"].ToInt32() : 0;
        return (amount, count);
    }

    public async Task<(decimal Amount, int Count)> GetTopUpStatsInRangeAsync(
        DateTime startUtc,
        DateTime endUtc,
        CancellationToken cancellationToken = default)
    {
        var pipeline = new[]
        {
            new MongoDB.Bson.BsonDocument("$match", new MongoDB.Bson.BsonDocument
            {
                { "type", (int)TransactionType.TopUp },
                { "status", (int)TransactionStatus.Completed },
                { "createdAt", new MongoDB.Bson.BsonDocument
                    {
                        { "$gte", startUtc },
                        { "$lt", endUtc },
                    }
                },
            }),
            new MongoDB.Bson.BsonDocument("$group", new MongoDB.Bson.BsonDocument
            {
                { "_id", MongoDB.Bson.BsonNull.Value },
                { "amount", new MongoDB.Bson.BsonDocument("$sum", "$amount") },
                { "count", new MongoDB.Bson.BsonDocument("$sum", 1) },
            }),
        };

        var result = await _collection
            .Aggregate<MongoDB.Bson.BsonDocument>(pipeline, cancellationToken: cancellationToken)
            .FirstOrDefaultAsync(cancellationToken);

        if (result == null) return (0m, 0);
        var amount = result.Contains("amount") ? result["amount"].ToDecimal() : 0m;
        var count = result.Contains("count") ? result["count"].ToInt32() : 0;
        return (amount, count);
    }
}
