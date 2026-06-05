using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Models;
using Locker.Backend.Domain.Entities;
using Locker.Backend.Domain.Enums;
using MediatR;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.SendReceiveOrders.Commands.CreateSendReceiveOrder;

public record CreateSendReceiveOrderCommand(
    Guid SenderId,
    string ReceiverPhone,
    Guid LockerId,
    int SlotIndex,
    string PinCode,
    string? Notes) : IRequest<SendReceiveOrderDto?>;

public class CreateSendReceiveOrderCommandHandler : IRequestHandler<CreateSendReceiveOrderCommand, SendReceiveOrderDto?>
{
    private readonly ISendReceiveOrderRepository _repository;
    private readonly IPasswordHasher _passwordHasher;

    public CreateSendReceiveOrderCommandHandler(ISendReceiveOrderRepository repository, IPasswordHasher passwordHasher)
    {
        _repository = repository;
        _passwordHasher = passwordHasher;
    }

    public async Task<SendReceiveOrderDto?> Handle(CreateSendReceiveOrderCommand request, CancellationToken cancellationToken)
    {
        var item = new SendReceiveOrder
        {
            SenderId = request.SenderId,
            ReceiverPhone = request.ReceiverPhone,
            LockerId = request.LockerId,
            SlotIndex = request.SlotIndex,
            PinHash = _passwordHasher.Hash(request.PinCode),
            Status = SendReceiveStatus.Initiated,
            Notes = request.Notes
        };

        await _repository.CreateAsync(item, cancellationToken);

        return new SendReceiveOrderDto
        {
            Id = item.Id,
            SenderId = item.SenderId,
            ReceiverPhone = item.ReceiverPhone,
            LockerId = item.LockerId,
            SlotIndex = item.SlotIndex,
            Status = item.Status,
            Notes = item.Notes,
            CreatedAt = item.CreatedAt
        };
    }
}
