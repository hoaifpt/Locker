using Locker.Backend.Domain.Enums;
using System;

namespace Locker.Backend.Application.Models;

public class WalletTransactionDto
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    /// <summary>Username của user thực hiện transaction (admin view).</summary>
    public string? UserName { get; set; }
    public decimal Amount { get; set; }
    public TransactionType Type { get; set; }
    public TransactionStatus Status { get; set; }
    public string? Description { get; set; }
    public string? ReferenceId { get; set; }
    public Guid? RelatedUserId { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
}

public class WalletOverviewDto
{
    public decimal Balance { get; set; }
    public int RecentTransactionsCount { get; set; }
}

/// <summary>Aggregate stats for admin dashboard / wallet overview.</summary>
public class WalletTopUpSummaryDto
{
    /// <summary>Sum amount of all Completed TopUp transactions.</summary>
    public decimal TotalTopUpAmount { get; set; }

    /// <summary>Total number of Completed TopUp transactions.</summary>
    public int TopUpCount { get; set; }
}