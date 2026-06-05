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
        services.AddScoped<IEmailService, EmailService>();
        services.AddScoped<IIdentifierValidator, IdentifierValidator>();
        services.AddScoped<IIdentityService, IdentityService>();

        var mongoConnectionString = configuration.GetSection("Mongo:ConnectionString").Value ?? "mongodb://localhost:27017/LockerDb";
        var mongoDatabaseName = configuration.GetSection("Mongo:DatabaseName").Value ?? "LockerDb";
        var mongoDbIdentityConfig = new MongoDbIdentityConfiguration
        {
            MongoDbSettings = new MongoDbSettings
            {
                ConnectionString = mongoConnectionString,
                DatabaseName = mongoDatabaseName
            },
            IdentityOptionsAction = identityOptions =>
            {
                identityOptions.Password.RequireDigit = false;
                identityOptions.Password.RequiredLength = 6;
                identityOptions.Password.RequireNonAlphanumeric = false;
                identityOptions.Password.RequireUppercase = false;
                identityOptions.Password.RequireLowercase = false;
                identityOptions.User.RequireUniqueEmail = true;
            }
        };

        services.ConfigureMongoDbIdentity<User, Role, Guid>(mongoDbIdentityConfig);

        return services;
    }

    public static async Task UseDatabaseSeeder(this IServiceProvider serviceProvider)
    {
        await Data.DbSeeder.SeedAsync(serviceProvider);
    }
}
