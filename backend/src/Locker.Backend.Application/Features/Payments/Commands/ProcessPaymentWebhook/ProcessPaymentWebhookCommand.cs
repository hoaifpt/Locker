using Locker.Backend.Application.Interfaces;
using Locker.Backend.Domain.Enums;
using MediatR;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.Payments.Commands.ProcessPaymentWebhook;

public record ProcessPaymentWebhookCommand(Guid PaymentId, string TransactionId, bool IsSuccess) : IRequest<PaymentWebhookResult>;

public class ProcessPaymentWebhookCommandHandler : IRequestHandler<ProcessPaymentWebhookCommand, PaymentWebhookResult>
{
    private readonly IPaymentRepository _paymentRepository;

    public ProcessPaymentWebhookCommandHandler(IPaymentRepository paymentRepository)
    {
        _paymentRepository = paymentRepository;
    }

    public async Task<PaymentWebhookResult> Handle(ProcessPaymentWebhookCommand request, CancellationToken cancellationToken)
    {
        var payment = await _paymentRepository.GetByIdAsync(request.PaymentId, cancellationToken);
        if (payment == null) return PaymentWebhookResult.NotFound;

        if (payment.Status == PaymentStatus.Completed)
        {
            return PaymentWebhookResult.Ignored;
        }

        payment.TransactionId = request.TransactionId;
        payment.PaidAt = DateTime.UtcNow;
        payment.Status = request.IsSuccess ? PaymentStatus.Completed : PaymentStatus.Failed;

        await _paymentRepository.UpdateAsync(payment, cancellationToken);
        return PaymentWebhookResult.Updated;
    }
}

public enum PaymentWebhookResult
{
    Updated,
    NotFound,
    Ignored
}
