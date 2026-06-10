namespace Locker.Backend.Application.Features.Wallet.Commands.VnPayInitTopUp;

public record VnPayInitTopUpResponse(
    Guid PaymentId,
    string VnPayUrl,
    decimal Amount,
    DateTime ExpiresAt
);
