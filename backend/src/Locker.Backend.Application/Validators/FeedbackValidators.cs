using FluentValidation;
using Locker.Backend.Application.Models;

namespace Locker.Backend.Application.Validators;

public class UpsertFeedbackRequestValidator : AbstractValidator<UpsertFeedbackRequest>
{
    public UpsertFeedbackRequestValidator()
    {
        RuleFor(x => x.Rating).InclusiveBetween(1, 5);
        RuleFor(x => x.Topic).IsInEnum();
        RuleFor(x => x.Content)
            .Cascade(CascadeMode.Stop)
            .Must(content => !string.IsNullOrWhiteSpace(content))
            .WithMessage("Content is required.")
            .Must(content => content.Trim().Length <= 2000)
            .WithMessage("Content must not exceed 2000 characters.");
        RuleFor(x => x.PageUrl)
            .NotEmpty()
            .MaximumLength(500)
            .Must(path => Uri.TryCreate(path, UriKind.Relative, out _) &&
                          path.StartsWith('/') &&
                          !path.StartsWith("//") &&
                          !path.Contains('\\') &&
                          !path.Contains('?') &&
                          !path.Contains('#'))
            .WithMessage("PageUrl must be an internal pathname without query or fragment.");
    }
}
