using Locker.Backend.Application.Interfaces;
using Locker.Backend.Infrastructure.Notifications;
using MailKit.Net.Smtp;
using MailKit.Security;
using Microsoft.Extensions.Options;
using MimeKit;

namespace Locker.Backend.Infrastructure.Services;

public class EmailService : IEmailService
{
    private readonly EmailSettings _settings;

    public EmailService(IOptions<EmailSettings> settings)
    {
        _settings = settings.Value;
    }

    public async Task SendOtpAsync(string toEmail, string otpCode, CancellationToken cancellationToken)
    {
        var message = new MimeMessage();
        message.From.Add(new MailboxAddress(_settings.FromName, _settings.FromAddress));
        message.To.Add(MailboxAddress.Parse(toEmail));
        message.Subject = "Mã OTP đặt lại mật khẩu";

        message.Body = new TextPart("html")
        {
            Text = $"""
                <div style="font-family:sans-serif;max-width:480px;margin:auto">
                  <h2>Đặt lại mật khẩu</h2>
                  <p>Mã OTP của bạn là:</p>
                  <div style="font-size:32px;font-weight:bold;letter-spacing:8px;color:#1a73e8">{otpCode}</div>
                  <p>Mã có hiệu lực trong <strong>5 phút</strong>.</p>
                  <p style="color:#888;font-size:12px">Nếu bạn không yêu cầu đặt lại mật khẩu, hãy bỏ qua email này.</p>
                </div>
                """
        };

        await SendAsync(message, cancellationToken);
    }

    public async Task SendVerificationEmailAsync(string toEmail, string fullName, string verificationLink, CancellationToken cancellationToken)
    {
        var displayName = string.IsNullOrWhiteSpace(fullName) ? toEmail : fullName;

        var message = new MimeMessage();
        message.From.Add(new MailboxAddress(_settings.FromName, _settings.FromAddress));
        message.To.Add(MailboxAddress.Parse(toEmail));
        message.Subject = "Xác thực tài khoản Locker";

        message.Body = new TextPart("html")
        {
            Text = $"""
                <div style="font-family:sans-serif;max-width:520px;margin:auto;border:1px solid #e0e0e0;border-radius:8px;padding:32px">
                  <h2 style="color:#1a73e8;margin-top:0">Chào mừng đến với Locker! 🎉</h2>
                  <p>Xin chào <strong>{displayName}</strong>,</p>
                  <p>Cảm ơn bạn đã đăng ký tài khoản. Vui lòng nhấn nút bên dưới để xác thực địa chỉ email và kích hoạt tài khoản của bạn.</p>
                  <div style="text-align:center;margin:32px 0">
                    <a href="{verificationLink}"
                       style="background:#1a73e8;color:#fff;text-decoration:none;padding:14px 32px;border-radius:6px;font-size:16px;font-weight:bold">
                      Xác thực Email
                    </a>
                  </div>
                  <p style="color:#888;font-size:12px">Liên kết có hiệu lực trong <strong>24 giờ</strong>. Nếu bạn không tạo tài khoản này, hãy bỏ qua email này.</p>
                  <hr style="border:none;border-top:1px solid #eee">
                  <p style="color:#aaa;font-size:11px">Hoặc copy đường dẫn sau vào trình duyệt:<br/><span style="word-break:break-all">{verificationLink}</span></p>
                </div>
                """
        };

        await SendAsync(message, cancellationToken);
    }

    private async Task SendAsync(MimeMessage message, CancellationToken cancellationToken)
    {
        using var client = new SmtpClient();
        var secureOption = _settings.UseStartTls
            ? SecureSocketOptions.StartTls
            : (_settings.UseSsl ? SecureSocketOptions.SslOnConnect : SecureSocketOptions.None);

        await client.ConnectAsync(_settings.Host, _settings.Port, secureOption, cancellationToken);
        await client.AuthenticateAsync(_settings.Username, _settings.Password, cancellationToken);
        await client.SendAsync(message, cancellationToken);
        await client.DisconnectAsync(true, cancellationToken);
    }
}