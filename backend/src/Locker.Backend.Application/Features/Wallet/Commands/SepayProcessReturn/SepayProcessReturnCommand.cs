using Locker.Backend.Application.Interfaces;
using Locker.Backend.Domain.Enums;
using MediatR;

namespace Locker.Backend.Application.Features.Wallet.Commands.SepayProcessReturn;

public record SepayProcessReturnCommand(IDictionary<string, string> Parameters) : IRequest<SepayProcessReturnResponse>;

public record SepayProcessReturnResponse(bool Success, string Message, string? TransactionId = null);

public class SepayProcessReturnCommandHandler : IRequestHandler<SepayProcessReturnCommand, SepayProcessReturnResponse>
{
    private readonly IPaymentRepository _paymentRepository;

    public SepayProcessReturnCommandHandler(IPaymentRepository paymentRepository)
    {
        _paymentRepository = paymentRepository;
    }

    public async Task<SepayProcessReturnResponse> Handle(SepayProcessReturnCommand request, CancellationToken cancellationToken)
    {
        var paymentId = TryGetPaymentId(request.Parameters);
        if (paymentId == Guid.Empty)
        {
            return new SepayProcessReturnResponse(
                true,
                "Da nhan callback tu SePay. Ket qua thanh toan se duoc xac nhan bang IPN webhook.");
        }

        var payment = await _paymentRepository.GetByIdAsync(paymentId, cancellationToken);
        if (payment == null)
        {
            return new SepayProcessReturnResponse(false, "Payment not found.", paymentId.ToString());
        }

        return payment.Status switch
        {
            PaymentStatus.Completed => new SepayProcessReturnResponse(true, "Nap tien thanh cong.", payment.TransactionId),
            PaymentStatus.Failed => new SepayProcessReturnResponse(false, "Thanh toan that bai hoac da bi huy.", payment.TransactionId),
            _ => new SepayProcessReturnResponse(
                true,
                "Thanh toan dang cho IPN tu SePay xac nhan.",
                payment.Id.ToString())
        };
    }

    private static Guid TryGetPaymentId(IDictionary<string, string> parameters)
    {
        if (parameters.TryGetValue("paymentId", out var paymentIdValue) &&
            Guid.TryParse(paymentIdValue, out var paymentId))
        {
            return paymentId;
        }

        if (parameters.TryGetValue("order_invoice_number", out var invoiceNumber) ||
            parameters.TryGetValue("orderInvoiceNumber", out invoiceNumber))
        {
            return TryParseTopUpInvoiceNumber(invoiceNumber, out paymentId) ? paymentId : Guid.Empty;
        }

        return Guid.Empty;
    }

    private static bool TryParseTopUpInvoiceNumber(string? invoiceNumber, out Guid paymentId)
    {
        paymentId = Guid.Empty;
        const string prefix = "TOPUP_";

        if (string.IsNullOrWhiteSpace(invoiceNumber) ||
            !invoiceNumber.StartsWith(prefix, StringComparison.OrdinalIgnoreCase))
        {
            return false;
        }

        return Guid.TryParseExact(invoiceNumber[prefix.Length..], "N", out paymentId);
    }
}
