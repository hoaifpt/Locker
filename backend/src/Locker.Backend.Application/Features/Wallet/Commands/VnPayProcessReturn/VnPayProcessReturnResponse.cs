namespace Locker.Backend.Application.Features.Wallet.Commands.VnPayProcessReturn;

public record VnPayProcessReturnResponse(
    bool Success,
    string Message,
    Guid? PaymentId = null,
    decimal? Amount = null,
    decimal? NewBalance = null,
    string? VnpResponseCode = null
);
