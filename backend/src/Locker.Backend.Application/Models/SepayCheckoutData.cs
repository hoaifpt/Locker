namespace Locker.Backend.Application.Models;

public record SepayCheckoutData(
    string CheckoutUrl,
    IReadOnlyDictionary<string, string> Fields,
    string SignedString,
    string Signature);