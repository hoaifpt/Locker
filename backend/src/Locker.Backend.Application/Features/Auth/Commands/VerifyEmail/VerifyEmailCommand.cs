using Locker.Backend.Application.Interfaces;
using MediatR;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.Auth.Commands.VerifyEmail;

public record VerifyEmailCommand(string Token) : IRequest<(bool Success, string? Error)>;

public class VerifyEmailCommandHandler : IRequestHandler<VerifyEmailCommand, (bool Success, string? Error)>
{
    private readonly IIdentityService _identityService;

    public VerifyEmailCommandHandler(IIdentityService identityService)
    {
        _identityService = identityService;
    }

    public async Task<(bool Success, string? Error)> Handle(VerifyEmailCommand request, CancellationToken cancellationToken)
    {
        var user = await _identityService.FindByEmailVerificationTokenAsync(request.Token);
        if (user == null ||
            user.EmailVerificationTokenExpiry == null ||
            user.EmailVerificationTokenExpiry < DateTime.UtcNow)
            return (false, "Mã xác thực không hợp lệ hoặc đã hết hạn.");

        user.IsActive = true;
        user.EmailConfirmed = true;
        user.EmailVerificationToken = null;
        user.EmailVerificationTokenExpiry = null;

        await _identityService.UpdateUserAsync(user);

        return (true, null);
    }
}
