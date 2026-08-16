using Locker.Backend.Application.Interfaces;
using Locker.Backend.Domain.Enums;
using MediatR;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.Payments.Commands.CompletePayment;

public record CompletePaymentCommand(Guid PaymentId, Guid UserId, string TransactionId) : IRequest<bool>;

public class CompletePaymentCommandHandler : IRequestHandler<CompletePaymentCommand, bool>
{
    private readonly IPaymentRepository _paymentRepository;

    public CompletePaymentCommandHandler(IPaymentRepository paymentRepository)
    {
        _paymentRepository = paymentRepository;
    }

    public async Task<bool> Handle(CompletePaymentCommand request, CancellationToken cancellationToken)
    {
        var payment = await _paymentRepository.GetByIdAsync(request.PaymentId, cancellationToken);
        if (payment == null || payment.UserId != request.UserId) return false;
        if (payment.Status == PaymentStatus.Completed) return true;
        if (payment.Status != PaymentStatus.Pending) return false;

        payment.Status = PaymentStatus.Completed;
        payment.TransactionId = request.TransactionId;
        payment.PaidAt = DateTime.UtcNow;

        await _paymentRepository.UpdateAsync(payment, cancellationToken);

        


        return true;
    }
}
