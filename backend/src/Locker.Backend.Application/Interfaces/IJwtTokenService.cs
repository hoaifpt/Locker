using Locker.Backend.Application.Models;

namespace Locker.Backend.Application.Interfaces;

public interface IJwtTokenService
{
    string CreateToken(TokenSubject subject);
    string CreateRefreshToken(TokenSubject subject);
    DateTime GetAccessTokenExpiry();
    DateTime GetRefreshTokenExpiry();
}
