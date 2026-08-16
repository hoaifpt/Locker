using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Mapping;
using Locker.Backend.Application.Models;
using MediatR;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.Admin.Queries.GetWalletTopUpSummary;

public record GetWalletTopUpSummaryQuery(DateTime? SelectedDayUtc = null) : IRequest<WalletTopUpSummaryDto>;

public class GetWalletTopUpSummaryQueryHandler
    : IRequestHandler<GetWalletTopUpSummaryQuery, WalletTopUpSummaryDto>
{
    private readonly IWalletTransactionRepository _walletTransactionRepository;

    public GetWalletTopUpSummaryQueryHandler(IWalletTransactionRepository walletTransactionRepository)
    {
        _walletTransactionRepository = walletTransactionRepository;
    }

    public async Task<WalletTopUpSummaryDto> Handle(
        GetWalletTopUpSummaryQuery request,
        CancellationToken cancellationToken)
    {
        var now = DateTime.UtcNow;
        var startOfToday = new DateTime(now.Year, now.Month, now.Day, 0, 0, 0, DateTimeKind.Utc);
        // ISO 8601: Monday is the first day of the week. DayOfWeek: Sunday=0..Saturday=6.
        var daysSinceMonday = ((int)now.DayOfWeek + 6) % 7;
        var startOfWeek = startOfToday.AddDays(-daysSinceMonday);
        var startOfMonth = new DateTime(now.Year, now.Month, 1, 0, 0, 0, DateTimeKind.Utc);

        var total = await _walletTransactionRepository.GetTotalTopUpAmountAsync(cancellationToken);
        var topUps = await _walletTransactionRepository.GetTopUpsAsync(null, null, cancellationToken);

        var today = await _walletTransactionRepository.GetTopUpStatsSinceAsync(startOfToday, cancellationToken);
        var week = await _walletTransactionRepository.GetTopUpStatsSinceAsync(startOfWeek, cancellationToken);
        var month = await _walletTransactionRepository.GetTopUpStatsSinceAsync(startOfMonth, cancellationToken);

        // Selected day (default = today UTC). Use end-of-day as exclusive upper
        // bound so we capture the full 24h of the chosen date.
        var selectedDay = request.SelectedDayUtc.HasValue
            ? DateTime.SpecifyKind(request.SelectedDayUtc.Value.Date, DateTimeKind.Utc)
            : startOfToday;
        var selectedEnd = selectedDay.AddDays(1);
        var selected = await _walletTransactionRepository.GetTopUpStatsInRangeAsync(selectedDay, selectedEnd, cancellationToken);

        return new WalletTopUpSummaryDto
        {
            TotalTopUpAmount = total,
            TopUpCount = topUps.Count,

            TodayAmount = today.Amount,
            TodayCount = today.Count,

            WeekAmount = week.Amount,
            WeekCount = week.Count,

            MonthAmount = month.Amount,
            MonthCount = month.Count,

            SelectedDay = selectedDay,
            SelectedDayAmount = selected.Amount,
            SelectedDayCount = selected.Count,
        };
    }
}