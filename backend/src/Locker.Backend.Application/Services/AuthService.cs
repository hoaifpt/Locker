using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Models;
using Locker.Backend.Domain.Entities;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace Locker.Backend.Application.Services;

public class AuthService
{
    private readonly IUserRepository _userRepository;
    private readonly IRefreshTokenRepository _refreshTokenRepository;
    private readonly IPasswordHasher _passwordHasher;
    private readonly IJwtTokenService _jwtTokenService;
    private readonly IOtpRepository _otpRepository;
    private readonly IEmailService _emailService;
    private readonly IIdentifierValidator _identifierValidator;
    private readonly ILogger<AuthService> _logger;
    private readonly string _baseUrl;

    private static readonly TimeSpan OtpExpiry = TimeSpan.FromMinutes(5);

    public AuthService(
        IUserRepository userRepository,
        IRefreshTokenRepository refreshTokenRepository,
        IPasswordHasher passwordHasher,
        IJwtTokenService jwtTokenService,
        IOtpRepository otpRepository,
        IEmailService emailService,
        IIdentifierValidator identifierValidator,
        IOptions<AppSettings> appSettings,
        ILogger<AuthService> logger)
    {
        _userRepository = userRepository;
        _refreshTokenRepository = refreshTokenRepository;
        _passwordHasher = passwordHasher;
        _jwtTokenService = jwtTokenService;
        _otpRepository = otpRepository;
        _emailService = emailService;
        _identifierValidator = identifierValidator;
        _baseUrl = appSettings.Value.BaseUrl.TrimEnd('/');
        _logger = logger;
    }

    public async Task<(AuthResponse? Response, string? Error)> LoginAsync(AuthRequest request, CancellationToken cancellationToken)
    {
        var user = await _userRepository.GetByUsernameAsync(request.Username, cancellationToken);
        if (user == null)
            return (null, "Tên đăng nhập hoặc mật khẩu không đúng.");

        if (!user.IsEmailVerified)
            return (null, "Tài khoản chưa được xác thực email. Vui lòng kiểm tra hộp thư của bạn.");

        if (!user.IsActive)
            return (null, "Tài khoản đã bị vô hiệu hóa.");

        if (string.IsNullOrEmpty(user.PasswordHash) || !_passwordHasher.Verify(request.Password, user.PasswordHash))
            return (null, "Tên đăng nhập hoặc mật khẩu không đúng.");

        var response = await GenerateAuthResponseAsync(user, cancellationToken);
        return (response, null);
    }

    public async Task<(bool Success, string? Error)> RegisterAsync(RegisterRequest request, CancellationToken cancellationToken)
    {
        var existing = await _userRepository.GetByUsernameAsync(request.Username, cancellationToken);
        if (existing != null)
            return (false, "Tên người dùng đã tồn tại.");

        var existingEmail = await _userRepository.GetByEmailAsync(request.Email, cancellationToken);
        if (existingEmail != null)
            return (false, "Email đã được sử dụng.");

        if (!string.IsNullOrWhiteSpace(request.PhoneNumber))
        {
            var existingPhone = await _userRepository.GetByPhoneNumberAsync(request.PhoneNumber, cancellationToken);
            if (existingPhone != null)
                return (false, "Số điện thoại đã được sử dụng.");
        }

        var verificationToken = Guid.NewGuid().ToString("N");

        var user = new User
        {
            Username = request.Username,
            Email = request.Email,
            FullName = request.FullName,
            PhoneNumber = request.PhoneNumber,
            PasswordHash = _passwordHasher.Hash(request.Password),
            Role = "User",
            IsActive = false,          // inactive until email verified
            IsEmailVerified = false,
            EmailVerificationToken = verificationToken
        };

        await _userRepository.CreateAsync(user, cancellationToken);

        // Send verification email — non-blocking: don't fail registration if email fails
        try
        {
            var verificationLink = $"{_baseUrl}/api/auth/verify-email?token={verificationToken}";
            await _emailService.SendVerificationEmailAsync(user.Email, user.FullName ?? user.Username, verificationLink, cancellationToken);
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Failed to send verification email to {Email}. User was created; they can use resend-verification.", user.Email);
        }

        return (true, null);
    }

    /// <summary>
    /// Resend verification email to a registered but unverified account.
    /// </summary>
    public async Task<(bool Success, string? Error)> ResendVerificationEmailAsync(ResendVerificationRequest request, CancellationToken cancellationToken)
    {
        var user = await _userRepository.GetByEmailAsync(request.Email.Trim(), cancellationToken);

        // Don't reveal if email exists — anti-enumeration
        if (user == null || user.IsEmailVerified)
            return (true, null);

        // Rotate token per resend
        user.EmailVerificationToken = Guid.NewGuid().ToString("N");
        await _userRepository.UpdateAsync(user, cancellationToken);

        try
        {
            var verificationLink = $"{_baseUrl}/api/auth/verify-email?token={user.EmailVerificationToken}";
            await _emailService.SendVerificationEmailAsync(user.Email, user.FullName ?? user.Username, verificationLink, cancellationToken);
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Failed to resend verification email to {Email}.", user.Email);
            return (false, "Không thể gửi email. Vui lòng kiểm tra cấu hình SMTP hoặc thử lại sau.");
        }

        return (true, null);
    }

    /// <summary>
    /// Activates the account when the user clicks the verification link in their email.
    /// </summary>
    public async Task<(bool Success, string? Error)> VerifyEmailAsync(string token, CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(token))
            return (false, "Token không hợp lệ.");

        var user = await _userRepository.GetByVerificationTokenAsync(token, cancellationToken);
        if (user == null)
            return (false, "Liên kết xác thực không hợp lệ hoặc đã được sử dụng.");

        user.IsEmailVerified = true;
        user.IsActive = true;
        user.EmailVerificationToken = null;   // one-time use
        await _userRepository.UpdateAsync(user, cancellationToken);

        return (true, null);
    }

    public async Task<AuthResponse?> RefreshTokenAsync(string refreshToken, CancellationToken cancellationToken)
    {
        var storedToken = await _refreshTokenRepository.GetByTokenAsync(refreshToken, cancellationToken);
        if (storedToken == null || storedToken.IsRevoked || storedToken.ExpiresAt < DateTime.UtcNow)
            return null;

        var user = await _userRepository.GetByIdAsync(storedToken.UserId, cancellationToken);
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

    /// <summary>
    /// Determines if the identifier is an email or phone, validates it's real,
    /// finds the user, generates OTP, and dispatches it.
    /// Returns (false, errorMessage) on validation failure; (true, null) on success or account not found (anti-enumeration).
    /// </summary>
    public async Task<(bool Success, string? Error)> SendForgotPasswordOtpAsync(ForgotPasswordRequest request, CancellationToken cancellationToken)
    {
        var email = request.Email.Trim();

        var (valid, error) = await _identifierValidator.ValidateEmailAsync(email, cancellationToken);
        if (!valid)
            return (false, error);

        // Look up user (silently succeed if not found – anti-enumeration)
        var user = await _userRepository.GetByEmailAsync(email, cancellationToken);

        if (user == null || !user.IsActive)
            return (true, null); // anti-enumeration: don't reveal non-existence

        // Generate a 6-digit OTP
        var code = Random.Shared.Next(100_000, 999_999).ToString();

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

    /// <summary>
    /// Validates the OTP and resets the password if valid.
    /// Returns (false, errorMessage) on failure.
    /// </summary>
    public async Task<(bool Success, string? Error)> ResetPasswordAsync(ResetPasswordRequest request, CancellationToken cancellationToken)
    {
        var email = request.Email.Trim();

        var (valid, error) = await _identifierValidator.ValidateEmailAsync(email, cancellationToken);
        if (!valid)
            return (false, error);

        var user = await _userRepository.GetByEmailAsync(email, cancellationToken);

        if (user == null || !user.IsActive)
            return (false, "Tài khoản không tồn tại.");

        var otp = await _otpRepository.GetLatestValidAsync(user.Id, email, cancellationToken);
        if (otp == null || otp.Code != request.Otp)
            return (false, "Mã OTP không hợp lệ hoặc đã hết hạn.");

        // Mark OTP as used
        await _otpRepository.MarkUsedAsync(otp.Id, cancellationToken);

        // Update password
        user.PasswordHash = _passwordHasher.Hash(request.NewPassword);
        await _userRepository.UpdateAsync(user, cancellationToken);

        return (true, null);
    }

    private async Task<AuthResponse> GenerateAuthResponseAsync(User user, CancellationToken cancellationToken)
    {
        var accessToken = _jwtTokenService.CreateToken(user);
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
            Username = user.Username,
            Role = user.Role,
            ExpiresAt = _jwtTokenService.GetAccessTokenExpiry()
        };
    }
}
