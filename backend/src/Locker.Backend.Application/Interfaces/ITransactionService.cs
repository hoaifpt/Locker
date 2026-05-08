using Locker.Backend.Application.Models;
using Locker.Backend.Domain.Enums;

namespace Locker.Backend.Application.Interfaces;

public interface ITransactionService
{
    Task<TransactionDto> CreateTransactionAsync(string userId, CreateTransactionRequest request, CancellationToken cancellationToken);
    Task<TransactionDto> GetTransactionAsync(string id, CancellationToken cancellationToken);
    Task<List<TransactionDto>> GetUserTransactionsAsync(string userId, CancellationToken cancellationToken);
    Task<TransactionDto> UpdateTransactionStatusAsync(string id, TransactionStatus status, CancellationToken cancellationToken);
}

public interface IQrCodeService
{
    Task<QrCodeDto> GenerateQrCodeAsync(string transactionId, string type, CancellationToken cancellationToken);
    Task<bool> ValidateAndUseQrCodeAsync(string code, CancellationToken cancellationToken);
}