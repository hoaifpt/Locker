using AutoMapper;
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
        services.AddAutoMapper(typeof(MappingProfile).Assembly);
        services.AddValidatorsFromAssemblyContaining<AuthRequestValidator>();

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
