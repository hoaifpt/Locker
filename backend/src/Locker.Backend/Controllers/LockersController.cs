using System;
using System.Security.Claims;
using System.Threading;
using System.Threading.Tasks;
using Locker.Backend.Application.Features.Lockers.Commands.CreateLocker;
using Locker.Backend.Application.Features.Lockers.Commands.DeleteLocker;
using Locker.Backend.Application.Features.Lockers.Commands.OpenLockerSlot;
using Locker.Backend.Application.Features.Lockers.Commands.RecordOpenEvent;
using Locker.Backend.Application.Features.Lockers.Commands.UpdateLocker;
using Locker.Backend.Application.Features.Lockers.Commands.UpdateLockerSettings;
using Locker.Backend.Application.Features.Lockers.Commands.UpdateSlotStatus;
using Locker.Backend.Application.Features.Lockers.Queries.GetAllLockers;
using Locker.Backend.Application.Features.Lockers.Queries.GetAvailableLockers;
using Locker.Backend.Application.Features.Lockers.Queries.GetLockerById;
using Locker.Backend.Application.Features.Lockers.Queries.GetLockerMap;
using Locker.Backend.Application.Features.Lockers.Queries.GetScanHistory;
using Locker.Backend.Application.Features.Lockers.Queries.ValidateQrCode;
using Locker.Backend.Application.Models;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Locker.Backend.Controllers;

[ApiController]
[Route("api/lockers")]
[Authorize]
public class LockersController : ControllerBase
{
    private readonly ISender _sender;

    public LockersController(ISender sender)
    {
        _sender = sender;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll(CancellationToken cancellationToken)
    {
        var items = await _sender.Send(new GetAllLockersQuery(), cancellationToken);
        return Ok(items);
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(Guid id, CancellationToken cancellationToken)
    {
        var item = await _sender.Send(new GetLockerByIdQuery(id), cancellationToken);
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
        var items = await _sender.Send(new GetAvailableLockersQuery(), cancellationToken);
        return Ok(items);
    }

    [HttpGet("map")]
    [AllowAnonymous]
    public async Task<IActionResult> GetMap(CancellationToken cancellationToken)
    {
        var items = await _sender.Send(new GetLockerMapQuery(), cancellationToken);
        return Ok(items);
    }

    [HttpPost]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Create([FromBody] CreateLockerRequest request, CancellationToken cancellationToken)
    {
        var command = new CreateLockerCommand(request.Name, request.Location, request.Latitude, request.Longitude, request.Slots);
        var item = await _sender.Send(command, cancellationToken);
        return CreatedAtAction(nameof(GetById), new { id = item.Id }, item);
    }

    [HttpPut("{id}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Update(Guid id, [FromBody] UpdateLockerRequest request, CancellationToken cancellationToken)
    {
        var command = new UpdateLockerCommand(id, request.Name, request.Location, request.Latitude, request.Longitude);
        var updated = await _sender.Send(command, cancellationToken);
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
        var deleted = await _sender.Send(new DeleteLockerCommand(id), cancellationToken);
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

        var result = await _sender.Send(new OpenLockerSlotCommand(
            id,
            request.SlotIndex,
            userId,
            isPrivileged), cancellationToken);

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

        var result = await _sender.Send(new ValidateQrCodeQuery(request.QrCode), cancellationToken);
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
        var history = await _sender.Send(new GetScanHistoryQuery(), cancellationToken);
        return Ok(history);
    }

    [HttpPatch("{id}/settings")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> UpdateSettings(Guid id, [FromBody] UpdateLockerSettingsRequest request, CancellationToken cancellationToken)
    {
        var command = new UpdateLockerSettingsCommand(id, request.IsAutoLockEnabled, request.IsIntrusionAlertEnabled);
        var updated = await _sender.Send(command, cancellationToken);
        if (!updated) return NotFound();
        var locker = await _sender.Send(new GetLockerByIdQuery(id), cancellationToken);
        return Ok(locker);
    }

    /// <summary>Called by firmware/ESP32 to report slot status change.</summary>
    [HttpPost("{id}/slots/{slotIndex}/status")]
    [Authorize(Roles = "Admin,Shipper")]
    public async Task<IActionResult> UpdateSlotStatus(Guid id, int slotIndex, [FromBody] UpdateSlotStatusRequest request, CancellationToken cancellationToken)
    {
        var updated = await _sender.Send(new UpdateSlotStatusCommand(id, slotIndex, request.Status), cancellationToken);
        if (!updated) return NotFound();
        return NoContent();
    }

    /// <summary>Called by firmware/ESP32 to report slot open events.</summary>
    [HttpPost("{id}/slots/{slotIndex}/open-event")]
    [Authorize(Roles = "Admin,Shipper")]
    public async Task<IActionResult> RecordOpenEvent(Guid id, int slotIndex, [FromBody] LockerOpenEventRequest request, CancellationToken cancellationToken)
    {
        var updated = await _sender.Send(new RecordOpenEventCommand(id, slotIndex, request.SensorState), cancellationToken);
        if (!updated) return NotFound();
        return NoContent();
    }
}
