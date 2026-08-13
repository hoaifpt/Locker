using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Models;
using MediatR;
using Microsoft.Extensions.Options;

namespace Locker.Backend.Application.Features.Wallet.Commands.SepayInitTopUp;

public class SepayInitTopUpCommandHandler : IRequestHandler<SepayInitTopUpCommand, SepayInitTopUpResponse>
{
    private readonly ISepayService _sepayService;
    private readonly SepaySettings _sepaySettings;

    public SepayInitTopUpCommandHandler(
        ISepayService sepayService,
        IOptions<SepaySettings> sepaySettings)
    {
        _sepayService = sepayService;
        _sepaySettings = sepaySettings.Value;
    }

    public async Task<SepayInitTopUpResponse> Handle(SepayInitTopUpCommand request, CancellationToken cancellationToken)
    {
        var paymentUrl = _sepayService.GenerateSepayPaymentUrl(request.UserId, request.Amount, request.IpAddress);

        return new SepayInitTopUpResponse(true, "SEPAY payment URL generated successfully.", paymentUrl);
    }
}
