using Locker.Backend.Domain.Enums;
using System;

namespace Locker.Backend.Application.Models;

public class WalletTransactionDto
{
    public Guid Id { get; set; }
    public decimal Amount { get; set; }
    public TransactionType Type { get; set; }
    public TransactionStatus Status { get; set; }
    public string? Description { get; set; }
    public DateTime CreatedAt { get; set; }
}

public class WalletOverviewDto
{
    public decimal Balance { get; set; }
    public int RecentTransactionsCount { get; set; }
}
