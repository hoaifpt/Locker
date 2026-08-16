using Locker.Backend.Application.Models;
using Locker.Backend.Domain.Entities;

namespace Locker.Backend.Application.Mapping;

public class WalletTransactionMapper : IMapper<WalletTransaction, WalletTransactionDto>
{
    public WalletTransactionDto Map(WalletTransaction source) => new()
    {
        Id = source.Id,
        UserId = source.UserId,
        Amount = source.Amount,
        Type = source.Type,
        Status = source.Status,
        Description = source.Description,
        ReferenceId = source.ReferenceId,
        RelatedUserId = source.RelatedUserId,
        CreatedAt = source.CreatedAt,
        UpdatedAt = source.UpdatedAt,
    };
}