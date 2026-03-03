using System.ComponentModel.DataAnnotations;

namespace Locker.Backend.Application.Models;

public class AuthRequest
{
    [Required]
    public string Identifier { get; set; } = string.Empty;  // Email or Phone Number

    [Required]
    [MinLength(6)]
    public string Password { get; set; } = string.Empty;
}
