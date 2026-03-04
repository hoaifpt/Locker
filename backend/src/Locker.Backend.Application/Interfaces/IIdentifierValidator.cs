namespace Locker.Backend.Application.Interfaces;

public interface IIdentifierValidator
{
    /// <summary>Validate an email address: format check + DNS MX record lookup.</summary>
    Task<(bool IsValid, string? Error)> ValidateEmailAsync(string email, CancellationToken cancellationToken);

    /// <summary>Validate a phone number using libphonenumber (E.164 or local format).</summary>
    (bool IsValid, string? Error) ValidatePhoneNumber(string phoneNumber);
}
