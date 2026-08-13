namespace Locker.Backend.Application.Models;

public record PaymentReturnResponse(
    bool IsSuccess,
    string Message,
    decimal Amount,
    Guid UserId,
    DateTime TransactionDate,
    string TransactionId,
    string GatewayTransactionNo
);