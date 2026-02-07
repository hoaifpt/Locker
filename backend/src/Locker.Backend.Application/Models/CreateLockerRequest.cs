using System.ComponentModel.DataAnnotations;

namespace Locker.Backend.Application.Models;

public class CreateLockerRequest
{
    [Required]
    public string Name { get; set; } = string.Empty;

    public string Location { get; set; } = string.Empty;

    [Range(1, 500)]
    public int Slots { get; set; } = 12;
}
