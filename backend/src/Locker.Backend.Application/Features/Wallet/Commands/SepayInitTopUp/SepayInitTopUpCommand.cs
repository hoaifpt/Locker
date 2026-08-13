using MediatR;

namespace Locker.Backend.Application.Features.Wallet.Commands.SepayInitTopUp;

public record SepayInitTopUpCommand(Guid UserId, decimal Amount, string IpAddress) : IRequest<SepayInitTopUpResponse>;
