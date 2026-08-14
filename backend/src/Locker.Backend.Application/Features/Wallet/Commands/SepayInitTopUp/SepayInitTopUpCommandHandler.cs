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
        // 💡 GIẢI PHÁP TỰ SINH LINK VIETQR ĐỘNG THEO MẪU CỦA BẠN
        // =========================================================
        string bankId = "TPBank"; 
        string accountNo = "84519828888"; 
        string accountName = "PHAM DUC HUNG"; 

        // Ghép thêm tham số số tiền (amount) và nội dung chuyển khoản (memo = sepayCode) vào link vietqr.app
        string cleanVietQrUrl = $"https://vietqr.app/img?bank={bankId}" +
                                $"&acc={accountNo}" +
                                $"&template=standee" +
                                $"&fullacc=true" +
                                $"&holder={System.Net.WebUtility.UrlEncode(accountName)}" +
                                $"&amount={decimal.Truncate(request.Amount).ToString("0")}" +
                                $"&memo={System.Net.WebUtility.UrlEncode(sepayCode)}";

        var expiresAt = payment.CreatedAt.AddMinutes(_sepaySettings.PaymentTimeoutMinutes);

        Console.WriteLine($"[VIETQR] Đã tạo link QR động chứa mã {sepayCode}: {cleanVietQrUrl}");

        return new SepayInitTopUpResponse(
            Succeeded: true,
            Message: "VietQR dynamic checkout generated successfully.",
            PaymentUrl: cleanVietQrUrl, // Trả link QR động về cho App hiển thị
            PaymentId: payment.Id,
            Amount: request.Amount,
            ExpiresAt: expiresAt,
            CheckoutUrl: cleanVietQrUrl,
            FormFields: checkout.Fields);
    }
}
