using Locker.Backend.Application.Models;
using Locker.Backend.Domain.Entities;

namespace Locker.Backend.Application.Mapping;

public class UserMapper : IMapper<User, UserDto>
{
    public UserDto Map(User source) => new()
    {
        Id = source.Id,
        Username = source.Username,
        Email = source.Email,
        FullName = source.FullName,
        Role = source.Role,
        IsActive = source.IsActive,
        CreatedAt = source.CreatedAt
    };
}
