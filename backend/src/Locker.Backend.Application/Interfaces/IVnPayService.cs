using Locker.Backend.Application.Features.Wallet.Commands.VnPayInitTopUp;

namespace Locker.Backend.Application.Interfaces;

public interface IVnPayService
{
    string CreatePaymentUrl(VnPayInitTopUpResponse payment, string ipAddress);
    bool VerifyReturnUrl(IDictionary<string, string> parameters, out string? errorMessage);
}
