using System.Text;
using FluentValidation;
using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Models;
using Locker.Backend.Domain.Enums;
using MediatR;

namespace Locker.Backend.Application.Features.Feedback.Queries.ExportFeedback;

public sealed record ExportFeedbackQuery(
    int? Rating,
    FeedbackTopic? Topic,
    bool? IsVisible,
    string? Search) : IRequest<ExportFeedbackResult>;

public sealed class ExportFeedbackQueryValidator : AbstractValidator<ExportFeedbackQuery>
{
    public ExportFeedbackQueryValidator()
    {
        RuleFor(x => x.Rating).InclusiveBetween(1, 5).When(x => x.Rating.HasValue);
        RuleFor(x => x.Topic).IsInEnum().When(x => x.Topic.HasValue);
        RuleFor(x => x.Search).MaximumLength(200).When(x => x.Search is not null);
    }
}

public sealed class ExportFeedbackQueryHandler
    : IRequestHandler<ExportFeedbackQuery, ExportFeedbackResult>
{
    private readonly IFeedbackRepository _repository;

    public ExportFeedbackQueryHandler(IFeedbackRepository repository)
    {
        _repository = repository;
    }

    public async Task<ExportFeedbackResult> Handle(ExportFeedbackQuery request, CancellationToken cancellationToken)
    {
        var filter = new FeedbackFilter(
            request.Rating,
            request.Topic,
            request.IsVisible,
            request.Search);
        var feedbacks = await _repository.GetForExportAsync(filter, cancellationToken);
        var csv = new StringBuilder();

        csv.AppendLine(string.Join(',',
            CsvCell("Username"),
            CsvCell("Rating"),
            CsvCell("Topic"),
            CsvCell("Content"),
            CsvCell("PageUrl"),
            CsvCell("IsVisible"),
            CsvCell("CreatedAtUtc"),
            CsvCell("UpdatedAtUtc")));
        foreach (var feedback in feedbacks)
        {
            csv.AppendJoin(',',
                CsvCell(feedback.Username),
                CsvCell(feedback.Rating.ToString()),
                CsvCell(feedback.Topic.ToString()),
                CsvCell(feedback.Content),
                CsvCell(feedback.PageUrl),
                CsvCell(feedback.IsVisible ? "true" : "false"),
                CsvCell(feedback.CreatedAt.ToString("O")),
                CsvCell(feedback.UpdatedAt.ToString("O")));
            csv.AppendLine();
        }

        var preamble = Encoding.UTF8.GetPreamble();
        var body = Encoding.UTF8.GetBytes(csv.ToString());
        var content = preamble.Concat(body).ToArray();
        return new ExportFeedbackResult(content, $"feedback-{DateTime.UtcNow:yyyyMMdd-HHmmss}.csv");
    }

    private static string CsvCell(string value)
    {
        var safe = value;
        if (safe.Length > 0 && "=+-@".Contains(safe[0]))
            safe = "'" + safe;
        return $"\"{safe.Replace("\"", "\"\"")}\"";
    }
}
