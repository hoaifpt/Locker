using MediatR;

namespace Locker.Backend.Application.Features.Wallet.Commands.VnPayInitTopUp;

public record VnPayInitTopUpCommand(Guid UserId, decimal Amount, string IpAddress) : IRequest<VnPayInitTopUpResponse>;
