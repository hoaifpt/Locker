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

    /// <summary>Sum amount of Completed TopUp transactions created today (UTC).</summary>
    public decimal TodayAmount { get; set; }

    /// <summary>Number of Completed TopUp transactions created today (UTC).</summary>
    public int TodayCount { get; set; }

    /// <summary>Sum amount of Completed TopUp transactions created since the start of the current ISO week (UTC, Monday).</summary>
    public decimal WeekAmount { get; set; }

    /// <summary>Number of Completed TopUp transactions created since the start of the current ISO week (UTC, Monday).</summary>
    public int WeekCount { get; set; }

    /// <summary>Sum amount of Completed TopUp transactions created since the start of the current month (UTC).</summary>
    public decimal MonthAmount { get; set; }

    /// <summary>Number of Completed TopUp transactions created since the start of the current month (UTC).</summary>
    public int MonthCount { get; set; }

    /// <summary>Day this summary is scoped to (UTC date). Null = today.</summary>
    public DateTime? SelectedDay { get; set; }

    /// <summary>Sum amount of Completed TopUp transactions created on the selected UTC day (00:00–24:00).</summary>
    public decimal SelectedDayAmount { get; set; }

    /// <summary>Number of Completed TopUp transactions created on the selected UTC day.</summary>
    public int SelectedDayCount { get; set; }
}