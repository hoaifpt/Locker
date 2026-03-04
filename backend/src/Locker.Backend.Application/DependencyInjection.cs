using FluentValidation;
using Locker.Backend.Application.Mapping;
using Locker.Backend.Application.Services;
using Locker.Backend.Application.Validators;
using Microsoft.Extensions.DependencyInjection;

namespace Locker.Backend.Application;

public static class DependencyInjection
{
    public static IServiceCollection AddApplication(this IServiceCollection services)
    {
        // Mappers
        services.AddSingleton<UserMapper>();
        services.AddSingleton<LockerSlotMapper>();
        services.AddSingleton<LockerMapper>();
        services.AddSingleton<PackageMapper>();
        services.AddSingleton<BookingMapper>();
        services.AddSingleton<PaymentMapper>();

        // Validators
        services.AddValidatorsFromAssemblyContaining<AuthRequestValidator>();

        // Services
        services.AddScoped<LockerService>();
        services.AddScoped<AuthService>();
        services.AddScoped<UserService>();
        services.AddScoped<PackageService>();
        services.AddScoped<BookingService>();
        services.AddScoped<PaymentService>();
        services.AddScoped<AdminService>();
        return services;
    }
}
