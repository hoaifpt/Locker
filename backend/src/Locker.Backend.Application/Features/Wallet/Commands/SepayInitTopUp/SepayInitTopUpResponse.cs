namespace Locker.Backend.Application.Features.Wallet.Commands.SepayInitTopUp;

public record SepayInitTopUpResponse(
    bool Succeeded,
    string Message,
    string? PaymentUrl = null);
