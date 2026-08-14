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
        [FromBody] SepayIpnRequest request,
        CancellationToken cancellationToken)
    {

        var authHeader = Request.Headers["Authorization"].FirstOrDefault();

        // 2. Định dạng SePay gửi là: "Apikey <API_KEY_CUA_BAN>"
        // Chúng ta cần trích xuất phần API_KEY_CUA_BAN
        var providedKey = authHeader?.Replace("Apikey ", "").Trim();

        if (!_sepayService.IsValidIpnSecret(providedKey))
        {
            return Unauthorized("Invalid API Key");
        }

        Console.WriteLine("========== SEPAY IPN START ==========");

        Console.WriteLine($"NotificationType: {request.NotificationType}");
        Console.WriteLine($"Timestamp: {request.Timestamp}");

        Console.WriteLine("----- ORDER -----");
        Console.WriteLine($"OrderId: {request.Order?.OrderId}");
        Console.WriteLine($"OrderStatus: {request.Order?.OrderStatus}");
        Console.WriteLine($"OrderAmount: {request.Order?.OrderAmount}");
        Console.WriteLine($"InvoiceNumber: {request.Order?.OrderInvoiceNumber}");
        Console.WriteLine($"OrderDescription: {request.Order?.OrderDescription}");

        Console.WriteLine("----- TRANSACTION -----");
        Console.WriteLine($"TransactionId: {request.Transaction?.TransactionId}");
        Console.WriteLine($"TransactionStatus: {request.Transaction?.TransactionStatus}");
        Console.WriteLine($"TransactionAmount: {request.Transaction?.TransactionAmount}");
        Console.WriteLine($"TransactionDate: {request.Transaction?.TransactionDate}");
        Console.WriteLine($"PaymentMethod: {request.Transaction?.PaymentMethod}");

        Console.WriteLine("====================================");

        var providedSecret = Request.Headers["X-Secret-Key"].FirstOrDefault();
        if (!_sepayService.IsValidIpnSecret(providedSecret))
        {
            return Unauthorized(new
            {
                success = false,
                message = "Invalid SePay IPN secret"
            });
        }

        var result = await _sender.Send(
            new SepayProcessIpnCommand(request),
            cancellationToken);

        if (!result.Success)
        {
            return BadRequest(new
            {
                success = false,
                message = result.Message,
                paymentId = result.PaymentId
            });
        }

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
