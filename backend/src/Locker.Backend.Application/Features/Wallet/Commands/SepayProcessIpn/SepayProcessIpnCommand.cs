using System.Globalization;
using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Models;
using Locker.Backend.Domain.Entities;
using Locker.Backend.Domain.Enums;
using MediatR;

namespace Locker.Backend.Application.Features.Wallet.Commands.SepayProcessIpn;

public record SepayProcessIpnCommand(SepayIpnRequest Request) : IRequest<SepayProcessIpnResponse>;

public record SepayProcessIpnResponse(bool Success, string Message, Guid? PaymentId = null);

public class SepayProcessIpnCommandHandler : IRequestHandler<SepayProcessIpnCommand, SepayProcessIpnResponse>
{
    private readonly IPaymentRepository _paymentRepository;
    private readonly IWalletTransactionRepository _walletTransactionRepository;

    public SepayProcessIpnCommandHandler(
        IPaymentRepository paymentRepository,
        IWalletTransactionRepository walletTransactionRepository)
    {
        _paymentRepository = paymentRepository;
        _walletTransactionRepository = walletTransactionRepository;
    }

    public async Task<SepayProcessIpnResponse> Handle(SepayProcessIpnCommand request, CancellationToken cancellationToken)
    {
        var ipn = request.Request;
        if (!IsPaidNotification(ipn))
        {
            return new SepayProcessIpnResponse(true, "IPN ignored because it is not a paid notification.");
        }

        if (!TryParseTopUpInvoiceNumber(ipn.Order.OrderInvoiceNumber, out var paymentId))
        {
            return new SepayProcessIpnResponse(false, "Invalid order invoice number.");
        }

        var payment = await _paymentRepository.GetByIdAsync(paymentId, cancellationToken);
        if (payment == null)
        {
            return new SepayProcessIpnResponse(false, "Payment not found.", paymentId);
        }

        if (payment.Method != "sepay")
        {
            return new SepayProcessIpnResponse(false, "Payment method mismatch.", paymentId);
        }

        if (!IsSameAmount(payment.Amount, ipn.Order.OrderAmount, ipn.Transaction.TransactionAmount))
        {
            return new SepayProcessIpnResponse(false, "Payment amount mismatch.", paymentId);
        }

        if (payment.Status == PaymentStatus.Completed)
        {
            return new SepayProcessIpnResponse(true, "Payment already processed.", paymentId);
        }

        if (payment.Status != PaymentStatus.Pending)
        {
            return new SepayProcessIpnResponse(false, "Payment is not pending.", paymentId);
        }

        var gatewayTransactionId = FirstNotEmpty(ipn.Transaction.TransactionId, ipn.Transaction.Id, ipn.Order.OrderId);
        var existingWalletTransaction = await _walletTransactionRepository.FindOneAsync(
            x => x.ReferenceId == payment.Id.ToString() && x.Type == TransactionType.TopUp,
            cancellationToken);

        payment.Status = PaymentStatus.Completed;
        payment.TransactionId = gatewayTransactionId;
        payment.PaidAt = ParseSepayDate(ipn.Transaction.TransactionDate) ?? DateTime.UtcNow;
        await _paymentRepository.UpdateAsync(payment, cancellationToken);

        if (existingWalletTransaction == null)
        {
            var walletTransaction = new WalletTransaction
            {
                UserId = payment.UserId,
                Amount = payment.Amount,
                Type = TransactionType.TopUp,
                Status = TransactionStatus.Completed,
                Description = $"Nap tien vi qua SePay. Ma GD: {gatewayTransactionId}",
                ReferenceId = payment.Id.ToString(),
                CreatedAt = payment.PaidAt ?? DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };

            await _walletTransactionRepository.CreateAsync(walletTransaction, cancellationToken);
        }

        return new SepayProcessIpnResponse(true, "Payment updated.", paymentId);
    }

    private static bool IsPaidNotification(SepayIpnRequest ipn)
    {
        return string.Equals(ipn.NotificationType, "ORDER_PAID", StringComparison.OrdinalIgnoreCase)
            && string.Equals(ipn.Order.OrderStatus, "CAPTURED", StringComparison.OrdinalIgnoreCase)
            && string.Equals(ipn.Transaction.TransactionStatus, "APPROVED", StringComparison.OrdinalIgnoreCase);
    }

    private static bool IsSameAmount(decimal expectedAmount, params string[] amountValues)
    {
        foreach (var amountValue in amountValues)
        {
            if (string.IsNullOrWhiteSpace(amountValue))
            {
                continue;
            }

            if (decimal.TryParse(amountValue, NumberStyles.Number, CultureInfo.InvariantCulture, out var parsed) &&
                decimal.Round(parsed, 0) == decimal.Round(expectedAmount, 0))
            {
                return true;
            }
        }

        return false;
    }

    private static DateTime? ParseSepayDate(string? value)
    {
        if (DateTime.TryParseExact(
                value,
                "yyyy-MM-dd HH:mm:ss",
                CultureInfo.InvariantCulture,
                DateTimeStyles.AssumeLocal,
                out var parsed))
        {
            return parsed.ToUniversalTime();
        }

        return null;
    }

    private static string FirstNotEmpty(params string[] values)
    {
        return values.FirstOrDefault(value => !string.IsNullOrWhiteSpace(value)) ?? Guid.NewGuid().ToString("N");
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
