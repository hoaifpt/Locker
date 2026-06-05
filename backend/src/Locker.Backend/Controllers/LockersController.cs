using System.Security.Claims;
using Locker.Backend.Application.Models;
using Locker.Backend.Application.Services;
using Locker.Backend.Domain.Enums;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Locker.Backend.Controllers;

[ApiController]
[Route("api/lockers")]
[Authorize]
public class LockersController : ControllerBase
{
    private readonly LockerService _lockerService;

    public LockersController(LockerService lockerService)
    {
        _lockerService = lockerService;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll(CancellationToken cancellationToken)
    {
        var items = await _lockerService.GetAllAsync(cancellationToken);
        return Ok(items);
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(Guid id, CancellationToken cancellationToken)
    {
        var item = await _lockerService.GetByIdAsync(id, cancellationToken);
        if (item == null)
        {
            return NotFound();
        }

        return Ok(item);
    }

    [HttpGet("available")]
    [AllowAnonymous]
    public async Task<IActionResult> GetAvailable(CancellationToken cancellationToken)
    {
        var items = await _lockerService.GetAvailableAsync(cancellationToken);
        return Ok(items);
    }

    [HttpGet("map")]
    [AllowAnonymous]
    public async Task<IActionResult> GetMap(CancellationToken cancellationToken)
    {
        var items = await _lockerService.GetMapAsync(cancellationToken);
        return Ok(items);
    }

    [HttpPost]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Create([FromBody] CreateLockerRequest request, CancellationToken cancellationToken)
    {
        var item = await _lockerService.CreateAsync(request, cancellationToken);
        return CreatedAtAction(nameof(GetById), new { id = item.Id }, item);
    }

    [HttpPut("{id}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Update(Guid id, [FromBody] UpdateLockerRequest request, CancellationToken cancellationToken)
    {
        var updated = await _lockerService.UpdateAsync(id, request, cancellationToken);
        if (!updated)
        {
            return NotFound();
        }

        return NoContent();
    }

    [HttpPut("{id}/soft-delete")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> SoftDelete(Guid id, CancellationToken cancellationToken)
    {
        var deleted = await _lockerService.SoftDeleteAsync(id, cancellationToken);
        if (!deleted)
        {
            return NotFound();
        }

        return NoContent();
    }

    [HttpPost("{id}/open")]
    public async Task<IActionResult> Open(Guid id, [FromBody] OpenLockerRequest request, CancellationToken cancellationToken)
    {
        var idStr = User.FindFirstValue(ClaimTypes.NameIdentifier) ?? User.FindFirstValue("sub");
        var userId = Guid.TryParse(idStr, out var parsedId) ? parsedId : (Guid?)null;
        var isPrivileged = User.IsInRole("Admin") || User.IsInRole("Shipper");

        var result = await _lockerService.OpenSlotAsync(
            id,
            request.SlotIndex,
            userId,
            isPrivileged,
            cancellationToken);

        return result switch
        {
            OpenLockerResult.Success => NoContent(),
            OpenLockerResult.Forbidden => Forbid(),
            _ => NotFound()
        };
    }

    [HttpPost("qr-scan")]
    [AllowAnonymous]
    public async Task<IActionResult> ValidateQrCode([FromBody] QrScanRequest request, CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(request.QrCode))
        {
            return BadRequest(new { message = "Mã QR không được để trống." });
        }

        var result = await _lockerService.ValidateQrCodeAsync(request.QrCode, cancellationToken);
        if (result == null)
        {
            return BadRequest(new { message = "Mã QR không hợp lệ hoặc không tìm thấy tủ." });
        }

        return Ok(result);
    }

    [HttpGet("scan-history")]
    [AllowAnonymous]
    public async Task<IActionResult> GetScanHistory(CancellationToken cancellationToken)
    {
        var history = await _lockerService.GetScanHistoryAsync(cancellationToken);
        return Ok(history);
    }

    [HttpPatch("{id}/settings")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> UpdateSettings(Guid id, [FromBody] UpdateLockerSettingsRequest request, CancellationToken cancellationToken)
    {
        var updated = await _lockerService.UpdateSettingsAsync(id, request, cancellationToken);
        if (!updated) return NotFound();
        var locker = await _lockerService.GetByIdAsync(id, cancellationToken);
        return Ok(locker);
    }

    /// <summary>Called by firmware/ESP32 to report slot status change.</summary>
    [HttpPost("{id}/slots/{slotIndex}/status")]
    [Authorize(Roles = "Admin,Shipper")]
    public async Task<IActionResult> UpdateSlotStatus(Guid id, int slotIndex, [FromBody] UpdateSlotStatusRequest request, CancellationToken cancellationToken)
    {
        var updated = await _lockerService.UpdateSlotStatusAsync(id, slotIndex, request.Status, cancellationToken);
        if (!updated) return NotFound();
        return NoContent();
    }

    /// <summary>Called by firmware/ESP32 to report slot open events.</summary>
    [HttpPost("{id}/slots/{slotIndex}/open-event")]
    [Authorize(Roles = "Admin,Shipper")]
    public async Task<IActionResult> RecordOpenEvent(Guid id, int slotIndex, [FromBody] LockerOpenEventRequest request, CancellationToken cancellationToken)
    {
        var updated = await _lockerService.RecordOpenEventAsync(id, slotIndex, request, cancellationToken);
        if (!updated) return NotFound();
        return NoContent();
    }
}
