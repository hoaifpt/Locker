using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Models;
using Locker.Backend.Infrastructure.Mongo;
using Locker.Backend.Infrastructure.Notifications;
using Locker.Backend.Infrastructure.Repositories;
using Locker.Backend.Infrastructure.Security;
using Locker.Backend.Infrastructure.Services;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace Locker.Backend.Infrastructure;

public static class DependencyInjection
{
    public static IServiceCollection AddInfrastructure(this IServiceCollection services, IConfiguration configuration)
    {
        services.Configure<MongoSettings>(configuration.GetSection("Mongo"));
        services.Configure<JwtSettings>(configuration.GetSection("Jwt"));
        services.Configure<EmailSettings>(configuration.GetSection("Email"));
        services.Configure<AppSettings>(configuration.GetSection("App"));

        services.AddSingleton<MongoContext>();
        services.AddScoped<ILockerRepository, LockerRepository>();
        services.AddScoped<IUserRepository, UserRepository>();
        services.AddScoped<IRefreshTokenRepository, RefreshTokenRepository>();
        services.AddScoped<IPackageRepository, PackageRepository>();
        services.AddScoped<IBookingRepository, BookingRepository>();
        services.AddScoped<IPaymentRepository, PaymentRepository>();
        services.AddScoped<IOtpRepository, OtpRepository>();
        services.AddScoped<IJwtTokenService, JwtTokenService>();
        services.AddScoped<IPasswordHasher, PasswordHasher>();
        services.AddScoped<IEmailService, EmailService>();
        services.AddScoped<IIdentifierValidator, IdentifierValidator>();

        return services;
    }
}
