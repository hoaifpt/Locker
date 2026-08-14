using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Models;
using Locker.Backend.Domain.Entities;
using Locker.Backend.Domain.Enums;
using MediatR;
using Microsoft.Extensions.Options;

namespace Locker.Backend.Application.Features.Wallet.Commands.SepayInitTopUp;

public class SepayInitTopUpCommandHandler : IRequestHandler<SepayInitTopUpCommand, SepayInitTopUpResponse>
{
    private readonly SepaySettings _sepaySettings;
    private readonly IPaymentRepository _paymentRepository;

    public SepayInitTopUpCommandHandler(
        IOptions<SepaySettings> sepaySettings,
        IPaymentRepository paymentRepository)
    {
        _sepaySettings = sepaySettings.Value;
        _paymentRepository = paymentRepository;
    }

    public async Task<SepayInitTopUpResponse> Handle(SepayInitTopUpCommand request, CancellationToken cancellationToken)
    {
        var payment = new Payment
        {
            Id = Guid.NewGuid(),
            UserId = request.UserId,
            Amount = request.Amount,
            Method = "sepay",
            Status = PaymentStatus.Pending,
            CreatedAt = DateTime.UtcNow
        };

        // Mã chuyển khoản = TOPUP_<guid không gạch> để IPN parse trực tiếp ra payment.Id
        payment.SepayCode = $"TOPUP_{payment.Id:N}";

        await _paymentRepository.CreateAsync(payment, cancellationToken);

        // =========================================================
        // CẬP NHẬT MÃ NGÂN HÀNG CHUẨN ĐÃ TEST CHẠY THÀNH CÔNG
        // =========================================================
        string bankId = "TPB";
        string accountNo = "84519828888";
        string accountName = "PHAM DUC HUNG";

        string cleanVietQrUrl = $"https://img.vietqr.io/image/{bankId}-{accountNo}-compact.png" +
                                $"?amount={decimal.Truncate(request.Amount).ToString("0")}" +
                                $"&addInfo={System.Net.WebUtility.UrlEncode(payment.SepayCode)}" +
                                $"&accountName={System.Net.WebUtility.UrlEncode(accountName)}";

        var expiresAt = payment.CreatedAt.AddMinutes(_sepaySettings.PaymentTimeoutMinutes);

        Console.WriteLine($"[VIETQR] Đã tạo link QR động chuẩn: {cleanVietQrUrl}");

        return new SepayInitTopUpResponse(
            Succeeded: true,
            Message: "VietQR dynamic checkout generated successfully.",
            PaymentUrl: cleanVietQrUrl,
            PaymentId: payment.Id,
            Amount: request.Amount,
            ExpiresAt: expiresAt,
            CheckoutUrl: cleanVietQrUrl,
            SepayCode: payment.SepayCode,
            FormFields: new Dictionary<string, string>());
    }
}