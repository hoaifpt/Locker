using FluentValidation;

namespace Locker.Backend.Application.Features.Wallet.Commands.VnPayInitTopUp;

public class VnPayInitTopUpCommandValidator : AbstractValidator<VnPayInitTopUpCommand>
{
    public VnPayInitTopUpCommandValidator()
    {
        RuleFor(x => x.Amount)
            .GreaterThanOrEqualTo(10000)
            .WithMessage("Số tiền nạp tối thiểu là 10,000 VND.")
            .LessThanOrEqualTo(50000000)
            .WithMessage("Số tiền nạp tối đa là 50,000,000 VND.");

        RuleFor(x => x.IpAddress)
            .NotEmpty()
            .WithMessage("IP address is required.");
    }
}
