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
        <div style="background-color: #fcf0e9; padding: 40px 20px; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; line-height: 1.6;">
            <div style="max-width: 600px; margin: 0 auto; background-color: #ffffff; border-radius: 12px; overflow: hidden; box-shadow: 0 4px 15px rgba(244,123,89,0.1);">
                
                <div style="background-color: #f47b59; padding: 30px; text-align: center;">
                    <h1 style="margin: 0; color: #ffffff; font-size: 28px; letter-spacing: 2px; font-weight: bold;">E-BOX</h1>
                </div>

                <div style="padding: 40px 30px; color: #333333; text-align: center;">
                    <h2 style="margin-top: 0; color: #202124; font-size: 22px;">Yêu cầu đặt lại mật khẩu</h2>
                    <p style="font-size: 16px; color: #5f6368;">Mã OTP xác thực của bạn là:</p>
                    
                    <div style="font-size: 36px; font-weight: bold; color: #f47b59; letter-spacing: 8px; margin: 30px 0; padding: 15px; background-color: #fef5f2; border-radius: 8px; border: 2px dashed #f47b59; display: inline-block;">
                        {otpCode}
                    </div>

                    <p style="font-size: 15px; color: #e53935; font-weight: bold;">
                        Mã OTP này có hiệu lực trong 5 phút.
                    </p>
                </div>

                <div style="background-color: #fef5f2; padding: 25px 30px; text-align: center; border-top: 1px solid #f9e2d9; color: #80868b; font-size: 13px;">
                    <p style="margin: 0 0 10px 0;">Nếu bạn không yêu cầu đặt lại mật khẩu, vui lòng bỏ qua email này để đảm bảo an toàn.</p>
                    <p style="margin: 20px 0 0 0; font-weight: bold;">© 2026 E-Box System.</p>
                </div>
            </div>
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
        <div style="background-color: #fcf0e9; padding: 40px 20px; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; line-height: 1.6;">
            <div style="max-width: 600px; margin: 0 auto; background-color: #ffffff; border-radius: 12px; overflow: hidden; box-shadow: 0 4px 15px rgba(244,123,89,0.1);">
                
                <div style="background-color: #f47b59; padding: 30px; text-align: center;">
                    <h1 style="margin: 0; color: #ffffff; font-size: 28px; letter-spacing: 2px; font-weight: bold;">E-BOX</h1>
                </div>

                <div style="padding: 40px 30px; color: #333333;">
                    <h2 style="margin-top: 0; color: #202124; font-size: 22px;">Chào {name}, 👋</h2>
                    <p style="font-size: 16px; color: #5f6368;">
                        Cảm ơn bạn đã đăng ký tài khoản sử dụng dịch vụ tủ đồ thông minh E-Box. Để đảm bảo an toàn và kích hoạt các tính năng của ứng dụng, vui lòng xác thực địa chỉ email của bạn.
                    </p>

                    <div style="text-align: center; margin: 40px 0;">
                        <a href="{verificationLink}"
                           style="background-color: #f47b59; color: #ffffff; padding: 14px 32px; border-radius: 8px; text-decoration: none; font-weight: 600; font-size: 16px; display: inline-block; box-shadow: 0 4px 6px rgba(244,123,89,0.25);">
                            Xác thực Email ngay
                        </a>
                    </div>

                    <p style="font-size: 15px; color: #5f6368;">
                        Nếu nút trên không hoạt động, bạn có thể copy và dán đường dẫn dưới đây vào trình duyệt:
                    </p>
                    
                    <div style="background-color: #fef5f2; padding: 15px; border-radius: 6px; word-break: break-all; font-size: 13px; color: #f47b59; border: 1px dashed #f47b59;">
                        {verificationLink}
                    </div>
                </div>

                <div style="background-color: #fef5f2; padding: 25px 30px; text-align: center; border-top: 1px solid #f9e2d9; color: #80868b; font-size: 13px;">
                    <p style="margin: 0 0 10px 0;">Liên kết xác thực này có hiệu lực trong vòng <strong>24 giờ</strong>.</p>
                    <p style="margin: 0 0 10px 0;">Nếu bạn không tạo tài khoản này, vui lòng bỏ qua email và không chia sẻ liên kết cho bất kỳ ai.</p>
                    <p style="margin: 20px 0 0 0; font-weight: bold;">© 2026 E-Box System.</p>
                </div>
            </div>
        </div>
        """;

        await SendEmailAsync(
            toEmail,
            "Xác thực tài khoản E-Box",
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