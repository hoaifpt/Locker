using Locker.Backend.Application.Services;
using Microsoft.Extensions.DependencyInjection;

namespace Locker.Backend.Application;

public static class DependencyInjection
{
    public static IServiceCollection AddApplication(this IServiceCollection services)
    {
        services.AddScoped<LockerService>();
        services.AddScoped<AuthService>();
        services.AddScoped<UserService>();
        return services;
    }
}
