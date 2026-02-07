using System.ComponentModel.DataAnnotations;

namespace Locker.Backend.Application.Models;

public class UpdateLockerRequest
{
    [Required]
    public string Name { get; set; } = string.Empty;

    public string Location { get; set; } = string.Empty;
}
