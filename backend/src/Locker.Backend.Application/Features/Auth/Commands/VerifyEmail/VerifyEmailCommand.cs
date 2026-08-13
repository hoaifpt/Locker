using Locker.Backend.Application.Interfaces;
using MediatR;
using Microsoft.Extensions.Logging;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.Auth.Commands.VerifyEmail;

public record VerifyEmailCommand(string Token) : IRequest<(bool Success, string? Error)>;

public class VerifyEmailCommandHandler : IRequestHandler<VerifyEmailCommand, (bool Success, string? Error)>
{
    private readonly IIdentityService _identityService;
    private readonly ILogger<VerifyEmailCommandHandler> _logger;

    public VerifyEmailCommandHandler(IIdentityService identityService, ILogger<VerifyEmailCommandHandler> logger)
    {
        _identityService = identityService;
        _logger = logger;
    }

    public async Task<(bool Success, string? Error)> Handle(VerifyEmailCommand request, CancellationToken cancellationToken)
    {
        _logger.LogInformation("VerifyEmail called with token length: {Length}", request.Token?.Length ?? 0);
        
        var user = await _identityService.FindByEmailVerificationTokenAsync(request.Token);
        if (user == null)
        {
            _logger.LogWarning("No user found with token: {Token}", request.Token ?? "null");
            return (false, "Mã xác thực không hợp lệ.");
        }
        
        if (user.EmailVerificationTokenExpiry == null || user.EmailVerificationTokenExpiry < DateTime.UtcNow)
        {
            _logger.LogWarning("Token expired for user {Email}. Expiry: {Expiry}", user.Email, user.EmailVerificationTokenExpiry);
            return (false, "Mã xác thực đã hết hạn.");
        }
        
        _logger.LogInformation("Verifying email for user {Email}", user.Email);
        
        user.IsActive = true;
        user.EmailConfirmed = true;
        user.EmailVerificationToken = null;
        user.EmailVerificationTokenExpiry = null;

        await _identityService.UpdateUserAsync(user);

        return (true, null);
    }
}
