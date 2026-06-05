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
}
