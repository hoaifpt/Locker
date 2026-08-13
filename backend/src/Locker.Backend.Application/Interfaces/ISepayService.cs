using Locker.Backend.Application.Models;

namespace Locker.Backend.Application.Interfaces;

public interface ISepayService
{
    SepayCheckoutData CreateTopUpCheckout(Guid paymentId, Guid userId, decimal amount, string? paymentMethod = null);
    bool IsValidIpnSecret(string? providedSecret);
}
