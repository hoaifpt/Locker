using Locker.Backend.Application.Models;
using Locker.Backend.Application.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;

using MediatR;
using Locker.Backend.Application.Features.Auth.Commands.Login;
using Locker.Backend.Application.Features.Auth.Commands.Register;
using Locker.Backend.Application.Features.Auth.Commands.ResendVerificationEmail;
using Locker.Backend.Application.Features.Auth.Commands.VerifyEmail;
using Locker.Backend.Application.Features.Auth.Commands.RefreshToken;
using Locker.Backend.Application.Features.Auth.Commands.Logout;
using Locker.Backend.Application.Features.Auth.Commands.LogoutAll;
using Locker.Backend.Application.Features.Auth.Commands.SendForgotPasswordOtp;
using Locker.Backend.Application.Features.Auth.Commands.ResetPassword;

namespace Locker.Backend.Controllers;

[ApiController]
[Route("api/auth")]
[EnableRateLimiting("auth")]
public class AuthController : ControllerBase
{
    private readonly ISender _sender;

    public AuthController(ISender sender)
    {
        _sender = sender;
    }

    [HttpPost("login")]
    [AllowAnonymous]
    public async Task<IActionResult> Login([FromBody] AuthRequest request, CancellationToken cancellationToken)
    {
        var (response, error) = await _sender.Send(new LoginCommand(request.Identifier, request.Password), cancellationToken);
        if (response == null)
            return Unauthorized(new { message = error ?? "Email/số điện thoại hoặc mật khẩu không đúng." });

        return Ok(response);
    }

    [HttpPost("register")]
    [AllowAnonymous]
    public async Task<IActionResult> Register([FromBody] RegisterRequest request, CancellationToken cancellationToken)
    {
        var command = new RegisterCommand(request.Username, request.Email, request.Password, request.FullName, request.PhoneNumber);
        var (response, error) = await _sender.Send(command, cancellationToken);
        if (response == null)
            return Conflict(new { message = error });

        return Ok(response);
    }

    /// <summary>
    /// Verify email address via the token sent in the registration email.
    /// </summary>
    [HttpGet("verify-email")]
    [AllowAnonymous]
    public async Task<IActionResult> VerifyEmail([FromQuery] string token, CancellationToken cancellationToken)
    {
        var (success, error) = await _sender.Send(new VerifyEmailCommand(token), cancellationToken);
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
        var (success, error) = await _sender.Send(new ResendVerificationEmailCommand(request.Email), cancellationToken);
        if (!success)
            return BadRequest(new { message = error });

        // Always 200 to avoid email enumeration
        return Ok(new { message = "Nếu email chưa được xác thực, chúng tôi đã gửi lại liên kết xác thực." });
    }

    [HttpPost("refresh")]
    [AllowAnonymous]
    public async Task<IActionResult> Refresh([FromBody] RefreshTokenRequest request, CancellationToken cancellationToken)
    {
        var response = await _sender.Send(new RefreshTokenCommand(request.RefreshToken), cancellationToken);
        if (response == null)
            return Unauthorized(new { message = "Invalid or expired refresh token" });

        return Ok(response);
    }

    [HttpPost("logout")]
    [Authorize]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    public async Task<IActionResult> Logout([FromBody] LogoutRequest request, CancellationToken cancellationToken)
    {
        await _sender.Send(new LogoutCommand(request.RefreshToken), cancellationToken);
        return NoContent();
    }

    /// <summary>
    /// Revoke all active refresh tokens for the current user (logout from all devices).
    /// </summary>
    [HttpPost("logout-all")]
    [Authorize]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    public async Task<IActionResult> LogoutAll(CancellationToken cancellationToken)
    {
        var userIdString = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
        if (!Guid.TryParse(userIdString, out var userId))
            return Unauthorized();

        await _sender.Send(new LogoutAllCommand(userId), cancellationToken);
        return NoContent();
    }

    /// <summary>
    /// Send a 6-digit OTP to the user's email or phone number for password reset.
    /// </summary>
    [HttpPost("forgot-password")]
    [AllowAnonymous]
    public async Task<IActionResult> ForgotPassword([FromBody] ForgotPasswordRequest request, CancellationToken cancellationToken)
    {
        var (success, error) = await _sender.Send(new SendForgotPasswordOtpCommand(request.Email), cancellationToken);
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
        var (success, error) = await _sender.Send(new ResetPasswordCommand(request.Email, request.Otp, request.NewPassword), cancellationToken);
        if (!success)
            return BadRequest(new { message = error });

        return Ok(new { message = "Mật khẩu đã được đặt lại thành công." });
    }
}
