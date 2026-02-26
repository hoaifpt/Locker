using Locker.Backend.Application.Models;
using Locker.Backend.Application.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;

namespace Locker.Backend.Controllers;

[ApiController]
[Route("api/auth")]
[EnableRateLimiting("auth")]
public class AuthController : ControllerBase
{
    private readonly AuthService _authService;

    public AuthController(AuthService authService)
    {
        _authService = authService;
    }

    [HttpPost("login")]
    [AllowAnonymous]
    public async Task<IActionResult> Login([FromBody] AuthRequest request, CancellationToken cancellationToken)
    {
        var (response, error) = await _authService.LoginAsync(request, cancellationToken);
        if (response == null)
            return Unauthorized(new { message = error ?? "Tên đăng nhập hoặc mật khẩu không đúng." });

        return Ok(response);
    }

    [HttpPost("register")]
    [AllowAnonymous]
    public async Task<IActionResult> Register([FromBody] RegisterRequest request, CancellationToken cancellationToken)
    {
        // RegisterAsync returns null on duplicate username OR after successful registration
        // We distinguish by trying to look up the user before calling register.
        // To keep it simple, RegisterAsync now throws on duplicate and returns null on success.
        // See the updated contract below.
        var (success, error) = await _authService.RegisterAsync(request, cancellationToken);
        if (!success)
            return Conflict(new { message = error });

        return Ok(new { message = "Đăng ký thành công. Vui lòng kiểm tra email để xác thực tài khoản." });
    }

    /// <summary>
    /// Verify email address via the token sent in the registration email.
    /// </summary>
    [HttpGet("verify-email")]
    [AllowAnonymous]
    public async Task<IActionResult> VerifyEmail([FromQuery] string token, CancellationToken cancellationToken)
    {
        var (success, error) = await _authService.VerifyEmailAsync(token, cancellationToken);
        if (!success)
            return BadRequest(new { message = error });

        return Ok(new { message = "Email đã được xác thực thành công. Bạn có thể đăng nhập ngay bây giờ." });
    }

    /// <summary>
    /// Resend the verification email to the given address (useful when SMTP failed at registration time).
    /// </summary>
    [HttpPost("resend-verification")]
    [AllowAnonymous]
    public async Task<IActionResult> ResendVerification([FromBody] ResendVerificationRequest request, CancellationToken cancellationToken)
    {
        var (success, error) = await _authService.ResendVerificationEmailAsync(request, cancellationToken);
        if (!success)
            return BadRequest(new { message = error });

        // Always 200 to avoid email enumeration
        return Ok(new { message = "Nếu email chưa được xác thực, chúng tôi đã gửi lại liên kết xác thực." });
    }

    [HttpPost("refresh")]
    [AllowAnonymous]
    public async Task<IActionResult> Refresh([FromBody] RefreshTokenRequest request, CancellationToken cancellationToken)
    {
        var response = await _authService.RefreshTokenAsync(request.RefreshToken, cancellationToken);
        if (response == null)
            return Unauthorized(new { message = "Invalid or expired refresh token" });

        return Ok(response);
    }

    [HttpPost("logout")]
    [Authorize]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    public async Task<IActionResult> Logout([FromBody] LogoutRequest request, CancellationToken cancellationToken)
    {
        await _authService.LogoutAsync(request.RefreshToken, cancellationToken);
        return NoContent();
    }

    /// <summary>
    /// Send a 6-digit OTP to the user's email or phone number for password reset.
    /// </summary>
    [HttpPost("forgot-password")]
    [AllowAnonymous]
    public async Task<IActionResult> ForgotPassword([FromBody] ForgotPasswordRequest request, CancellationToken cancellationToken)
    {
        var (success, error) = await _authService.SendForgotPasswordOtpAsync(request, cancellationToken);
        if (!success)
            return BadRequest(new { message = error });

        // Always return 200 even if account not found (anti-enumeration)
        return Ok(new { message = "Nếu tài khoản tồn tại, mã OTP đã được gửi." });
    }

    /// <summary>
    /// Reset the password using the OTP received via email or SMS.
    /// </summary>
    [HttpPost("reset-password")]
    [AllowAnonymous]
    public async Task<IActionResult> ResetPassword([FromBody] ResetPasswordRequest request, CancellationToken cancellationToken)
    {
        var (success, error) = await _authService.ResetPasswordAsync(request, cancellationToken);
        if (!success)
            return BadRequest(new { message = error });

        return Ok(new { message = "Mật khẩu đã được đặt lại thành công." });
    }
}

