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
            return (false, "Email không được để trống.");

        if (!_emailRegex.IsMatch(email))
            return (false, "Định dạng email không hợp lệ.");

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
                    return (false, $"Domain '{domain}' không tồn tại hoặc không thể nhận email.");
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
            // return (false, $"Không thể xác minh domain '{domain}'. Vui lòng thử lại.");
        }

        return (true, null);
    }

    public (bool IsValid, string? Error) ValidatePhoneNumber(string phoneNumber)
    {
        if (string.IsNullOrWhiteSpace(phoneNumber))
            return (false, "Số điện thoại không được để trống.");

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
                    return (false, "Số điện thoại phải bắt đầu bằng '+' (định dạng quốc tế) hoặc '0' (số nội địa Việt Nam).");

                parsed = _phoneUtil.Parse(phoneNumber, region);
            }

            if (!_phoneUtil.IsValidNumber(parsed))
                return (false, "Số điện thoại không hợp lệ.");

            var numberType = _phoneUtil.GetNumberType(parsed);

            // Allow mobile and fixed-line (some countries use fixed-line for SMS)
            bool isRealNumber = numberType == PhoneNumberType.MOBILE
                || numberType == PhoneNumberType.FIXED_LINE_OR_MOBILE
                || numberType == PhoneNumberType.FIXED_LINE;

            if (!isRealNumber)
                return (false, "Số điện thoại phải là số di động hoặc cố định hợp lệ.");
        }
        catch (NumberParseException ex)
        {
            return (false, $"Số điện thoại không hợp lệ: {ex.Message}");
        }

        return (true, null);
    }
}
