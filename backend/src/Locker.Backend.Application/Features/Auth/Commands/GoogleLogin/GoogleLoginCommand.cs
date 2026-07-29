using Locker.Backend.Application.Models;
using MediatR;

namespace Locker.Backend.Application.Features.Auth.Commands.GoogleLogin;

public record GoogleLoginCommand(string IdToken)
    : IRequest<(AuthResponse? Response, string? Error)>;