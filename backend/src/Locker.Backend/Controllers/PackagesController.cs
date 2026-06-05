using Locker.Backend.Application.Features.Packages.Commands.CreatePackage;
using Locker.Backend.Application.Features.Packages.Commands.DeletePackage;
using Locker.Backend.Application.Features.Packages.Commands.UpdatePackage;
using Locker.Backend.Application.Features.Packages.Queries.GetAllPackages;
using Locker.Backend.Application.Features.Packages.Queries.GetPackageById;
using Locker.Backend.Application.Models;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Locker.Backend.Controllers;

[ApiController]
[Route("api/packages")]
public class PackagesController : ControllerBase
{
    private readonly ISender _sender;

    public PackagesController(ISender sender)
    {
        _sender = sender;
    }

    [HttpGet]
    [AllowAnonymous]
    public async Task<IActionResult> GetAll(CancellationToken cancellationToken)
    {
        var items = await _sender.Send(new GetAllPackagesQuery(), cancellationToken);
        return Ok(items);
    }

    [HttpGet("{id}")]
    [AllowAnonymous]
    public async Task<IActionResult> GetById(Guid id, CancellationToken cancellationToken)
    {
        var item = await _sender.Send(new GetPackageByIdQuery(id), cancellationToken);
        if (item == null) return NotFound();
        return Ok(item);
    }

    [HttpPost]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Create([FromBody] CreatePackageRequest request, CancellationToken cancellationToken)
    {
        var command = new CreatePackageCommand(request.Name, request.Size, request.Description, request.PricePerHour);
        var item = await _sender.Send(command, cancellationToken);
        return CreatedAtAction(nameof(GetById), new { id = item.Id }, item);
    }

    [HttpPut("{id}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Update(Guid id, [FromBody] UpdatePackageRequest request, CancellationToken cancellationToken)
    {
        var command = new UpdatePackageCommand(id, request.Name, request.Size, request.Description, request.PricePerHour, request.IsActive);
        var success = await _sender.Send(command, cancellationToken);
        if (!success) return NotFound();
        return NoContent();
    }

    [HttpPut("{id}/soft-delete")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> SoftDelete(Guid id, CancellationToken cancellationToken)
    {
        var success = await _sender.Send(new DeletePackageCommand(id), cancellationToken);
        if (!success) return NotFound();
        return NoContent();
    }
}
