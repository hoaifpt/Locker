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
    public async Task<IActionResult> GetById(string id, CancellationToken cancellationToken)
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

    [HttpPost]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Create([FromBody] CreateLockerRequest request, CancellationToken cancellationToken)
    {
        var item = await _lockerService.CreateAsync(request, cancellationToken);
        return CreatedAtAction(nameof(GetById), new { id = item.Id }, item);
    }

    [HttpPut("{id}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Update(string id, [FromBody] UpdateLockerRequest request, CancellationToken cancellationToken)
    {
        var updated = await _lockerService.UpdateAsync(id, request, cancellationToken);
        if (!updated)
        {
            return NotFound();
        }

        return NoContent();
    }

    [HttpDelete("{id}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Delete(string id, CancellationToken cancellationToken)
    {
        var deleted = await _lockerService.DeleteAsync(id, cancellationToken);
        if (!deleted)
        {
            return NotFound();
        }

        return NoContent();
    }

    /// <summary>Called by firmware/ESP32 to report slot status change.</summary>
    [HttpPost("{id}/slots/{slotIndex}/status")]
    [Authorize(Roles = "Admin,Shipper")]
    public async Task<IActionResult> UpdateSlotStatus(string id, int slotIndex, [FromBody] UpdateSlotStatusRequest request, CancellationToken cancellationToken)
    {
        var updated = await _lockerService.UpdateSlotStatusAsync(id, slotIndex, request.Status, cancellationToken);
        if (!updated) return NotFound();
        return NoContent();
    }
}
