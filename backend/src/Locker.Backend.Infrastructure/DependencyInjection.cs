using AspNetCore.Identity.MongoDbCore.Extensions;
using AspNetCore.Identity.MongoDbCore.Infrastructure;
using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Models;
using Locker.Backend.Infrastructure.Mongo;
using Locker.Backend.Infrastructure.Notifications;
using Locker.Backend.Infrastructure.Repositories;
using Locker.Backend.Infrastructure.Security;
using Locker.Backend.Infrastructure.Services;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Locker.Backend.Domain.Entities;
using Resend;

namespace Locker.Backend.Infrastructure;

public static class DependencyInjection
{
    public static IServiceCollection AddInfrastructure(this IServiceCollection services, IConfiguration configuration)
    {
        services.Configure<MongoSettings>(configuration.GetSection("Mongo"));
        services.Configure<JwtSettings>(configuration.GetSection("Jwt"));
        services.Configure<ResendSettings>(configuration.GetSection("Resend"));

        services.AddHttpClient();

        services.AddResend(options =>
        {
            options.ApiToken = configuration["Resend:ApiKey"]!;
        });

        services.Configure<AppSettings>(configuration.GetSection("App"));
        services.Configure<VnPaySettings>(configuration.GetSection("VnPay"));

        services.AddSingleton<MongoContext>();
        services.AddScoped<ILockerRepository, LockerRepository>();
        services.AddScoped<IRefreshTokenRepository, RefreshTokenRepository>();
        services.AddScoped<IPackageRepository, PackageRepository>();
        services.AddScoped<IBookingRepository, BookingRepository>();
        services.AddScoped<IOrderRepository, OrderRepository>();
        services.AddScoped<IPaymentRepository, PaymentRepository>();
        services.AddScoped<IOtpRepository, OtpRepository>();
        services.AddScoped<INotificationRepository, NotificationRepository>();
        services.AddScoped<IDeviceTokenRepository, DeviceTokenRepository>();
        services.AddScoped<IWalletTransactionRepository, WalletTransactionRepository>();
        services.AddScoped<IRestaurantRepository, RestaurantRepository>();
        services.AddScoped<IMenuItemRepository, MenuItemRepository>();
        services.AddScoped<IFoodOrderRepository, FoodOrderRepository>();
        services.AddScoped<IDeliveryRequestRepository, DeliveryRequestRepository>();
        services.AddScoped<ISendReceiveOrderRepository, SendReceiveOrderRepository>();
        services.AddScoped<ILockerEventRepository, LockerEventRepository>();

        services.AddScoped<IJwtTokenService, JwtTokenService>();
        services.AddScoped<IPasswordHasher, PasswordHasher>();
        services.AddScoped<IEmailService, ResendEmailService>();
        services.AddScoped<IIdentifierValidator, IdentifierValidator>();
        services.AddScoped<IIdentityService, IdentityService>();
        services.AddScoped<IVnPayService, VnPayService>();

        services.AddHostedService<OverdueOrderBackgroundService>();

        var mongoConnectionString = configuration["Mongo:ConnectionString"]
            ?? "mongodb://localhost:27017/LockerDb";

        var mongoDatabaseName = configuration["Mongo:DatabaseName"]
            ?? "LockerDb";

        var mongoDbIdentityConfig = new MongoDbIdentityConfiguration
        {
            MongoDbSettings = new MongoDbSettings
            {
                ConnectionString = mongoConnectionString,
                DatabaseName = mongoDatabaseName
            },
            IdentityOptionsAction = options =>
            {
                options.Password.RequireDigit = true;
                options.Password.RequiredLength = 8;
                options.Password.RequireUppercase = true;
                options.Password.RequireLowercase = true;
                options.Password.RequireNonAlphanumeric = false;
                options.User.RequireUniqueEmail = true;
            }
        };

        services.ConfigureMongoDbIdentity<User, Role, Guid>(mongoDbIdentityConfig)
            .AddDefaultTokenProviders();

        return services;
    }

    public static async Task UseDatabaseSeeder(this IServiceProvider serviceProvider)
    {
        await Data.DbSeeder.SeedAsync(serviceProvider);
    }
}
