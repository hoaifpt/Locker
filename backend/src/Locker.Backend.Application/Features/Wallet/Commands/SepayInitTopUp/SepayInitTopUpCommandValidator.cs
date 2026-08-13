using FluentValidation;

namespace Locker.Backend.Application.Features.Wallet.Commands.SepayInitTopUp;

public class SepayInitTopUpCommandValidator : AbstractValidator<SepayInitTopUpCommand>
{
    public SepayInitTopUpCommandValidator()
    {
        RuleFor(x => x.UserId)
            .NotEmpty();

        RuleFor(x => x.Amount)
            .GreaterThan(0);

        RuleFor(x => x.IpAddress)
            .NotEmpty();
    }
}
