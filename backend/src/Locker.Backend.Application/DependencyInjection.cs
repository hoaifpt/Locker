using FluentValidation;
using Locker.Backend.Application.Mapping;
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
        services.AddSingleton<OrderMapper>();
        services.AddSingleton<WalletTransactionMapper>();

        // Validators
        services.AddValidatorsFromAssemblyContaining<AuthRequestValidator>();

        // MediatR & Pipeline Behaviors
        services.AddMediatR(cfg => 
        {
            cfg.RegisterServicesFromAssembly(typeof(DependencyInjection).Assembly);
            cfg.AddOpenBehavior(typeof(Behaviors.ValidationBehavior<,>));
        });

        // Services
        return services;
    }
}
