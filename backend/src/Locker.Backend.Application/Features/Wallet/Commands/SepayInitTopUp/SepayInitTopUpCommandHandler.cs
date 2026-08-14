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

    private static string CreateSepayCode()
    {
        var suffix = Guid.NewGuid()
        .ToString("N")
        .Substring(0, 8)
        .ToUpperInvariant();

        return $"DH{suffix}";
    }

    public async Task<SepayInitTopUpResponse> Handle(SepayInitTopUpCommand request, CancellationToken cancellationToken)
    {
        var sepayCode = CreateSepayCode();

        var payment = new Payment
        {
            UserId = request.UserId,
            Amount = request.Amount,
            Method = "sepay",
            Status = PaymentStatus.Pending,
            SepayCode = sepayCode,
            CreatedAt = DateTime.UtcNow
        };

        await _paymentRepository.CreateAsync(payment, cancellationToken);

        var checkout = _sepayService.CreateTopUpCheckout(
            payment.Id,
            request.UserId,
            request.Amount,
            sepayCode);

        // =========================================================
        // 💡 GIẢI PHÁP TẠO MÃ QR ĐỘNG CHUẨN QUỐC GIA (API VIETQR.IO)
        // =========================================================
        string bankId = "TPBank";
        string accountNo = "84519828888";
        string accountName = "PHAM DUC HUNG";

        // Sử dụng template 'qr_only' hoặc 'compact2' của VietQR để hiển thị ảnh động mượt mà
        string cleanVietQrUrl = $"https://vietqr.io{bankId}-{accountNo}-compact2.png" +
                                $"?amount={decimal.Truncate(request.Amount).ToString("0")}" +
                                $"&addInfo={System.Net.WebUtility.UrlEncode(sepayCode)}" +
                                $"&accountName={System.Net.WebUtility.UrlEncode(accountName)}";

        var expiresAt = payment.CreatedAt.AddMinutes(_sepaySettings.PaymentTimeoutMinutes);

        Console.WriteLine($"[VIETQR] Đã tạo link QR động chuẩn: {cleanVietQrUrl}");

        return new SepayInitTopUpResponse(
            Succeeded: true,
            Message: "VietQR dynamic checkout generated successfully.",
            PaymentUrl: cleanVietQrUrl, // Trả link ảnh QR chuẩn về cho Front-end
            PaymentId: payment.Id,
            Amount: request.Amount,
            ExpiresAt: expiresAt,
            CheckoutUrl: cleanVietQrUrl,
            FormFields: checkout.Fields);
    }
}

