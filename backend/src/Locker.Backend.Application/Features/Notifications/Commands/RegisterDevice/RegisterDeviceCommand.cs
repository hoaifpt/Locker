using Locker.Backend.Application.Interfaces;
using Locker.Backend.Domain.Entities;
using MediatR;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.Notifications.Commands.RegisterDevice;

public record RegisterDeviceCommand(Guid UserId, string DeviceToken, string Platform) : IRequest;

public class RegisterDeviceCommandHandler : IRequestHandler<RegisterDeviceCommand>
{
    private readonly IDeviceTokenRepository _deviceTokenRepository;

    public RegisterDeviceCommandHandler(IDeviceTokenRepository deviceTokenRepository)
    {
        _deviceTokenRepository = deviceTokenRepository;
    }

    public async Task Handle(RegisterDeviceCommand request, CancellationToken cancellationToken)
    {
        var token = new DeviceToken
        {
            UserId = request.UserId,
            Token = request.DeviceToken,
            Platform = request.Platform,
            UpdatedAt = DateTime.UtcNow,
            CreatedAt = DateTime.UtcNow
        };

        await _deviceTokenRepository.UpsertAsync(token, cancellationToken);
    }
}
