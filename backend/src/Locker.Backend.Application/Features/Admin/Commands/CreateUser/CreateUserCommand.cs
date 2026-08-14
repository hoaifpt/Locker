using Locker.Backend.Application.Interfaces;
using Locker.Backend.Domain.Entities;
using MediatR;

namespace Locker.Backend.Application.Features.Admin.Commands.CreateUser;

public record CreateUserCommand(
    string Username,
    string Email,
    string Password,
    string Role,
    string? FullName,
    string? PhoneNumber
) : IRequest<(User? User, string? Error)>;

public class CreateUserCommandHandler : IRequestHandler<CreateUserCommand, (User? User, string? Error)>
{
    private readonly IIdentityService _identityService;

    public CreateUserCommandHandler(IIdentityService identityService)
    {
        _identityService = identityService;
    }

    public async Task<(User? User, string? Error)> Handle(CreateUserCommand request, CancellationToken cancellationToken)
    {
        if (await _identityService.FindByNameAsync(request.Username) != null)
            return (null, "Username đã tồn tại.");

        if (await _identityService.FindByEmailAsync(request.Email) != null)
            return (null, "Email đã được sử dụng.");

        var user = new User
        {
            UserName = request.Username,
            Email = request.Email,
            FullName = request.FullName,
            PhoneNumber = request.PhoneNumber,
            IsActive = true,
            EmailConfirmed = true
        };

        var (success, errors) = await _identityService.CreateUserAsync(user, request.Password);
        if (!success)
        {
            var errorMsg = string.Join(", ", errors);
            return (null, errorMsg);
        }

        await _identityService.AddToRoleAsync(user, request.Role);
        return (user, null);
    }
}
