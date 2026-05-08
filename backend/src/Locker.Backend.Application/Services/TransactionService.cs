using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Models;
using Locker.Backend.Domain.Entities;
using Locker.Backend.Domain.Enums;

namespace Locker.Backend.Application.Services;

public class TransactionService : ITransactionService
{
    private readonly ITransactionRepository _transactionRepository;
    private readonly ILockerSlotRepository _slotRepository;
    private readonly IFoodOrderRepository _foodOrderRepository;
    private readonly IPersonalStorageRepository _storageRepository;

    public TransactionService(
        ITransactionRepository transactionRepository,
        ILockerSlotRepository slotRepository,
        IFoodOrderRepository foodOrderRepository,
        IPersonalStorageRepository storageRepository)
    {
        _transactionRepository = transactionRepository;
        _slotRepository = slotRepository;
        _foodOrderRepository = foodOrderRepository;
        _storageRepository = storageRepository;
    }

    public async Task<TransactionDto> CreateTransactionAsync(string userId, CreateTransactionRequest request, CancellationToken cancellationToken)
    {
        // Find an available slot
        var slots = await _slotRepository.GetByLockerIdAsync(request.LockerId, cancellationToken);
        var availableSlot = slots.FirstOrDefault(s => s.Status == LockerSlotStatus.Available);

        if (availableSlot == null)
            throw new Exception("No available slots in this locker.");

        // Reserve the slot
        availableSlot.Status = LockerSlotStatus.Reserved;
        await _slotRepository.UpdateAsync(availableSlot, cancellationToken);

        var transaction = new Transaction
        {
            UserId = userId,
            LockerId = request.LockerId,
            SlotId = availableSlot.Id,
            Type = request.Type,
            Status = TransactionStatus.Pending
        };

        if (request.Type == TransactionType.SendReceivePackage)
        {
            transaction.ReceiverIdentifier = request.ReceiverIdentifier;
            transaction.PackageId = request.PackageId;
        }
        else if (request.Type == TransactionType.FoodDelivery)
        {
            transaction.TotalAmount = request.FoodItems?.Sum(x => x.Price * x.Quantity) ?? 0;
        }

        await _transactionRepository.AddAsync(transaction, cancellationToken);

        // Sub-entity creation
        if (request.Type == TransactionType.FoodDelivery && request.FoodItems != null)
        {
            var foodOrder = new FoodOrder
            {
                TransactionId = transaction.Id,
                UserId = userId,
                RestaurantName = request.RestaurantName ?? "Unknown",
                FoodTotal = transaction.TotalAmount,
                Items = request.FoodItems.Select(i => new Domain.Entities.OrderItem { Name = i.Name, Price = i.Price, Quantity = i.Quantity }).ToList()
            };
            await _foodOrderRepository.AddAsync(foodOrder, cancellationToken);
        }
        else if (request.Type == TransactionType.PersonalStorage && request.ExpectedEndTime.HasValue)
        {
            var storage = new PersonalStorage
            {
                TransactionId = transaction.Id,
                UserId = userId,
                ExpectedEndTime = request.ExpectedEndTime.Value
            };
            await _storageRepository.AddAsync(storage, cancellationToken);
        }

        return MapToDto(transaction);
    }

    public async Task<TransactionDto> GetTransactionAsync(string id, CancellationToken cancellationToken)
    {
        var transaction = await _transactionRepository.GetByIdAsync(id, cancellationToken);
        if (transaction == null) throw new Exception("Transaction not found");
        return MapToDto(transaction);
    }

    public async Task<List<TransactionDto>> GetUserTransactionsAsync(string userId, CancellationToken cancellationToken)
    {
        var transactions = await _transactionRepository.GetByUserIdAsync(userId, cancellationToken);
        return transactions.Select(MapToDto).ToList();
    }

    public async Task<TransactionDto> UpdateTransactionStatusAsync(string id, TransactionStatus status, CancellationToken cancellationToken)
    {
        var transaction = await _transactionRepository.GetByIdAsync(id, cancellationToken);
        if (transaction == null) throw new Exception("Transaction not found");

        transaction.Status = status;
        if (status == TransactionStatus.Completed || status == TransactionStatus.Canceled)
        {
            transaction.CompletedAt = DateTime.UtcNow;
            // Free up the slot
            if (!string.IsNullOrEmpty(transaction.SlotId))
            {
               var slot = await _slotRepository.GetByIdAsync(transaction.SlotId, cancellationToken);
               if (slot != null)
               {
                   slot.Status = LockerSlotStatus.Available;
                   slot.ActiveTransactionId = null;
                   await _slotRepository.UpdateAsync(slot, cancellationToken);
               }
            }
        }
        else if (status == TransactionStatus.InProgress)
        {
            transaction.StartedAt = DateTime.UtcNow;
            if (!string.IsNullOrEmpty(transaction.SlotId))
            {
               var slot = await _slotRepository.GetByIdAsync(transaction.SlotId, cancellationToken);
               if (slot != null && slot.Status == LockerSlotStatus.Reserved)
               {
                   slot.Status = LockerSlotStatus.Occupied;
                   slot.ActiveTransactionId = transaction.Id;
                   await _slotRepository.UpdateAsync(slot, cancellationToken);
               }
            }
        }

        await _transactionRepository.UpdateAsync(transaction, cancellationToken);
        return MapToDto(transaction);
    }

    private TransactionDto MapToDto(Transaction t)
    {
        return new TransactionDto
        {
            Id = t.Id,
            LockerId = t.LockerId,
            SlotId = t.SlotId,
            Type = t.Type,
            Status = t.Status,
            TotalAmount = t.TotalAmount,
            CreatedAt = t.CreatedAt
        };
    }
}