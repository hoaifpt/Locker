using Locker.Backend.Application.Interfaces;
using Locker.Backend.Domain.Enums;
using MediatR;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.Orders.Commands.SetOrderPin;

public record SetOrderPinCommand(Guid OrderId, Guid UserId, string Pin) : IRequest<bool>;

public class SetOrderPinCommandHandler : IRequestHandler<SetOrderPinCommand, bool>
{
    private readonly IOrderRepository _orderRepository;
    private readonly IPasswordHasher _passwordHasher;

    public SetOrderPinCommandHandler(IOrderRepository orderRepository, IPasswordHasher passwordHasher)
    {
        _orderRepository = orderRepository;
        _passwordHasher = passwordHasher;
    }

    public async Task<bool> Handle(SetOrderPinCommand request, CancellationToken cancellationToken)
    {
        var order = await _orderRepository.GetByIdAsync(request.OrderId, cancellationToken);
        if (order == null || order.UserId != request.UserId)
            return false;

        if (order.Status != OrderStatus.Reserved)
            return false;

        order.PinHash = _passwordHasher.Hash(request.Pin);
        order.PinAttempts = 0;
        order.PinLockedUntil = null;

        await _orderRepository.UpdateAsync(order, cancellationToken);
        return true;
    }
}
