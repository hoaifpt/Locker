using System.Security.Claims;
using Locker.Backend.Domain.Entities;

namespace Locker.Backend.Application.Interfaces;

public interface IJwtTokenService
{
    string GenerateAccessToken(User user, IList<string> roles);
    string GenerateRefreshTokenJwt(User user, IList<string> roles);
    DateTime GetAccessTokenExpiryTime();
    DateTime GetRefreshTokenExpiryTime();
    ClaimsPrincipal? GetPrincipalFromExpiredToken(string token);
}
