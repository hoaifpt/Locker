using DnsClient;
using Locker.Backend.Application.Interfaces;
using PhoneNumbers;
using System.Text.RegularExpressions;

namespace Locker.Backend.Infrastructure.Services;

public class IdentifierValidator : IIdentifierValidator
{
    private static readonly PhoneNumberUtil _phoneUtil = PhoneNumberUtil.GetInstance();
    // Regex for a basic email format check before doing DNS lookup
    private static readonly Regex _emailRegex = new(
        @"^[^@\s]+@[^@\s]+\.[^@\s]+$",
        RegexOptions.Compiled | RegexOptions.IgnoreCase);

    public async Task<(bool IsValid, string? Error)> ValidateEmailAsync(string email, CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(email))
            return (false, "Email khÃ´ng Ä‘Æ°á»£c Ä‘á»ƒ trá»‘ng.");

        if (!_emailRegex.IsMatch(email))
            return (false, "Äá»‹nh dáº¡ng email khÃ´ng há»£p lá»‡.");

        // Extract domain
        var domain = email.Split('@')[1];

        // DNS MX record check to verify the domain really accepts email
        try
        {
            var lookup = new LookupClient(new LookupClientOptions { Timeout = TimeSpan.FromSeconds(5) });
            var result = await lookup.QueryAsync(domain, QueryType.MX, cancellationToken: cancellationToken);

            if (result.HasError || !result.Answers.MxRecords().Any())
            {
                // Fallback: check A record (some small providers use A instead of MX)
                var aResult = await lookup.QueryAsync(domain, QueryType.A, cancellationToken: cancellationToken);
                if (aResult.HasError || !aResult.Answers.ARecords().Any())
                    return (false, $"Domain '{domain}' khÃ´ng tá»“n táº¡i hoáº·c khÃ´ng thá»ƒ nháº­n email.");
            }
        }
        catch (OperationCanceledException)
        {
            throw;
        }
        catch
        {
            // If DNS lookup fails due to network (e.g., offline env), fall through
            // Uncomment the return below to be strict in production:
            // return (false, $"KhÃ´ng thá»ƒ xÃ¡c minh domain '{domain}'. Vui lÃ²ng thá»­ láº¡i.");
        }

        return (true, null);
    }

    public (bool IsValid, string? Error) ValidatePhoneNumber(string phoneNumber)
    {
        if (string.IsNullOrWhiteSpace(phoneNumber))
            return (false, "Sá»‘ Ä‘iá»‡n thoáº¡i khÃ´ng Ä‘Æ°á»£c Ä‘á»ƒ trá»‘ng.");

        try
        {
            // Try E.164 international format first (e.g., +84901234567)
            PhoneNumber? parsed = null;

            if (phoneNumber.StartsWith("+"))
            {
                parsed = _phoneUtil.Parse(phoneNumber, null);
            }
            else
            {
                // Try with common regions; default to VN for local numbers starting with 0
                var region = phoneNumber.StartsWith("0") ? "VN" : null;
                if (region == null)
                    return (false, "Sá»‘ Ä‘iá»‡n thoáº¡i pháº£i báº¯t Ä‘áº§u báº±ng '+' (Ä‘á»‹nh dáº¡ng quá»‘c táº¿) hoáº·c '0' (sá»‘ ná»™i Ä‘á»‹a Viá»‡t Nam).");

                parsed = _phoneUtil.Parse(phoneNumber, region);
            }

            if (!_phoneUtil.IsValidNumber(parsed))
                return (false, "Sá»‘ Ä‘iá»‡n thoáº¡i khÃ´ng há»£p lá»‡.");

            var numberType = _phoneUtil.GetNumberType(parsed);

            // Allow mobile and fixed-line (some countries use fixed-line for SMS)
            bool isRealNumber = numberType == PhoneNumberType.MOBILE
                || numberType == PhoneNumberType.FIXED_LINE_OR_MOBILE
                || numberType == PhoneNumberType.FIXED_LINE;

            if (!isRealNumber)
                return (false, "Sá»‘ Ä‘iá»‡n thoáº¡i pháº£i lÃ  sá»‘ di Ä‘á»™ng hoáº·c cá»‘ Ä‘á»‹nh há»£p lá»‡.");
        }
        catch (NumberParseException ex)
        {
            return (false, $"Sá»‘ Ä‘iá»‡n thoáº¡i khÃ´ng há»£p lá»‡: {ex.Message}");
        }

        return (true, null);
    }
}
