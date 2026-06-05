using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Models;
using Locker.Backend.Domain.Entities;

using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Services;

public class AuthService
{
    private readonly IIdentityService _identityService;
    private readonly IRefreshTokenRepository _refreshTokenRepository;
    private readonly IJwtTokenService _jwtTokenService;
    private readonly IOtpRepository _otpRepository;
    private readonly IEmailService _emailService;
    private readonly IIdentifierValidator _identifierValidator;
    private readonly ILogger<AuthService> _logger;
    private readonly string _baseUrl;

    private static readonly TimeSpan OtpExpiry = TimeSpan.FromMinutes(5);

    public AuthService(
        IIdentityService identityService,
        IRefreshTokenRepository refreshTokenRepository,
        IJwtTokenService jwtTokenService,
        IOtpRepository otpRepository,
        IEmailService emailService,
        IIdentifierValidator identifierValidator,
        IOptions<AppSettings> appSettings,
        ILogger<AuthService> logger)
    {
        _identityService = identityService;
        _refreshTokenRepository = refreshTokenRepository;
        _jwtTokenService = jwtTokenService;
        _otpRepository = otpRepository;
        _emailService = emailService;
        _identifierValidator = identifierValidator;
        _baseUrl = appSettings.Value.BaseUrl.TrimEnd('/');
        _logger = logger;
    }

    public async Task<(AuthResponse? Response, string? Error)> LoginAsync(AuthRequest request, CancellationToken cancellationToken)
    {
        User? user = null;
        var identifier = request.Identifier.Trim();

        if (identifier.Contains("@"))
        {
            user = await _identityService.FindByEmailAsync(identifier);
        }
        else
        {
            user = (await _identityService.FindByPhoneNumberAsync(identifier));
            user ??= await _identityService.FindByNameAsync(identifier);
        }

        if (user == null)
            return (null, "Email/số điện thoại hoặc mật khẩu không đúng.");

        if (!await _identityService.IsEmailConfirmedAsync(user))
            return (null, "Tài khoản chưa được xác thực email. Vui lòng kiểm tra hộp thư của bạn.");

        if (!user.IsActive)
            return (null, "Tài khoản đã bị vô hiệu hóa.");

        if (await _identityService.IsLockedOutAsync(user))
        {
            var remaining = (int)Math.Ceiling(((user.LockoutEnd ?? DateTimeOffset.UtcNow) - DateTimeOffset.UtcNow).TotalMinutes);
            return (null, $"Tài khoản tạm thời bị khóa do đăng nhập sai quá nhiều lần. Vui lòng thử lại sau {remaining} phút.");
        }

        if (!await _identityService.CheckPasswordAsync(user, request.Password))
        {
            await _identityService.AccessFailedAsync(user);
            if (await _identityService.IsLockedOutAsync(user))
            {
                return (null, "Tài khoản bị khóa do đăng nhập sai nhiều lần liên tiếp.");
            }
            return (null, "Email/số điện thoại hoặc mật khẩu không đúng.");
        }

        await _identityService.ResetAccessFailedCountAsync(user);

        var response = await GenerateAuthResponseAsync(user, cancellationToken);
        return (response, null);
    }

    public async Task<(bool Success, string? Error)> RegisterAsync(RegisterRequest request, CancellationToken cancellationToken)
    {
        var existing = await _identityService.FindByNameAsync(request.Username);
        if (existing != null)
            return (false, "Tên người dùng đã tồn tại.");

        var existingEmail = await _identityService.FindByEmailAsync(request.Email);
        if (existingEmail != null)
            return (false, "Email đã được sử dụng.");

        if (!string.IsNullOrWhiteSpace(request.PhoneNumber))
        {
            var existingPhone = (await _identityService.FindByPhoneNumberAsync(request.PhoneNumber));
            if (existingPhone != null)
                return (false, "Số điện thoại đã được sử dụng.");
        }

        var verificationToken = Guid.NewGuid().ToString("N");

        var user = new User
        {
            UserName = request.Username,
            Email = request.Email,
            FullName = request.FullName,
            PhoneNumber = request.PhoneNumber,
            IsActive = false,
            EmailVerificationToken = verificationToken
        };

        var result = await _identityService.CreateUserAsync(user, request.Password);
        if (!result.Success)
        {
            return (false, string.Join(", ", result.Errors));
        }

        await _identityService.AddToRoleAsync(user, "User");

        try
        {
            var verificationLink = $"{_baseUrl}/api/auth/verify-email?token={verificationToken}";
            await _emailService.SendVerificationEmailAsync(user.Email, user.FullName ?? user.UserName, verificationLink, cancellationToken);
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Failed to send verification email to {Email}.", user.Email);
        }

        return (true, null);
    }

    public async Task<(bool Success, string? Error)> ResendVerificationEmailAsync(ResendVerificationRequest request, CancellationToken cancellationToken)
    {
        var user = await _identityService.FindByEmailAsync(request.Email.Trim());

        if (user == null || await _identityService.IsEmailConfirmedAsync(user))
            return (true, null);

        user.EmailVerificationToken = Guid.NewGuid().ToString("N");
        await _identityService.UpdateUserAsync(user);

        try
        {
            var verificationLink = $"{_baseUrl}/api/auth/verify-email?token={user.EmailVerificationToken}";
            await _emailService.SendVerificationEmailAsync(user.Email, user.FullName ?? user.UserName, verificationLink, cancellationToken);
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Failed to resend verification email to {Email}.", user.Email);
            return (false, "Không thể gửi email. Vui lòng kiểm tra cấu hình SMTP hoặc thử lại sau.");
        }

        return (true, null);
    }

    public async Task<(bool Success, string? Error)> VerifyEmailAsync(string token, CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(token))
            return (false, "Token không hợp lệ.");

        var user = (await _identityService.FindByEmailVerificationTokenAsync(token));
        if (user == null)
            return (false, "Liên kết xác thực không hợp lệ hoặc đã được sử dụng.");

        user.EmailConfirmed = true;
        user.IsActive = true;
        user.EmailVerificationToken = null;
        await _identityService.UpdateUserAsync(user);

        return (true, null);
    }

    public async Task<AuthResponse?> RefreshTokenAsync(string refreshToken, CancellationToken cancellationToken)
    {
        var storedToken = await _refreshTokenRepository.GetByTokenAsync(refreshToken, cancellationToken);
        if (storedToken == null || storedToken.IsRevoked || storedToken.ExpiresAt < DateTime.UtcNow)
            return null;

        var user = await _identityService.FindByIdAsync(storedToken.UserId.ToString());
        if (user == null || !user.IsActive)
            return null;

        await _refreshTokenRepository.RevokeAsync(refreshToken, cancellationToken);
        return await GenerateAuthResponseAsync(user, cancellationToken);
    }

    public async Task<bool> LogoutAsync(string refreshToken, CancellationToken cancellationToken)
    {
        var storedToken = await _refreshTokenRepository.GetByTokenAsync(refreshToken, cancellationToken);
        if (storedToken == null || storedToken.IsRevoked)
            return false;

        await _refreshTokenRepository.RevokeAsync(refreshToken, cancellationToken);
        return true;
    }

    public Task LogoutAllAsync(Guid userId, CancellationToken cancellationToken)
        => _refreshTokenRepository.RevokeAllByUserIdAsync(userId, cancellationToken);

    public async Task<(bool Success, string? Error)> SendForgotPasswordOtpAsync(ForgotPasswordRequest request, CancellationToken cancellationToken)
    {
        var email = request.Email.Trim();

        var (valid, error) = await _identifierValidator.ValidateEmailAsync(email, cancellationToken);
        if (!valid)
            return (false, error);

        var user = await _identityService.FindByEmailAsync(email);

        if (user == null || !user.IsActive)
            return (true, null);

        var bytes = new byte[4];
        System.Security.Cryptography.RandomNumberGenerator.Fill(bytes);
        var code = (Math.Abs(BitConverter.ToInt32(bytes)) % 900_000 + 100_000).ToString();

        var otpCode = new OtpCode
        {
            UserId = user.Id,
            Target = email,
            Code = code,
            ExpiresAt = DateTime.UtcNow.Add(OtpExpiry)
        };

        await _otpRepository.CreateAsync(otpCode, cancellationToken);
        await _emailService.SendOtpAsync(email, code, cancellationToken);

        return (true, null);
    }

    public async Task<(bool Success, string? Error)> ResetPasswordAsync(ResetPasswordRequest request, CancellationToken cancellationToken)
    {
        var email = request.Email.Trim();

        var (valid, error) = await _identifierValidator.ValidateEmailAsync(email, cancellationToken);
        if (!valid)
            return (false, error);

        var user = await _identityService.FindByEmailAsync(email);

        if (user == null || !user.IsActive)
            return (false, "Tài khoản không tồn tại.");

        var otp = await _otpRepository.GetLatestValidAsync(user.Id, email, cancellationToken);
        if (otp == null || otp.Code != request.Otp)
            return (false, "Mã OTP không hợp lệ hoặc đã hết hạn.");

        await _otpRepository.MarkUsedAsync(otp.Id, cancellationToken);

        var resetToken = await _identityService.GeneratePasswordResetTokenAsync(user);
        var result = await _identityService.ResetPasswordAsync(user, resetToken, request.NewPassword);
        
        if (!result.Success)
            return (false, "Không thể thay đổi mật khẩu.");

        return (true, null);
    }

    private async Task<AuthResponse> GenerateAuthResponseAsync(User user, CancellationToken cancellationToken)
    {
        var roles = await _identityService.GetRolesAsync(user);
        var role = roles.FirstOrDefault() ?? "User";

        var tokenSubject = new TokenSubject(user.Id, user.UserName, user.Email, role);
        var accessToken = _jwtTokenService.CreateToken(tokenSubject);
        var refreshTokenValue = _jwtTokenService.CreateRefreshToken();

        var refreshToken = new RefreshToken
        {
            UserId = user.Id,
            Token = refreshTokenValue,
            ExpiresAt = _jwtTokenService.GetRefreshTokenExpiry(),
            CreatedAt = DateTime.UtcNow,
            IsRevoked = false
        };

        await _refreshTokenRepository.CreateAsync(refreshToken, cancellationToken);


        return new AuthResponse
        {
            Token = accessToken,
            RefreshToken = refreshTokenValue,
            Username = user.UserName,
            Role = role,
            ExpiresAt = _jwtTokenService.GetAccessTokenExpiry()
        };
    }
}
