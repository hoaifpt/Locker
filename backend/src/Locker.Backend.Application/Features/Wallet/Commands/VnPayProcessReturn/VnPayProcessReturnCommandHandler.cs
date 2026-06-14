using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Models;
using Locker.Backend.Domain.Entities;
using Locker.Backend.Domain.Enums;
using MediatR;
using Microsoft.Extensions.Options;

namespace Locker.Backend.Application.Features.Wallet.Commands.VnPayProcessReturn;

public class VnPayProcessReturnCommandHandler : IRequestHandler<VnPayProcessReturnCommand, VnPayProcessReturnResponse>
{
    private readonly IPaymentRepository _paymentRepository;
    private readonly IWalletTransactionRepository _walletTransactionRepository;
    private readonly IVnPayService _vnPayService;
    private readonly VnPaySettings _vnPaySettings;

    public VnPayProcessReturnCommandHandler(
        IPaymentRepository paymentRepository,
        IWalletTransactionRepository walletTransactionRepository,
        IVnPayService vnPayService,
        IOptions<VnPaySettings> vnPaySettings)
    {
        _paymentRepository = paymentRepository;
        _walletTransactionRepository = walletTransactionRepository;
        _vnPayService = vnPayService;
        _vnPaySettings = vnPaySettings.Value;
    }

    public async Task<VnPayProcessReturnResponse> Handle(VnPayProcessReturnCommand request, CancellationToken cancellationToken)
    {
        if (!_vnPayService.VerifyReturnUrl(request.Parameters, out var errorMessage))
        {
            return new VnPayProcessReturnResponse(
                Success: false,
                Message: errorMessage ?? "Invalid signature"
            );
        }

        if (!request.Parameters.TryGetValue("vnp_ResponseCode", out var responseCode))
        {
            return new VnPayProcessReturnResponse(
                Success: false,
                Message: "Missing response code"
            );
        }

        if (!request.Parameters.TryGetValue("vnp_TxnRef", out var txnRef) || !Guid.TryParse(txnRef, out var paymentId))
        {
            return new VnPayProcessReturnResponse(
                Success: false,
                Message: "Invalid transaction reference"
            );
        }

        if (!request.Parameters.TryGetValue("vnp_Amount", out var amountStr) || !long.TryParse(amountStr, out var vnpAmount))
        {
            return new VnPayProcessReturnResponse(
                Success: false,
                Message: "Invalid amount"
            );
        }

        var payment = await _paymentRepository.GetByIdAsync(paymentId, cancellationToken);
        if (payment == null)
        {
            return new VnPayProcessReturnResponse(
                Success: false,
                Message: "Payment not found"
            );
        }

        if (payment.Status != PaymentStatus.Pending)
        {
            var currentBalance = await _walletTransactionRepository.GetBalanceAsync(payment.UserId, cancellationToken);
            return new VnPayProcessReturnResponse(
                Success: true,
                Message: "Payment already processed",
                PaymentId: payment.Id,
                Amount: payment.Amount,
                NewBalance: currentBalance
            );
        }

        if ((DateTime.UtcNow - payment.CreatedAt).TotalMinutes > _vnPaySettings.PaymentTimeoutMinutes)
        {
            payment.Status = PaymentStatus.Failed;
            await _paymentRepository.UpdateAsync(payment, cancellationToken);
            return new VnPayProcessReturnResponse(
                Success: false,
                Message: "Payment has expired",
                PaymentId: payment.Id,
                VnpResponseCode: responseCode
            );
        }

        var expectedAmount = (long)(payment.Amount * 100);
        if (vnpAmount != expectedAmount)
        {
            return new VnPayProcessReturnResponse(
                Success: false,
                Message: "Amount mismatch"
            );
        }

        if (responseCode != "00")
        {
            payment.Status = PaymentStatus.Failed;
            await _paymentRepository.UpdateAsync(payment, cancellationToken);
            return new VnPayProcessReturnResponse(
                Success: false,
                Message: GetResponseMessage(responseCode),
                PaymentId: payment.Id,
                VnpResponseCode: responseCode
            );
        }

        request.Parameters.TryGetValue("vnp_TransactionNo", out var vnpTxnNo);
        payment.Status = PaymentStatus.Completed;
        payment.TransactionId = vnpTxnNo ?? Guid.NewGuid().ToString();
        payment.PaidAt = DateTime.UtcNow;
        await _paymentRepository.UpdateAsync(payment, cancellationToken);

        var walletTransaction = new WalletTransaction
        {
            UserId = payment.UserId,
            Amount = payment.Amount,
            Type = TransactionType.TopUp,
            Status = TransactionStatus.Completed,
            Description = "Nap tien vi qua VNPay",
            ReferenceId = payment.Id.ToString(),
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };
        await _walletTransactionRepository.CreateAsync(walletTransaction, cancellationToken);

        var newBalance = await _walletTransactionRepository.GetBalanceAsync(payment.UserId, cancellationToken);

        return new VnPayProcessReturnResponse(
            Success: true,
            Message: "Nap tien thanh cong",
            PaymentId: payment.Id,
            Amount: payment.Amount,
            NewBalance: newBalance
        );
    }

    private static string GetResponseMessage(string responseCode)
    {
        return responseCode switch
        {
            "07" => "Tai khoan khong du so du",
            "09" => "The chua dang ky dich vu",
            "10" => "Xac thuc that bai",
            "11" => "Mat ma khong dung",
            "12" => "The het han",
            "13" => "Mat the",
            "24" => "Hoan tac giao dich",
            "51" => "Khong du so du",
            "65" => "Vuot qua han muc",
            "99" => "Loi khac",
            _ => "Thanh toan that bai hoac bi huy bo"
        };
    }
}
