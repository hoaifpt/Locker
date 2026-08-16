using Locker.Backend.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Interfaces;

public interface IWalletTransactionRepository : IGenericRepository<WalletTransaction>
{
    Task<List<WalletTransaction>> GetByUserIdAsync(Guid userId, CancellationToken cancellationToken = default);
    Task<decimal> GetBalanceAsync(Guid userId, CancellationToken cancellationToken = default);

    /// <summary>Sum amount of all Completed TopUp transactions across the
    /// entire system. Used by admin revenue/dashboard widgets.</summary>
    Task<decimal> GetTotalTopUpAmountAsync(CancellationToken cancellationToken = default);

    /// <summary>List Completed TopUp transactions within an optional date
    /// range, newest first. Used by admin wallet overview.</summary>
    Task<List<WalletTransaction>> GetTopUpsAsync(
        DateTime? dateFrom,
        DateTime? dateTo,
        CancellationToken cancellationToken = default);
}