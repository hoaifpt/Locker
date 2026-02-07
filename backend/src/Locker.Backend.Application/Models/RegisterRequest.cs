using System.ComponentModel.DataAnnotations;

namespace Locker.Backend.Application.Models;

public class RegisterRequest
{
    [Required]
    public string Username { get; set; } = string.Empty;

    [Required]
    [MinLength(6)]
    public string Password { get; set; } = string.Empty;
}
