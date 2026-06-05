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
        message.Subject = "MÃ£ OTP Ä‘áº·t láº¡i máº­t kháº©u";

        message.Body = new TextPart("html")
        {
            Text = $"""
                <div style="font-family:sans-serif;max-width:480px;margin:auto">
                  <h2>Äáº·t láº¡i máº­t kháº©u</h2>
                  <p>MÃ£ OTP cá»§a báº¡n lÃ :</p>
                  <div style="font-size:32px;font-weight:bold;letter-spacing:8px;color:#1a73e8">{otpCode}</div>
                  <p>MÃ£ cÃ³ hiá»‡u lá»±c trong <strong>5 phÃºt</strong>.</p>
                  <p style="color:#888;font-size:12px">Náº¿u báº¡n khÃ´ng yÃªu cáº§u Ä‘áº·t láº¡i máº­t kháº©u, hÃ£y bá» qua email nÃ y.</p>
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
        message.Subject = "XÃ¡c thá»±c tÃ i khoáº£n Locker";

        message.Body = new TextPart("html")
        {
            Text = $"""
                <div style="font-family:sans-serif;max-width:520px;margin:auto;border:1px solid #e0e0e0;border-radius:8px;padding:32px">
                  <h2 style="color:#1a73e8;margin-top:0">ChÃ o má»«ng Ä‘áº¿n vá»›i Locker! ðŸŽ‰</h2>
                  <p>Xin chÃ o <strong>{displayName}</strong>,</p>
                  <p>Cáº£m Æ¡n báº¡n Ä‘Ã£ Ä‘Äƒng kÃ½ tÃ i khoáº£n. Vui lÃ²ng nháº¥n nÃºt bÃªn dÆ°á»›i Ä‘á»ƒ xÃ¡c thá»±c Ä‘á»‹a chá»‰ email vÃ  kÃ­ch hoáº¡t tÃ i khoáº£n cá»§a báº¡n.</p>
                  <div style="text-align:center;margin:32px 0">
                    <a href="{verificationLink}"
                       style="background:#1a73e8;color:#fff;text-decoration:none;padding:14px 32px;border-radius:6px;font-size:16px;font-weight:bold">
                      XÃ¡c thá»±c Email
                    </a>
                  </div>
                  <p style="color:#888;font-size:12px">LiÃªn káº¿t cÃ³ hiá»‡u lá»±c trong <strong>24 giá»</strong>. Náº¿u báº¡n khÃ´ng táº¡o tÃ i khoáº£n nÃ y, hÃ£y bá» qua email nÃ y.</p>
                  <hr style="border:none;border-top:1px solid #eee">
                  <p style="color:#aaa;font-size:11px">Hoáº·c copy Ä‘Æ°á»ng dáº«n sau vÃ o trÃ¬nh duyá»‡t:<br/><span style="word-break:break-all">{verificationLink}</span></p>
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