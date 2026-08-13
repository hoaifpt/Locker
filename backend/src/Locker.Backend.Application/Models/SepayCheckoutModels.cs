using System.Text.Json.Serialization;

namespace Locker.Backend.Application.Models;

public class SepayIpnRequest
{
    [JsonPropertyName("timestamp")]
    public long Timestamp { get; set; }

    [JsonPropertyName("notification_type")]
    public string NotificationType { get; set; } = string.Empty;

    [JsonPropertyName("order")]
    public SepayIpnOrder Order { get; set; } = new();

    [JsonPropertyName("transaction")]
    public SepayIpnTransaction Transaction { get; set; } = new();

    [JsonPropertyName("customer")]
    public SepayIpnCustomer? Customer { get; set; }
}

public class SepayIpnOrder
{
    [JsonPropertyName("id")]
    public string Id { get; set; } = string.Empty;

    [JsonPropertyName("order_id")]
    public string OrderId { get; set; } = string.Empty;

    [JsonPropertyName("order_status")]
    public string OrderStatus { get; set; } = string.Empty;

    [JsonPropertyName("order_currency")]
    public string OrderCurrency { get; set; } = string.Empty;

    [JsonPropertyName("order_amount")]
    public string OrderAmount { get; set; } = string.Empty;

    [JsonPropertyName("order_invoice_number")]
    public string OrderInvoiceNumber { get; set; } = string.Empty;

    [JsonPropertyName("order_description")]
    public string OrderDescription { get; set; } = string.Empty;
}

public class SepayIpnTransaction
{
    [JsonPropertyName("id")]
    public string Id { get; set; } = string.Empty;

    [JsonPropertyName("payment_method")]
    public string PaymentMethod { get; set; } = string.Empty;

    [JsonPropertyName("transaction_id")]
    public string TransactionId { get; set; } = string.Empty;

    [JsonPropertyName("transaction_type")]
    public string TransactionType { get; set; } = string.Empty;

    [JsonPropertyName("transaction_date")]
    public string TransactionDate { get; set; } = string.Empty;

    [JsonPropertyName("transaction_status")]
    public string TransactionStatus { get; set; } = string.Empty;

    [JsonPropertyName("transaction_amount")]
    public string TransactionAmount { get; set; } = string.Empty;

    [JsonPropertyName("transaction_currency")]
    public string TransactionCurrency { get; set; } = string.Empty;

    [JsonPropertyName("authentication_status")]
    public string AuthenticationStatus { get; set; } = string.Empty;
}

public class SepayIpnCustomer
{
    [JsonPropertyName("id")]
    public string Id { get; set; } = string.Empty;

    [JsonPropertyName("customer_id")]
    public string CustomerId { get; set; } = string.Empty;
}