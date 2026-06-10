using MediatR;

namespace Locker.Backend.Application.Features.Wallet.Commands.VnPayProcessReturn;

public record VnPayProcessReturnCommand(IDictionary<string, string> Parameters) : IRequest<VnPayProcessReturnResponse>;
