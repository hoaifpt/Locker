using System.ComponentModel.DataAnnotations;

namespace Locker.Backend.Application.Models;

public class ResendVerificationRequest
{
    [Required]
    [EmailAddress]
    public string Email { get; set; } = string.Empty;
}
