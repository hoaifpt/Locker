using AspNetCore.Identity.MongoDbCore.Models;
using System;

namespace Locker.Backend.Domain.Entities;

public class User : MongoIdentityUser<Guid>
{
    public string? FullName { get; set; }
    public bool IsActive { get; set; } = true;
    public string? EmailVerificationToken { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
