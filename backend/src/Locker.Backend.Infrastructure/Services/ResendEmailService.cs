using Locker.Backend.Application.Interfaces;
using Locker.Backend.Infrastructure.Notifications;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Resend;

namespace Locker.Backend.Infrastructure.Services;

public class ResendEmailService : IEmailService
{
    private readonly IResend _resend;
    private readonly ResendSettings _settings;
    private readonly ILogger<ResendEmailService> _logger;

    public ResendEmailService(
        IResend resend,
        IOptions<ResendSettings> settings,
        ILogger<ResendEmailService> logger)
    {
        _resend = resend;
        _settings = settings.Value;
        _logger = logger;
    }

    public async Task SendOtpAsync(
        string toEmail,
        string otpCode,
        CancellationToken cancellationToken)
    {
        var body = $"""
        <div style="font-family:Arial,sans-serif;max-width:500px;margin:auto">
            <h2>Đặt lại mật khẩu</h2>

            <p>Mã OTP của bạn là:</p>

            <div style="
                font-size:32px;
                font-weight:bold;
                color:#1a73e8;
                letter-spacing:6px;
                margin:20px 0;">
                {otpCode}
            </div>

            <p>Mã OTP có hiệu lực trong <strong>5 phút</strong>.</p>

            <hr>

            <small>
                Nếu bạn không yêu cầu đặt lại mật khẩu,
                hãy bỏ qua email này.
            </small>
        </div>
        """;

        await SendEmailAsync(
            toEmail,
            "Mã OTP đặt lại mật khẩu",
            body,
            cancellationToken);
    }

    public async Task SendVerificationEmailAsync(
        string toEmail,
        string fullName,
        string verificationLink,
        CancellationToken cancellationToken)
    {
        var name = string.IsNullOrWhiteSpace(fullName)
            ? toEmail
            : fullName;

        var body = $"""
        <div style="font-family:Arial,sans-serif;max-width:550px;margin:auto">

            <h2>Chào {name} 👋</h2>

            <p>
                Cảm ơn bạn đã đăng ký tài khoản Locker.
            </p>

            <p>
                Vui lòng nhấn nút dưới đây để xác thực email.
            </p>

            <div style="margin:30px 0">
                <a href="{verificationLink}"
                   style="
                        background:#1a73e8;
                        color:white;
                        padding:14px 28px;
                        border-radius:6px;
                        text-decoration:none;
                        font-weight:bold;">
                    Xác thực Email
                </a>
            </div>

            <p>
                Hoặc copy đường dẫn sau:
            </p>

            <p style="word-break:break-all">
                {verificationLink}
            </p>

            <hr>

            <small>
                Liên kết xác thực có hiệu lực trong 24 giờ.
            </small>

        </div>
        """;

        await SendEmailAsync(
            toEmail,
            "Xác thực tài khoản Locker",
            body,
            cancellationToken);
    }

    public async Task SendEmailAsync(
        string toEmail,
        string subject,
        string body)
    {
        await SendEmailAsync(
            toEmail,
            subject,
            body,
            CancellationToken.None);
    }

    private async Task SendEmailAsync(
        string toEmail,
        string subject,
        string body,
        CancellationToken cancellationToken)
    {
        var email = new EmailMessage
        {
            From = $"{_settings.FromName} <{_settings.FromEmail}>",
            Subject = subject,
            HtmlBody = body
        };

        email.To.Add(toEmail);

        try
        {
            _logger.LogInformation(
                "Sending email to {Email}",
                toEmail);

            var response = await _resend.EmailSendAsync(email);

            _logger.LogInformation(
                "Email sent successfully to {Email}",
                toEmail);
        }
        catch (Exception ex)
        {
            _logger.LogError(
                ex,
                "Failed to send email to {Email}",
                toEmail);

            throw;
        }
    }
}