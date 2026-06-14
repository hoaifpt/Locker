using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Models;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;

namespace Locker.Backend.Infrastructure.Security;

public class JwtTokenService : IJwtTokenService
{
    private readonly JwtSettings _settings;

    public JwtTokenService(IOptions<JwtSettings> settings)
    {
        _settings = settings.Value;

        if (string.IsNullOrWhiteSpace(_settings.Secret) || _settings.Secret.Length < 32)
        {
            throw new InvalidOperationException("Jwt:Secret must be at least 32 characters long.");
        }
    }

    public string CreateToken(TokenSubject subject)
    {
        var claims = new List<Claim>
        {
            new Claim(JwtRegisteredClaimNames.Sub, subject.UserId.ToString()),
            new Claim(ClaimTypes.NameIdentifier, subject.UserId.ToString()),
            new Claim(JwtRegisteredClaimNames.UniqueName, subject.Username ?? string.Empty),
            new Claim(ClaimTypes.Name, subject.Username ?? string.Empty),
            new Claim(ClaimTypes.Role, subject.Role),
            new Claim(JwtRegisteredClaimNames.Email, subject.Email ?? string.Empty),
            new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString())
        };

        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_settings.Secret));
        var credentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        var token = new JwtSecurityToken(
            _settings.Issuer,
            _settings.Audience,
            claims,
            expires: GetAccessTokenExpiry(),
            signingCredentials: credentials);

        return new JwtSecurityTokenHandler().WriteToken(token);
    }

    public string CreateRefreshToken(TokenSubject subject)
    {
        var claims = new[]
        {
            new Claim(JwtRegisteredClaimNames.Sub, subject.UserId.ToString()),
            new Claim(ClaimTypes.NameIdentifier, subject.UserId.ToString()),
            new Claim(JwtRegisteredClaimNames.UniqueName, subject.Username ?? string.Empty),
            new Claim(ClaimTypes.Name, subject.Username ?? string.Empty),
            new Claim(ClaimTypes.Role, subject.Role),
            new Claim(JwtRegisteredClaimNames.Email, subject.Email ?? string.Empty),
            new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()),
            new Claim("token_type", "refresh_token")
        };

        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_settings.Secret));
        var credentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        var token = new JwtSecurityToken(
            _settings.Issuer,
            _settings.Audience,
            claims,
            expires: GetRefreshTokenExpiry(),
            signingCredentials: credentials);

        return new JwtSecurityTokenHandler().WriteToken(token);
    }

    public DateTime GetAccessTokenExpiry()
        => DateTime.UtcNow.AddMinutes(_settings.ExpiryMinutes);

    public DateTime GetRefreshTokenExpiry()
        => DateTime.UtcNow.AddDays(_settings.RefreshTokenExpiryDays);

    public DateTime? GetTokenExpiry(string token)
    {
        var jwt = ReadToken(token);
        return jwt?.ValidTo == default ? null : jwt?.ValidTo;
    }

    public string? GetTokenJti(string token)
    {
        var jwt = ReadToken(token);
        return jwt?.Claims.FirstOrDefault(c => c.Type == JwtRegisteredClaimNames.Jti)?.Value;
    }

    private static JwtSecurityToken? ReadToken(string token)
    {
        var handler = new JwtSecurityTokenHandler();
        return handler.CanReadToken(token) ? handler.ReadJwtToken(token) : null;
    }
}
