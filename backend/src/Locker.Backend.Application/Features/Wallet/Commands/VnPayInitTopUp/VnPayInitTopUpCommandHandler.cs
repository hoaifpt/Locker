using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Models;
using Locker.Backend.Domain.Entities;
using Locker.Backend.Domain.Enums;
using MediatR;
using Microsoft.Extensions.Options;

namespace Locker.Backend.Application.Features.Wallet.Commands.VnPayInitTopUp;

public class VnPayInitTopUpCommandHandler : IRequestHandler<VnPayInitTopUpCommand, VnPayInitTopUpResponse>
{
    private readonly IPaymentRepository _paymentRepository;
    private readonly IVnPayService _vnPayService;
    private readonly VnPaySettings _vnPaySettings;

    public VnPayInitTopUpCommandHandler(
        IPaymentRepository paymentRepository,
        IVnPayService vnPayService,
        IOptions<VnPaySettings> vnPaySettings)
    {
        _paymentRepository = paymentRepository;
        _vnPayService = vnPayService;
        _vnPaySettings = vnPaySettings.Value;
    }

    public async Task<VnPayInitTopUpResponse> Handle(VnPayInitTopUpCommand request, CancellationToken cancellationToken)
    {
        var expiresAt = DateTime.UtcNow.AddMinutes(_vnPaySettings.PaymentTimeoutMinutes);

        var payment = new Payment
        {
            UserId = request.UserId,
            Amount = request.Amount,
            Method = "vnpay",
            Status = PaymentStatus.Pending,
            CreatedAt = DateTime.UtcNow
        };

        await _paymentRepository.CreateAsync(payment, cancellationToken);

        var response = new VnPayInitTopUpResponse(
            PaymentId: payment.Id,
            VnPayUrl: string.Empty,
            Amount: request.Amount,
            ExpiresAt: expiresAt
        );

        response = response with { VnPayUrl = _vnPayService.CreatePaymentUrl(response, request.IpAddress) };

        return response;
    }
}
