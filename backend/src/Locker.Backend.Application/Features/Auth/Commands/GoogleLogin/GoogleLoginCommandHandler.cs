using FirebaseAdmin.Auth;
using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Models;
using Locker.Backend.Domain.Entities;
using MediatR;

namespace Locker.Backend.Application.Features.Auth.Commands.GoogleLogin;

public class GoogleLoginCommandHandler
    : IRequestHandler<GoogleLoginCommand, (AuthResponse? Response, string? Error)>
{
    private readonly IFirebaseAuthService _firebaseAuthService;
    private readonly IIdentityService _identityService;
    private readonly IJwtTokenService _jwtTokenService;
    private readonly IRefreshTokenRepository _refreshTokenRepository;

    public GoogleLoginCommandHandler(
        IFirebaseAuthService firebaseAuthService,
        IIdentityService identityService,
        IJwtTokenService jwtTokenService,
        IRefreshTokenRepository refreshTokenRepository)
    {
        _firebaseAuthService = firebaseAuthService;
        _identityService = identityService;
        _jwtTokenService = jwtTokenService;
        _refreshTokenRepository = refreshTokenRepository;
    }

    public async Task<(AuthResponse? Response, string? Error)> Handle(
        GoogleLoginCommand request,
        CancellationToken cancellationToken)
    {
        FirebaseToken firebaseUser;

        try
        {
            firebaseUser = await _firebaseAuthService.VerifyAsync(request.IdToken);
        }
        catch
        {
            return (null, "Google Token không hợp lệ.");
        }

        var email = firebaseUser.Claims["email"]?.ToString();

        if (string.IsNullOrWhiteSpace(email))
            return (null, "Không lấy được email.");

        var fullName = firebaseUser.Claims.TryGetValue("name", out var nameObj)
            ? nameObj?.ToString()
            : email;

        var user = await _identityService.FindByEmailAsync(email);

        // Nếu chưa có tài khoản -> tạo mới
        if (user == null)
        {
            user = new User
            {
                UserName = email.Split('@')[0],
                Email = email,
                FullName = fullName ?? "",
                EmailConfirmed = true,
                IsActive = true
            };

            // Password random vì Google Login không dùng password
            var password = Guid.NewGuid().ToString("N") + "Aa1!";

            var result = await _identityService.CreateUserAsync(user, password);

            if (!result.Success)
                return (null, string.Join(", ", result.Errors));

            await _identityService.AddToRoleAsync(user, "User");
        }

        if (!user.IsActive)
            return (null, "Tài khoản đã bị khóa.");

        var response = await GenerateAuthResponseAsync(user, cancellationToken);

        return (response, null);
    }

    private async Task<AuthResponse> GenerateAuthResponseAsync(
        User user,
        CancellationToken cancellationToken)
    {
        var roles = await _identityService.GetRolesAsync(user);
        var role = roles.FirstOrDefault() ?? "User";

        var tokenSubject = new TokenSubject(
            user.Id,
            user.UserName,
            user.Email,
            role);

        var accessToken = _jwtTokenService.CreateToken(tokenSubject);
        var refreshTokenValue = _jwtTokenService.CreateRefreshToken(tokenSubject);

        var refreshToken = new Domain.Entities.RefreshToken
        {
            UserId = user.Id,
            Token = refreshTokenValue,
            ExpiresAt = _jwtTokenService.GetRefreshTokenExpiry(),
            CreatedAt = DateTime.UtcNow,
            IsRevoked = false
        };

        await _refreshTokenRepository.CreateAsync(
            refreshToken,
            cancellationToken);

        return new AuthResponse
        {
            Token = accessToken,
            RefreshToken = refreshTokenValue,
            Username = user.UserName ?? "",
            Role = role,
            ExpiresAt = _jwtTokenService.GetAccessTokenExpiry()
        };
    }
}