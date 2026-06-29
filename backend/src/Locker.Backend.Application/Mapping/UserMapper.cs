using Locker.Backend.Application.Models;
using Locker.Backend.Domain.Entities;

namespace Locker.Backend.Application.Mapping;

public class UserMapper : IMapper<User, UserDto>
{
    public UserDto Map(User user) => new()
    {
        Id = user.Id,
        Username = user.UserName,
        Email = user.Email,
        FullName = user.FullName,
        PhoneNumber = user.PhoneNumber,
        Role = "User",
        IsActive = user.IsActive,
        CreatedAt = user.CreatedAt
    };
}
