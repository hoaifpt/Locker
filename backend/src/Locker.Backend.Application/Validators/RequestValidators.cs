using FluentValidation;
using Locker.Backend.Application.Models;

namespace Locker.Backend.Application.Validators;

public class AuthRequestValidator : AbstractValidator<AuthRequest>
{
    public AuthRequestValidator()
    {
        RuleFor(x => x.Identifier)
            .NotEmpty().WithMessage("Email hoáº·c sá»‘ Ä‘iá»‡n thoáº¡i Ä‘Æ°á»£c yÃªu cáº§u.")
            .MaximumLength(255).WithMessage("Identifier quÃ¡ dÃ i.");

        RuleFor(x => x.Password)
            .NotEmpty().WithMessage("Password is required.")
            .MinimumLength(6).WithMessage("Password must be at least 6 characters.");
    }
}

public class RegisterRequestValidator : AbstractValidator<RegisterRequest>
{
    public RegisterRequestValidator()
    {
        RuleFor(x => x.Username)
            .NotEmpty().WithMessage("Username is required.")
            .MinimumLength(3).WithMessage("Username must be at least 3 characters.")
            .MaximumLength(50).WithMessage("Username must not exceed 50 characters.")
            .Matches("^[a-zA-Z0-9_]+$").WithMessage("Username can only contain letters, numbers and underscores.");

        RuleFor(x => x.Email)
            .NotEmpty().WithMessage("Email is required.")
            .EmailAddress().WithMessage("Invalid email format.");

        RuleFor(x => x.Password)
            .NotEmpty().WithMessage("Password is required.")
            .MinimumLength(8).WithMessage("Password must be at least 8 characters.")
            .Matches("[A-Z]").WithMessage("Password must contain at least one uppercase letter.")
            .Matches("[a-z]").WithMessage("Password must contain at least one lowercase letter.")
            .Matches("[0-9]").WithMessage("Password must contain at least one digit.")
            .Matches("[^a-zA-Z0-9]").WithMessage("Password must contain at least one special character.");

        RuleFor(x => x.FullName)
            .MaximumLength(100).WithMessage("Full name must not exceed 100 characters.")
            .When(x => x.FullName != null);

        RuleFor(x => x.PhoneNumber)
            .Matches(@"^(\+?[0-9]{7,15})$").WithMessage("Sá»‘ Ä‘iá»‡n thoáº¡i khÃ´ng há»£p lá»‡ (vÃ­ dá»¥: +84901234567 hoáº·c 0901234567).")
            .When(x => !string.IsNullOrEmpty(x.PhoneNumber));
    }
}

public class ChangePasswordRequestValidator : AbstractValidator<ChangePasswordRequest>
{
    public ChangePasswordRequestValidator()
    {
        RuleFor(x => x.CurrentPassword)
            .NotEmpty().WithMessage("Current password is required.");

        RuleFor(x => x.NewPassword)
            .NotEmpty().WithMessage("New password is required.")
            .MinimumLength(8).WithMessage("Password must be at least 8 characters.")
            .Matches("[A-Z]").WithMessage("Password must contain at least one uppercase letter.")
            .Matches("[a-z]").WithMessage("Password must contain at least one lowercase letter.")
            .Matches("[0-9]").WithMessage("Password must contain at least one digit.")
            .Matches("[^a-zA-Z0-9]").WithMessage("Password must contain at least one special character.")
            .NotEqual(x => x.CurrentPassword).WithMessage("New password must differ from the current password.");
    }
}

public class UpdateProfileRequestValidator : AbstractValidator<UpdateProfileRequest>
{
    public UpdateProfileRequestValidator()
    {
        RuleFor(x => x.Email)
            .EmailAddress().WithMessage("Invalid email format.")
            .When(x => !string.IsNullOrEmpty(x.Email));

        RuleFor(x => x.FullName)
            .MaximumLength(100).WithMessage("Full name must not exceed 100 characters.")
            .When(x => x.FullName != null);
    }
}

public class ForgotPasswordRequestValidator : AbstractValidator<ForgotPasswordRequest>
{
    public ForgotPasswordRequestValidator()
    {
        RuleFor(x => x.Email)
            .NotEmpty().WithMessage("Email khÃ´ng Ä‘Æ°á»£c Ä‘á»ƒ trá»‘ng.")
            .EmailAddress().WithMessage("Email khÃ´ng há»£p lá»‡.")
            .MaximumLength(200).WithMessage("Email quÃ¡ dÃ i.");
    }
}

public class ResetPasswordRequestValidator : AbstractValidator<ResetPasswordRequest>
{
    public ResetPasswordRequestValidator()
    {
        RuleFor(x => x.Email)
            .NotEmpty().WithMessage("Email hoáº·c sá»‘ Ä‘iá»‡n thoáº¡i khÃ´ng Ä‘Æ°á»£c Ä‘á»ƒ trá»‘ng.");

        RuleFor(x => x.Otp)
            .NotEmpty().WithMessage("MÃ£ OTP khÃ´ng Ä‘Æ°á»£c Ä‘á»ƒ trá»‘ng.")
            .Length(6).WithMessage("MÃ£ OTP pháº£i gá»“m 6 chá»¯ sá»‘.")
            .Matches("^[0-9]+$").WithMessage("MÃ£ OTP chá»‰ chá»©a chá»¯ sá»‘.");

        RuleFor(x => x.NewPassword)
    .NotEmpty().WithMessage("Mật khẩu mới không được để trống.")
    .MinimumLength(8).WithMessage("Mật khẩu phải có ít nhất 8 ký tự.")
    .Matches("[A-Z]").WithMessage("Mật khẩu phải chứa ít nhất một chữ hoa.")
    .Matches("[a-z]").WithMessage("Mật khẩu phải chứa ít nhất một chữ thường.")
    .Matches("[0-9]").WithMessage("Mật khẩu phải chứa ít nhất một chữ số.")
    .Matches("[^a-zA-Z0-9]").WithMessage("Mật khẩu phải chứa ít nhất một ký tự đặc biệt.");
    }
}

public class CreateLockerRequestValidator : AbstractValidator<CreateLockerRequest>
{
    public CreateLockerRequestValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("Locker name is required.")
            .MaximumLength(100).WithMessage("Name must not exceed 100 characters.");

        RuleFor(x => x.Location)
            .MaximumLength(200).WithMessage("Location must not exceed 200 characters.");

        RuleFor(x => x.Slots)
            .InclusiveBetween(1, 500).WithMessage("Slots must be between 1 and 500.");
    }
}

public class CreatePackageRequestValidator : AbstractValidator<CreatePackageRequest>
{
    public CreatePackageRequestValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("Package name is required.")
            .MaximumLength(100).WithMessage("Name must not exceed 100 characters.");

        RuleFor(x => x.Size)
            .NotEmpty().WithMessage("Size is required.");

        RuleFor(x => x.PricePerHour)
            .GreaterThan(0).WithMessage("Price must be greater than 0.");
    }
}

public class CreateBookingRequestValidator : AbstractValidator<CreateBookingRequest>
{
    public CreateBookingRequestValidator()
    {
        RuleFor(x => x.LockerId)
            .NotEmpty().WithMessage("LockerId is required.");

        RuleFor(x => x.PackageId)
            .NotEmpty().WithMessage("PackageId is required.");

        RuleFor(x => x.SlotIndex)
            .GreaterThanOrEqualTo(0).WithMessage("Slot index must be non-negative.");

        RuleFor(x => x.MobileNumber)
            .NotEmpty().WithMessage("Mobile number is required.")
            .Matches(@"^\+?[0-9]{7,15}$").WithMessage("Invalid mobile number format.");
    }
}

public class SetPinRequestValidator : AbstractValidator<SetPinRequest>
{
    public SetPinRequestValidator()
    {
        RuleFor(x => x.Pin)
            .NotEmpty().WithMessage("PIN is required.")
            .Length(4, 8).WithMessage("PIN must be between 4 and 8 digits.")
            .Matches("^[0-9]+$").WithMessage("PIN must contain only digits.");
    }
}

public class CreatePaymentRequestValidator : AbstractValidator<CreatePaymentRequest>
{
    public CreatePaymentRequestValidator()
    {
        RuleFor(x => x.BookingId)
            .NotEmpty().WithMessage("BookingId is required.");

        RuleFor(x => x.Method)
            .NotEmpty().WithMessage("Payment method is required.")
            .Must(m => new[] { "cash", "card", "momo", "vnpay", "zalopay","wallet" }.Contains(m.ToLower()))
            .WithMessage("Invalid payment method. Allowed: cash, card, momo, vnpay, zzalopay, wallet.");
    }
}

public class CreateOrderRequestValidator : AbstractValidator<CreateOrderRequest>
{
    public CreateOrderRequestValidator()
    {
        RuleFor(x => x.LockerId)
            .NotEmpty().WithMessage("MÃ£ tá»§ khÃ³a khÃ´ng Ä‘Æ°á»£c Ä‘á»ƒ trá»‘ng.");

        RuleFor(x => x.SlotIndex)
            .GreaterThanOrEqualTo(0).WithMessage("Vá»‹ trÃ­ khoang pháº£i >= 0.");

        RuleFor(x => x.PackageId)
            .NotEmpty().WithMessage("MÃ£ gÃ³i khÃ´ng Ä‘Æ°á»£c Ä‘á»ƒ trá»‘ng.");

        RuleFor(x => x.MobileNumber)
            .NotEmpty().WithMessage("Sá»‘ Ä‘iá»‡n thoáº¡i khÃ´ng Ä‘Æ°á»£c Ä‘á»ƒ trá»‘ng.")
            .Matches(@"^\+?[0-9]{7,15}$").WithMessage("Äá»‹nh dáº¡ng sá»‘ Ä‘iá»‡n thoáº¡i khÃ´ng há»£p lá»‡.");

        RuleFor(x => x.CheckInTime)
            .Must(d => d > DateTime.UtcNow).WithMessage("Giá» nháº­n pháº£i trong tÆ°Æ¡ng lai.");

        RuleFor(x => x.DurationHours)
            .GreaterThanOrEqualTo(1).WithMessage("Thá»i gian tá»‘i thiá»ƒu lÃ  1 giá».")
            .LessThanOrEqualTo(7 * 24).WithMessage("Thá»i gian tá»‘i Ä‘a lÃ  7 ngÃ y.");
    }
}

public class ConfirmOrderRequestValidator : AbstractValidator<ConfirmOrderRequest>
{
    public ConfirmOrderRequestValidator()
    {
        // Notes are optional
    }
}

public class SetOrderPinRequestValidator : AbstractValidator<SetOrderPinRequest>
{
    public SetOrderPinRequestValidator()
    {
        RuleFor(x => x.Pin)
            .NotEmpty().WithMessage("MÃ£ PIN khÃ´ng Ä‘Æ°á»£c Ä‘á»ƒ trá»‘ng.")
            .Length(4, 8).WithMessage("MÃ£ PIN pháº£i tá»« 4 Ä‘áº¿n 8 chá»¯ sá»‘.")
            .Matches("^[0-9]+$").WithMessage("MÃ£ PIN chá»‰ chá»©a cÃ¡c chá»¯ sá»‘.");
    }
}

public class CompleteOrderRequestValidator : AbstractValidator<CompleteOrderRequest>
{
    public CompleteOrderRequestValidator()
    {
        // Notes are optional
    }
}

public class CancelOrderRequestValidator : AbstractValidator<CancelOrderRequest>
{
    public CancelOrderRequestValidator()
    {
        RuleFor(x => x.CancellationReason)
            .MaximumLength(500).WithMessage("LÃ½ do há»§y khÃ´ng Ä‘Æ°á»£c vÆ°á»£t quÃ¡ 500 kÃ½ tá»±.")
            .When(x => !string.IsNullOrEmpty(x.CancellationReason));
    }
}

public class ExtendOrderRequestValidator : AbstractValidator<ExtendOrderRequest>
{
    public ExtendOrderRequestValidator()
    {
        RuleFor(x => x.AdditionalHours)
            .GreaterThanOrEqualTo(1).WithMessage("Pháº£i gia háº¡n Ã­t nháº¥t 1 giá».")
            .LessThanOrEqualTo(7 * 24).WithMessage("KhÃ´ng thá»ƒ gia háº¡n quÃ¡ 7 ngÃ y.");
    }
}

