using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Models;
using Locker.Backend.Domain.Entities;
using Locker.Backend.Domain.Enums;
using MediatR;
using Microsoft.Extensions.Options;

namespace Locker.Backend.Application.Features.Wallet.Commands.SepayInitTopUp;

public class SepayInitTopUpCommandHandler : IRequestHandler<SepayInitTopUpCommand, SepayInitTopUpResponse>
{
    private readonly ISepayService _sepayService;
    private readonly SepaySettings _sepaySettings;
    private readonly IPaymentRepository _paymentRepository;

    

    public SepayInitTopUpCommandHandler(
        ISepayService sepayService,
        IOptions<SepaySettings> sepaySettings,
        IPaymentRepository paymentRepository)
    {
        _sepayService = sepayService;
        _sepaySettings = sepaySettings.Value;
        _paymentRepository = paymentRepository;
    }

    public async Task<SepayInitTopUpResponse> Handle(SepayInitTopUpCommand request, CancellationToken cancellationToken)
    {
        var payment = new Payment
        {
            UserId = request.UserId,
            Amount = request.Amount,
            Method = "sepay",
            Status = PaymentStatus.Pending,
            CreatedAt = DateTime.UtcNow
        };

        await _paymentRepository.CreateAsync(payment, cancellationToken);

        var checkout = _sepayService.CreateTopUpCheckout(payment.Id, request.UserId, request.Amount);
        var expiresAt = payment.CreatedAt.AddMinutes(_sepaySettings.PaymentTimeoutMinutes);

        return new SepayInitTopUpResponse(
            Succeeded: true,
            Message: "SEPAY checkout form generated successfully.",
            PaymentUrl: checkout.CheckoutUrl,
            PaymentId: payment.Id,
            Amount: request.Amount,
            ExpiresAt: expiresAt,
            CheckoutUrl: checkout.CheckoutUrl,
            FormFields: checkout.Fields);
    }
}
