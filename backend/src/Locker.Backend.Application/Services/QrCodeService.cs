using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Models;
using Locker.Backend.Domain.Entities;

namespace Locker.Backend.Application.Services;

public class QrCodeService : IQrCodeService
{
    private readonly IQrCodeRepository _qrCodeRepository;
    private readonly ITransactionRepository _transactionRepository;

    public QrCodeService(IQrCodeRepository qrCodeRepository, ITransactionRepository transactionRepository)
    {
        _qrCodeRepository = qrCodeRepository;
        _transactionRepository = transactionRepository;
    }

    public async Task<QrCodeDto> GenerateQrCodeAsync(string transactionId, string type, CancellationToken cancellationToken)
    {
        var transaction = await _transactionRepository.GetByIdAsync(transactionId, cancellationToken);
        if (transaction == null) throw new Exception("Transaction not found");

        var code = Guid.NewGuid().ToString("N"); // generate random code

        var qrCode = new QrCode
        {
            TransactionId = transactionId,
            Type = type,
            Code = code,
            ExpiresAt = DateTime.UtcNow.AddMinutes(5), // 5 min expiry typical for MVP
            IsUsed = false
        };

        await _qrCodeRepository.AddAsync(qrCode, cancellationToken);

        return new QrCodeDto
        {
            Id = qrCode.Id,
            TransactionId = qrCode.TransactionId,
            Type = qrCode.Type,
            Code = qrCode.Code,
            ExpiresAt = qrCode.ExpiresAt,
            IsUsed = qrCode.IsUsed
        };
    }

    public async Task<bool> ValidateAndUseQrCodeAsync(string code, CancellationToken cancellationToken)
    {
        var validQr = await _qrCodeRepository.GetValidCodeAsync(code, cancellationToken);
        
        if (validQr == null)
            return false;

        validQr.IsUsed = true;
        await _qrCodeRepository.UpdateAsync(validQr, cancellationToken);

        return true;
    }
}