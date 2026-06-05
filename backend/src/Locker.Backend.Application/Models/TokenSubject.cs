using System;

namespace Locker.Backend.Application.Models;

public record TokenSubject(Guid UserId, string? Username, string? Email, string Role);
