using Locker.Backend.Application.Models; // Đảm bảo import DTO mới

namespace Locker.Backend.Application.Interfaces;

public interface ISepayService
{
    string GenerateSepayPaymentUrl(Guid userId, decimal amount, string ipAddress);
    bool VerifySepayReturnUrl(IDictionary<string, string> parameters, out string errorMessage);

    // Đổi kiểu trả về từ VnPayProcessReturnResponse sang PaymentReturnResponse
    PaymentReturnResponse ProcessSepayReturn(IDictionary<string, string> parameters);
}
