namespace Locker.Backend.Application.Features.Wallet.Commands.SepayInitTopUp;

public record SepayInitTopUpResponse(
    bool Succeeded,
    string Message,
    string? PaymentUrl = null,
    Guid? PaymentId = null,
    decimal? Amount = null,
    DateTime? ExpiresAt = null,
    string? CheckoutUrl = null,
    IReadOnlyDictionary<string, string>? FormFields = null);
