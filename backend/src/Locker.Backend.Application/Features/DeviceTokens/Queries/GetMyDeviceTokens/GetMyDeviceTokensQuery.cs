using Locker.Backend.Application.Interfaces;
using Locker.Backend.Domain.Entities;
using MediatR;
using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.DeviceTokens.Queries.GetMyDeviceTokens;

public record GetMyDeviceTokensQuery(Guid UserId) : IRequest<List<DeviceToken>>;

public class GetMyDeviceTokensQueryHandler : IRequestHandler<GetMyDeviceTokensQuery, List<DeviceToken>>
{
    private readonly IDeviceTokenRepository _repository;

    public GetMyDeviceTokensQueryHandler(IDeviceTokenRepository repository)
    {
        _repository = repository;
    }

    public async Task<List<DeviceToken>> Handle(GetMyDeviceTokensQuery request, CancellationToken cancellationToken)
    {
        return await _repository.GetByUserIdAsync(request.UserId, cancellationToken);
    }
}
