using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
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
            new Claim(JwtRegisteredClaimNames.Email, subject.Email ?? string.Empty)
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

    public string CreateRefreshToken()
    {
        var randomBytes = new byte[64];
        using var rng = RandomNumberGenerator.Create();
        rng.GetBytes(randomBytes);
        return Convert.ToBase64String(randomBytes);
    }

    public DateTime GetAccessTokenExpiry()
        => DateTime.UtcNow.AddMinutes(_settings.ExpiryMinutes);

    public DateTime GetRefreshTokenExpiry()
        => DateTime.UtcNow.AddDays(_settings.RefreshTokenExpiryDays);
}
