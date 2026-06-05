using Locker.Backend.Domain.Entities;

namespace Locker.Backend.Application.Interfaces;

public interface IJwtTokenService
{
    string CreateToken(User user, string role);
    string CreateRefreshToken();
    DateTime GetAccessTokenExpiry();
    DateTime GetRefreshTokenExpiry();
}
