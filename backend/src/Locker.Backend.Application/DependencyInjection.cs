using FluentValidation;
using Locker.Backend.Application.Interfaces;
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
        services.AddScoped<IAuthService, AuthService>();
        services.AddScoped<UserService>();
        services.AddScoped<PackageService>();
        services.AddScoped<BookingService>();
        services.AddScoped<PaymentService>();
        services.AddScoped<AdminService>();

        // MVP Virtual Locker Services
        services.AddScoped<Interfaces.ITransactionService, TransactionService>();
        services.AddScoped<Interfaces.IQrCodeService, QrCodeService>();

        return services;
    }
}
