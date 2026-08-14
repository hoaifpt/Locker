using System;
using System.Collections.Generic;
using System.Security.Claims;
using System.Threading;
using System.Threading.Tasks;
using System.Text.Json.Serialization;
using Locker.Backend.Infrastructure.Services;
using Locker.Backend.Application.Features.Wallet.Commands.TopUp;
using Locker.Backend.Application.Features.Wallet.Commands.Transfer;
using Locker.Backend.Application.Features.Wallet.Commands.VnPayInitTopUp;
using Locker.Backend.Application.Features.Wallet.Commands.SepayProcessReturn;
using Locker.Backend.Application.Features.Wallet.Commands.SepayProcessIpn;
using Locker.Backend.Application.Features.Wallet.Commands.SepayInitTopUp;
using Locker.Backend.Application.Features.Wallet.Commands.VnPayProcessReturn;
using Locker.Backend.Application.Features.Wallet.Queries.GetBalance;
using Locker.Backend.Application.Features.Wallet.Queries.GetOverview;
using Locker.Backend.Application.Features.Wallet.Queries.GetTransactions;
using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Models;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using System.Text.Json;
using Microsoft.AspNetCore.Mvc;

namespace Locker.Backend.Controllers;

[ApiController]
[Route("api/wallet")]
[Authorize]
public class WalletController : ControllerBase
{
    private readonly ISender _sender;
    private readonly ISepayService _sepayService;

    public WalletController(ISender sender, ISepayService sepayService)
    {
        _sender = sender;
        _sepayService = sepayService;
    }

    [HttpGet("overview")]
    public async Task<IActionResult> GetOverview(CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        if (userId == Guid.Empty) return Unauthorized();

        var overview = await _sender.Send(new GetOverviewQuery(userId), cancellationToken);
        return Ok(overview);
    }

    [HttpGet("transactions")]
    public async Task<IActionResult> GetTransactions(CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        if (userId == Guid.Empty) return Unauthorized();

        var transactions = await _sender.Send(new GetTransactionsQuery(userId), cancellationToken);
        return Ok(transactions);
    }

    [HttpGet("balance")]
    public async Task<IActionResult> GetBalance(CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        if (userId == Guid.Empty) return Unauthorized();

        var balance = await _sender.Send(new GetBalanceQuery(userId), cancellationToken);
        return Ok(new { Balance = balance });
    }

    [HttpPost("top-up")]
    public async Task<IActionResult> TopUp([FromBody] TopUpRequest request, CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        if (userId == Guid.Empty) return Unauthorized();

        var success = await _sender.Send(new TopUpCommand(userId, request.Amount, request.ReferenceId), cancellationToken);
        if (!success) return BadRequest(new { message = "Top up failed" });
        return Ok(new { message = "Top up successful" });
    }

    [HttpPost("transfer")]
    public async Task<IActionResult> Transfer([FromBody] TransferRequest request, CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        if (userId == Guid.Empty) return Unauthorized();

        var success = await _sender.Send(new TransferCommand(userId, request.ReceiverId, request.Amount, request.Note), cancellationToken);
        if (!success) return BadRequest(new { message = "Transfer failed or insufficient funds" });
        return Ok(new { message = "Transfer successful" });
    }

    [HttpPost("top-up/vnpay/init")]
    public async Task<IActionResult> InitVnPayTopUp([FromBody] VnPayTopUpInitRequest request, CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        if (userId == Guid.Empty) return Unauthorized();

        var ipAddress = GetClientIpAddress();
        var result = await _sender.Send(new VnPayInitTopUpCommand(userId, request.Amount, ipAddress), cancellationToken);
        return Ok(result);
    }

    [HttpGet("top-up/vnpay/return")]
    [AllowAnonymous]
    public async Task<IActionResult> VnPayReturn(CancellationToken cancellationToken)
    {
        var parameters = Request.Query.ToDictionary(
            kvp => kvp.Key,
            kvp => kvp.Value.ToString()
        );

        var result = await _sender.Send(new VnPayProcessReturnCommand(parameters), cancellationToken);

        if (!result.Success)
        {
            return BadRequest(result);
        }

        return Ok(result);
    }

    [HttpPost("top-up/sepay/init")]
    public async Task<IActionResult> InitSepayTopUp([FromBody] SepayTopUpInitRequest request, CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        if (userId == Guid.Empty) return Unauthorized();

        var ipAddress = GetClientIpAddress();
        var result = await _sender.Send(new SepayInitTopUpCommand(userId, request.Amount, ipAddress), cancellationToken);
        return Ok(result);
    }

    [HttpGet("top-up/sepay/return")]
    [AllowAnonymous]
    public async Task<IActionResult> SepayReturn(CancellationToken cancellationToken)
    {
        var parameters = Request.Query.ToDictionary(
            kvp => kvp.Key,
            kvp => kvp.Value.ToString()
        );

        var result = await _sender.Send(new SepayProcessReturnCommand(parameters), cancellationToken);

        if (!result.Success)
        {
            return BadRequest(result);
        }

        // Trả về kết quả thành công để client (WebView trong mobile app) có thể bắt và xử lý
        return Ok(result);
    }

    [HttpPost("top-up/sepay/ipn")]
    [AllowAnonymous]
    public async Task<IActionResult> SepayIpn(
     [FromBody] SepayBankWebhookRequest request,
     CancellationToken cancellationToken)
    {
        Console.WriteLine("========== SEPAY BANK WEBHOOK ==========");

        // =========================================================
        // 1. AUTHORIZATION
        // =========================================================

        var authorization = Request.Headers["Authorization"]
            .FirstOrDefault();

        var providedSecret = Request.Headers["X-Secret-Key"]
            .FirstOrDefault();

        // SePay Bank Webhook dùng:
        // Authorization: Apikey YOUR_API_KEY
        if (string.IsNullOrWhiteSpace(providedSecret) &&
            !string.IsNullOrWhiteSpace(authorization))
        {
            var parts = authorization.Split(' ', 2);

            if (parts.Length == 2 &&
                parts[0].Equals(
                    "Apikey",
                    StringComparison.OrdinalIgnoreCase))
            {
                providedSecret = parts[1].Trim();
            }
        }

        Console.WriteLine("========== SEPAY AUTH ==========");
        Console.WriteLine(
            $"Authorization exists: {!string.IsNullOrWhiteSpace(authorization)}"
        );
        Console.WriteLine(
            $"Authorization length: {authorization?.Length ?? 0}"
        );
        Console.WriteLine(
            $"Provided secret exists: {!string.IsNullOrWhiteSpace(providedSecret)}"
        );
        Console.WriteLine(
            $"Provided secret length: {providedSecret?.Length ?? 0}"
        );
        Console.WriteLine("================================");

        if (!_sepayService.IsValidIpnSecret(providedSecret))
        {
            Console.WriteLine("❌ SEPAY SECRET INVALID");

            return Unauthorized(new
            {
                success = false,
                message = "Invalid SePay API key"
            });
        }

        Console.WriteLine("✅ SEPAY SECRET VALID");

        // =========================================================
        // 2. VALIDATE BODY
        // =========================================================

        if (request == null)
        {
            Console.WriteLine("❌ SEPAY REQUEST BODY IS NULL");

            return BadRequest(new
            {
                success = false,
                message = "SePay request body is empty"
            });
        }



        Console.WriteLine("========== SEPAY DATA ==========");
        Console.WriteLine($"Id: {request.Id}");
        Console.WriteLine($"Gateway: {request.Gateway}");
        Console.WriteLine($"TransactionDate: {request.TransactionDate}");
        Console.WriteLine($"AccountNumber: {request.AccountNumber}");
        Console.WriteLine($"SubAccount: {request.SubAccount}");
        Console.WriteLine($"Code: {request.Code}");
        Console.WriteLine($"Content: {request.Content}");
        Console.WriteLine($"TransferType: {request.TransferType}");
        Console.WriteLine($"Description: {request.Description}");
        Console.WriteLine($"TransferAmount: {request.TransferAmount}");
        Console.WriteLine($"Accumulated: {request.Accumulated}");
        Console.WriteLine($"ReferenceCode: {request.ReferenceCode}");
        Console.WriteLine("================================");

        if (!string.IsNullOrWhiteSpace(request.Content))
        {
            // Sử dụng Regex lọc lấy chuỗi PAY... nằm trong chuỗi nội dung dài
            var match = System.Text.RegularExpressions.Regex.Match(request.Content, @"(PAY[A-Z0-9]+)");
            if (match.Success)
            {
                // Đè mã sạch (PAY28336A7F2598C6077) ngược lại vào biến Content
                request.Content = match.Value;
                Console.WriteLine($"⚙️ Đã bóc tách mã đơn hàng chuẩn thành công: {request.Content}");
            }
        }

        // =========================================================
        // 3. CHỈ XỬ LÝ TIỀN VÀO
        // =========================================================

        if (!string.Equals(
                request.TransferType,
                "in",
                StringComparison.OrdinalIgnoreCase))
        {
            Console.WriteLine(
                $"⚠️ IGNORE: transaction type = {request.TransferType}"
            );

            return Ok(new
            {
                success = true,
                message = "Ignored transaction type"
            });
        }

        // =========================================================
        // 4. VALIDATE AMOUNT
        // =========================================================

        if (request.TransferAmount <= 0)
        {
            Console.WriteLine(
                $"❌ INVALID AMOUNT: {request.TransferAmount}"
            );

            return BadRequest(new
            {
                success = false,
                message = "Transfer amount must be greater than zero"
            });
        }

        // =========================================================
        // 5. LẤY SEPAY PAYMENT CODE VÀ BÓC TÁCH MÃ ĐƠN HÀNG SẠCH
        // =========================================================

        Console.WriteLine($"Searching SePay payment code from webhook...");

        var sepayCode = request.Code?.Trim();
        Console.WriteLine($"SePayCode: {sepayCode}");

        if (string.IsNullOrWhiteSpace(sepayCode))
        {
            return BadRequest(new
            {
                success = false,
                message = "Cannot find SePay payment code"
            });
        }

        // Tạo biến riêng để chứa mã hóa đơn sạch
        string cleanInvoiceNumber = request.Content ?? "";

        if (!string.IsNullOrWhiteSpace(request.Content))
        {
            // Sử dụng Regex lọc lấy duy nhất chuỗi PAY... nằm trong chuỗi nội dung dài
            var match = System.Text.RegularExpressions.Regex.Match(request.Content, @"(PAY[A-Z0-9]+)");
            if (match.Success)
            {
                cleanInvoiceNumber = match.Value; // Kết quả thu được: PAY28336A7F2598C6077
                Console.WriteLine($"⚙️ Đã bóc tách mã đơn hàng chuẩn thành công: {cleanInvoiceNumber}");
            }
        }

        // =========================================================
        // 6. TẠO REQUEST CHO MEDIATR (Sử dụng mã hóa đơn sạch)
        // =========================================================

        var ipnRequest = new SepayIpnRequest
        {
            NotificationType = "ORDER_PAID",

            Order = new SepayIpnOrder
            {
                // GÁN MÃ SẠCH ĐÃ BÓC TÁCH VÀO ĐÂY
                OrderInvoiceNumber = cleanInvoiceNumber,
                OrderStatus = "CAPTURED",

                OrderAmount = request.TransferAmount
                    .ToString(System.Globalization.CultureInfo.InvariantCulture),

                OrderDescription = request.Description
            },

            Transaction = new SepayIpnTransaction
            {
                TransactionId = request.Id.ToString(),
                TransactionStatus = "APPROVED",
                TransactionAmount = request.TransferAmount.ToString(System.Globalization.CultureInfo.InvariantCulture),
                TransactionDate = request.TransactionDate ?? "",
                PaymentMethod = "BANK_TRANSFER",
                TransactionType = request.TransferType
            },
            Customer = null
        };

        // =========================================================
        // 7. PROCESS TOP-UP
        // =========================================================

        Console.WriteLine("========== SEPAY PROCESS ==========");

        var result = await _sender.Send(
            new SepayProcessIpnCommand(ipnRequest),
            cancellationToken
        );

        if (!result.Success)
        {
            Console.WriteLine($"❌ SEPAY PROCESS FAILED: {result.Message}");

            return BadRequest(new
            {
                success = false,
                message = result.Message,
                paymentId = result.PaymentId
            });
        }

        Console.WriteLine($"✅ SEPAY PROCESS SUCCESS: {result.Message}");

        // SePay yêu cầu HTTP 200 + JSON success=true
        return Ok(new
        {
            success = true
        });
    }

    [HttpPost("top-up/sepay/bank-notify")]
    [AllowAnonymous]
    public async Task<IActionResult> SepayBankNotify([FromBody] SepayBankNotifyRequest request, CancellationToken cancellationToken)
    {
        // Dùng cho trường hợp khách chuyển khoản trực tiếp qua App ngân hàng
        var authHeader = Request.Headers["Authorization"].FirstOrDefault();

        // Tách lấy phần API Key
        var providedKey = authHeader?.Replace("Apikey ", "").Trim();

        // Xác thực
        if (!_sepayService.IsValidIpnSecret(providedKey))
        {
            return Unauthorized("Sai API Key");
        }

        // 1. Trích xuất mã TOPUP từ content
        var invoiceNumber = SepayService.ExtractInvoiceNumberFromContent(request.Content);

        // 2. Nếu tìm thấy mã, giả lập một request IPN để tái sử dụng logic xử lý thanh toán đã có
        if (SepayService.TryParseTopUpPaymentId(invoiceNumber, out var paymentId))
        {
            var result = await _sender.Send(new SepayProcessIpnCommand(new SepayIpnRequest
            {
                NotificationType = "ORDER_PAID",
                Order = new SepayIpnOrder
                {
                    OrderInvoiceNumber = invoiceNumber,
                    OrderStatus = "CAPTURED",
                    OrderAmount = request.TransferAmount.ToString()
                },
                Transaction = new SepayIpnTransaction
                {
                    TransactionStatus = "APPROVED",
                    TransactionId = request.Id
                }
            }), cancellationToken);

            return result.Success ? Ok(result) : BadRequest(result);
        }
        return BadRequest("Invalid content");
    }

    private string GetClientIpAddress()
    {
        var forwardedFor = Request.Headers["X-Forwarded-For"].FirstOrDefault();
        if (!string.IsNullOrEmpty(forwardedFor))
        {
            return forwardedFor.Split(',')[0].Trim();
        }

        return HttpContext.Connection.RemoteIpAddress?.ToString() ?? "127.0.0.1";
    }

    private Guid GetUserId()
    {
        var idStr = User.FindFirstValue(ClaimTypes.NameIdentifier) ?? User.FindFirstValue("sub");
        return Guid.TryParse(idStr, out var id) ? id : Guid.Empty;
    }
}

public class TopUpRequest
{
    public decimal Amount { get; set; }
    public string? ReferenceId { get; set; }
}

public class TransferRequest
{
    public Guid ReceiverId { get; set; }
    public decimal Amount { get; set; }
    public string? Note { get; set; }
}

public class VnPayTopUpInitRequest
{
    public decimal Amount { get; set; }
}

public class SepayTopUpInitRequest
{
    public decimal Amount { get; set; }
}

public class SepayBankNotifyRequest
{
    public string Content { get; set; }
    public decimal TransferAmount { get; set; }
    public string Code { get; set; }
    public string Id { get; set; }
}

public class SepayBankWebhookRequest
{
    [JsonPropertyName("id")]
    public long Id { get; set; }

    [JsonPropertyName("gateway")]
    public string? Gateway { get; set; }

    [JsonPropertyName("transactionDate")]
    public string? TransactionDate { get; set; }

    [JsonPropertyName("accountNumber")]
    public string? AccountNumber { get; set; }

    [JsonPropertyName("subAccount")]
    public string? SubAccount { get; set; }

    [JsonPropertyName("code")]
    public string? Code { get; set; }

    [JsonPropertyName("content")]
    public string? Content { get; set; }

    [JsonPropertyName("transferType")]
    public string? TransferType { get; set; }

    [JsonPropertyName("description")]
    public string? Description { get; set; }

    [JsonPropertyName("transferAmount")]
    public decimal TransferAmount { get; set; }

    [JsonPropertyName("accumulated")]
    public decimal Accumulated { get; set; }

    [JsonPropertyName("referenceCode")]
    public string? ReferenceCode { get; set; }
}
