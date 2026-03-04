using System.ComponentModel.DataAnnotations;

namespace Locker.Backend.Application.Models;

public class ResetPasswordRequest
{
    /// <summary>Email address used in the forgot-password request.</summary>
    [Required]
    [EmailAddress]
    public string Email { get; set; } = string.Empty;

    [Required]
    public string Otp { get; set; } = string.Empty;

    [Required]
    [MinLength(6)]
    public string NewPassword { get; set; } = string.Empty;
}
