using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Locker.Backend.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class QrCodesController : ControllerBase
{
    private readonly IQrCodeService _qrCodeService;

    public QrCodesController(IQrCodeService qrCodeService)
    {
        _qrCodeService = qrCodeService;
    }

    [HttpPost("generate/{transactionId}")]
    public async Task<IActionResult> GenerateQrCode(string transactionId, [FromQuery] string type = "Unlock", CancellationToken cancellationToken = default)
    {
        try
        {
            var result = await _qrCodeService.GenerateQrCodeAsync(transactionId, type, cancellationToken);
            return Ok(result);
        }
        catch (Exception ex)
        {
            return BadRequest(new { Message = ex.Message });
        }
    }

    [HttpPost("validate")]
    public async Task<IActionResult> ValidateQrCode([FromBody] ValidationQrCodeRequest request, CancellationToken cancellationToken)
    {
        try
        {
            var isValid = await _qrCodeService.ValidateAndUseQrCodeAsync(request.Code, cancellationToken);
            if (!isValid) return BadRequest(new { Message = "Đã quá hạn hoặc QR Code không hợp lệ/đã được sử dụng" });
            
            return Ok(new { Message = "Xác thực QR thành công" });
        }
        catch (Exception ex)
        {
            return BadRequest(new { Message = ex.Message });
        }
    }
}