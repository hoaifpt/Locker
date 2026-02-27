using System.ComponentModel.DataAnnotations;

namespace Locker.Backend.Application.Models;

public class ForgotPasswordRequest
{
    /// <summary>Email address registered on the account.</summary>
    [Required]
    [EmailAddress]
    public string Email { get; set; } = string.Empty;
}
