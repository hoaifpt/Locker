using System;
using System.Collections.Generic;
using System.Security.Claims;
using System.Threading;
using System.Threading.Tasks;

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
    CancellationToken cancellationToken)
    {
        Console.WriteLine("========== SEPAY IPN REQUEST ==========");

        // =========================================================
        // 1. ĐỌC RAW BODY
        // =========================================================

        Request.EnableBuffering();

        // Quan trọng:
        // Nếu middleware trước đó đã đọc Body thì đưa Position về 0
        if (Request.Body.CanSeek)
        {
            Request.Body.Position = 0;
        }

        using var reader = new StreamReader(
            Request.Body,
            leaveOpen: true
        );

        var rawBody = await reader.ReadToEndAsync(cancellationToken);

        if (Request.Body.CanSeek)
        {
            Request.Body.Position = 0;
        }

        Console.WriteLine("========== RAW SEPAY IPN ==========");
        Console.WriteLine(rawBody);
        Console.WriteLine("====================================");

        if (string.IsNullOrWhiteSpace(rawBody))
        {
            Console.WriteLine("❌ SEPAY BODY EMPTY");

            return BadRequest(new
            {
                success = false,
                message = "SePay request body is empty"
            });
        }

        // =========================================================
        // 2. AUTHENTICATION
        // =========================================================

        var authorization =
            Request.Headers["Authorization"]
                .FirstOrDefault();

        var providedSecret =
            Request.Headers["X-Secret-Key"]
                .FirstOrDefault();

        if (
            string.IsNullOrWhiteSpace(providedSecret) &&
            !string.IsNullOrWhiteSpace(authorization)
        )
        {
            var parts = authorization.Split(' ', 2);

            if (
                parts.Length == 2 &&
                parts[0].Equals(
                    "Apikey",
                    StringComparison.OrdinalIgnoreCase
                )
            )
            {
                providedSecret = parts[1].Trim();
            }
        }

        Console.WriteLine("========== SEPAY AUTH DEBUG ==========");
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
        Console.WriteLine("======================================");

        if (!_sepayService.IsValidIpnSecret(providedSecret))
        {
            Console.WriteLine("❌ SEPAY SECRET INVALID");

            return Unauthorized(new
            {
                success = false,
                message = "Invalid SePay IPN secret"
            });
        }

        Console.WriteLine("✅ SEPAY SECRET VALID");

        // =========================================================
        // 3. PARSE SEPAY BANK NOTIFY
        // =========================================================

        static string GetField(
            string body,
            string fieldName,
            string nextFieldPattern)
        {
            var pattern =
                $@"(?:^|\s){System.Text.RegularExpressions.Regex.Escape(fieldName)}:\s*(.*?)(?=\s+{nextFieldPattern}:|$)";

            var match =
                System.Text.RegularExpressions.Regex.Match(
                    body,
                    pattern,
                    System.Text.RegularExpressions.RegexOptions.IgnoreCase
                );

            return match.Success
                ? match.Groups[1].Value.Trim()
                : string.Empty;
        }

        var gateway = GetField(
            rawBody,
            "gateway",
            "transactionDate"
        );

        var transactionDate = GetField(
            rawBody,
            "transactionDate",
            "accountNumber"
        );

        var accountNumber = GetField(
            rawBody,
            "accountNumber",
            "subAccount"
        );

        var subAccount = GetField(
            rawBody,
            "subAccount",
            "code"
        );

        var code = GetField(
            rawBody,
            "code",
            "content"
        );

        var content = GetField(
            rawBody,
            "content",
            "transferType"
        );

        var transferType = GetField(
            rawBody,
            "transferType",
            "description"
        );

        var description = GetField(
            rawBody,
            "description",
            "transferAmount"
        );

        var transferAmountText = GetField(
            rawBody,
            "transferAmount",
            "referenceCode"
        );

        var referenceCode = GetField(
            rawBody,
            "referenceCode",
            "accumulated"
        );

        var accumulated = GetField(
            rawBody,
            "accumulated",
            "id"
        );

        var transactionId = GetField(
            rawBody,
            "id",
            "$"
        );

        Console.WriteLine("========== PARSED SEPAY ==========");
        Console.WriteLine($"Gateway: {gateway}");
        Console.WriteLine($"TransactionDate: {transactionDate}");
        Console.WriteLine($"AccountNumber: {accountNumber}");
        Console.WriteLine($"Code: {code}");
        Console.WriteLine($"Content: {content}");
        Console.WriteLine($"TransferType: {transferType}");
        Console.WriteLine($"Description: {description}");
        Console.WriteLine($"TransferAmount: {transferAmountText}");
        Console.WriteLine($"ReferenceCode: {referenceCode}");
        Console.WriteLine($"Accumulated: {accumulated}");
        Console.WriteLine($"TransactionId: {transactionId}");
        Console.WriteLine("==================================");

        // =========================================================
        // 4. CHỈ XỬ LÝ TIỀN VÀO
        // =========================================================

        if (
            !transferType.Equals(
                "in",
                StringComparison.OrdinalIgnoreCase
            )
        )
        {
            Console.WriteLine(
                $"⚠️ IGNORE: transaction is not money-in: {transferType}"
            );

            return Ok(new
            {
                success = true,
                message = "Ignored transaction type"
            });
        }

        // =========================================================
        // 5. PARSE AMOUNT
        // =========================================================

        if (!decimal.TryParse(
                transferAmountText,
                System.Globalization.NumberStyles.Any,
                System.Globalization.CultureInfo.InvariantCulture,
                out var transferAmount))
        {
            Console.WriteLine(
                $"❌ INVALID TRANSFER AMOUNT: {transferAmountText}"
            );

            return BadRequest(new
            {
                success = false,
                message = "Invalid transfer amount"
            });
        }

        if (transferAmount <= 0)
        {
            return BadRequest(new
            {
                success = false,
                message = "Transfer amount must be greater than zero"
            });
        }

        // =========================================================
        // 6. TÌM MÃ TOPUP
        // =========================================================

        Console.WriteLine(
            $"Searching TOPUP invoice from content: {content}"
        );

        var invoiceNumber =
            SepayService.ExtractInvoiceNumberFromContent(content);

        Console.WriteLine(
            $"InvoiceNumber: {invoiceNumber}"
        );

        if (string.IsNullOrWhiteSpace(invoiceNumber))
        {
            Console.WriteLine(
                "❌ Cannot find TOPUP invoice number"
            );

            return BadRequest(new
            {
                success = false,
                message =
                    "Cannot find TOPUP invoice number in transfer content"
            });
        }

        // =========================================================
        // 7. TẠO REQUEST CHO HANDLER HIỆN TẠI
        // =========================================================

        var ipnRequest = new SepayIpnRequest
        {
            NotificationType = "ORDER_PAID",

            Order = new SepayIpnOrder
            {
                OrderInvoiceNumber = invoiceNumber,
                OrderStatus = "CAPTURED",
                OrderAmount = transferAmount.ToString(
                    System.Globalization.CultureInfo.InvariantCulture
                ),
                OrderDescription = description
            },

            Transaction = new SepayIpnTransaction
            {
                TransactionId = transactionId,
                TransactionStatus = "APPROVED",
                TransactionAmount = transferAmount.ToString(
                    System.Globalization.CultureInfo.InvariantCulture
                ),
                TransactionDate = transactionDate,
                PaymentMethod = "BANK_TRANSFER",
                TransactionType = transferType
            },

            Customer = null
        };

        // =========================================================
        // 8. GỌI HANDLER
        // =========================================================

        Console.WriteLine("========== SEPAY PROCESS ==========");

        var result = await _sender.Send(
            new SepayProcessIpnCommand(ipnRequest),
            cancellationToken
        );

        if (!result.Success)
        {
            Console.WriteLine(
                $"❌ SEPAY PROCESS FAILED: {result.Message}"
            );

            return BadRequest(new
            {
                success = false,
                message = result.Message,
                paymentId = result.PaymentId
            });
        }

        Console.WriteLine(
            $"✅ SEPAY PROCESS SUCCESS: {result.Message}"
        );

        return Ok(new
        {
            success = true,
            message = result.Message,
            paymentId = result.PaymentId
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
