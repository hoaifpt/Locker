using System.ComponentModel.DataAnnotations;

namespace Locker.Backend.Application.Models;

public class RegisterRequest
{
    [Required]
    public string Username { get; set; } = string.Empty;

    [Required]
    [EmailAddress]
    public string Email { get; set; } = string.Empty;

    public string? FullName { get; set; }

<<<<<<< HEAD
    [Phone]
    public string? PhoneNumber { get; set; }

=======
>>>>>>> cd41969f38b41cd3f098ee3ee44d55472bf88075
    [Required]
    [MinLength(6)]
    public string Password { get; set; } = string.Empty;
}
