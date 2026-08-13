using FluentValidation;
using Locker.Backend.Application.Models;

namespace Locker.Backend.Application.Validators;

public class UpsertFeedbackRequestValidator : AbstractValidator<UpsertFeedbackRequest>
{
    public UpsertFeedbackRequestValidator()
    {
        RuleFor(x => x.Rating).InclusiveBetween(1, 5);
        RuleFor(x => x.Topic).IsInEnum();
        RuleFor(x => x.Content).NotEmpty().MaximumLength(2000);
        RuleFor(x => x.PageUrl)
            .NotEmpty()
            .MaximumLength(500)
            .Must(path => Uri.TryCreate(path, UriKind.Relative, out _) &&
                          path.StartsWith('/') &&
                          !path.Contains('?') &&
                          !path.Contains('#'))
            .WithMessage("PageUrl must be an internal pathname without query or fragment.");
    }
}
