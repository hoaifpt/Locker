using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Mapping;
using Locker.Backend.Application.Models;
using MediatR;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.Admin.Queries.GetAllWalletTopUps;

public record GetAllWalletTopUpsQuery(
    DateTime? DateFrom,
    DateTime? DateTo) : IRequest<List<WalletTransactionDto>>;

public class GetAllWalletTopUpsQueryHandler
    : IRequestHandler<GetAllWalletTopUpsQuery, List<WalletTransactionDto>>
{
    private readonly IWalletTransactionRepository _walletTransactionRepository;
    private readonly IIdentityService _identityService;
    private readonly WalletTransactionMapper _mapper;

    public GetAllWalletTopUpsQueryHandler(
        IWalletTransactionRepository walletTransactionRepository,
        IIdentityService identityService,
        WalletTransactionMapper mapper)
    {
        _walletTransactionRepository = walletTransactionRepository;
        _identityService = identityService;
        _mapper = mapper;
    }

    public async Task<List<WalletTransactionDto>> Handle(
        GetAllWalletTopUpsQuery request,
        CancellationToken cancellationToken)
    {
        var topUps = await _walletTransactionRepository.GetTopUpsAsync(
            request.DateFrom, request.DateTo, cancellationToken);

        // Hydrate UserName cho mỗi transaction — IdentityService lấy
        // theo UserId. Nếu user bị xoá mềm, để null thay vì throw.
        var userCache = new Dictionary<Guid, string?>();
        var dtos = new List<WalletTransactionDto>(topUps.Count);

        foreach (var t in topUps)
        {
            var dto = _mapper.Map(t);
            if (!userCache.TryGetValue(t.UserId, out var userName))
            {
                var user = await _identityService.FindByIdAsync(t.UserId.ToString());
                userName = user?.UserName;
                userCache[t.UserId] = userName;
            }
            dto.UserName = userName;
            dtos.Add(dto);
        }

        return dtos;
    }
}