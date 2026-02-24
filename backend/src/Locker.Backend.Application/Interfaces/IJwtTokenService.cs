using Locker.Backend.Domain.Entities;

namespace Locker.Backend.Application.Interfaces;

public interface IJwtTokenService
{
    string CreateToken(User user);
    string CreateRefreshToken();
    DateTime GetAccessTokenExpiry();
    DateTime GetRefreshTokenExpiry();
}
