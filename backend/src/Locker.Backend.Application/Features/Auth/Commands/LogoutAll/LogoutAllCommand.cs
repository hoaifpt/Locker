using Locker.Backend.Application.Interfaces;
using MediatR;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.Auth.Commands.LogoutAll;

public record LogoutAllCommand(Guid UserId) : IRequest;

public class LogoutAllCommandHandler : IRequestHandler<LogoutAllCommand>
{
    private readonly IRefreshTokenRepository _refreshTokenRepository;

    public LogoutAllCommandHandler(IRefreshTokenRepository refreshTokenRepository)
    {
        _refreshTokenRepository = refreshTokenRepository;
    }

    public async Task Handle(LogoutAllCommand request, CancellationToken cancellationToken)
    {
        await _refreshTokenRepository.RevokeAllByUserIdAsync(request.UserId, cancellationToken);
    }
}
