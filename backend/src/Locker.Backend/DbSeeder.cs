using Locker.Backend.Application.Interfaces;
using Locker.Backend.Domain.Entities;

namespace Locker.Backend;

public static class DbSeeder
{
    public static async Task SeedAsync(IServiceProvider services)
    {
        using var scope = services.CreateScope();
        var userRepo = scope.ServiceProvider.GetRequiredService<IUserRepository>();
        var passwordHasher = scope.ServiceProvider.GetRequiredService<IPasswordHasher>();

        var existing = await userRepo.GetByUsernameAsync("admin", CancellationToken.None);

        // Nếu admin tồn tại nhưng các field bị trống (do lỗi convention), tự động fix lại
        if (existing is not null)
        {
            bool needsUpdate = false;

            if (string.IsNullOrEmpty(existing.PasswordHash))
            {
                existing.PasswordHash = passwordHasher.Hash("Admin@123");
                needsUpdate = true;
            }

            if (string.IsNullOrEmpty(existing.Role))
            {
                existing.Role = "Admin";
                needsUpdate = true;
            }

            if (string.IsNullOrEmpty(existing.Email))
            {
                existing.Email = "admin@locker.com";
                needsUpdate = true;
            }

            if (!existing.IsActive)
            {
                existing.IsActive = true;
                needsUpdate = true;
            }

            if (!existing.IsEmailVerified)
            {
                existing.IsEmailVerified = true;
                existing.EmailVerificationToken = null;
                needsUpdate = true;
            }

            if (needsUpdate)
            {
                await userRepo.UpdateAsync(existing, CancellationToken.None);
                Console.WriteLine("[DbSeeder] Admin record was corrupted by convention mismatch, fixed successfully.");
            }

            return;
        }

        var admin = new User
        {
            Username = "admin",
            Email = "admin@locker.com",
            FullName = "Administrator",
            PasswordHash = passwordHasher.Hash("Admin@123"),
            Role = "Admin",
            IsActive = true,
            IsEmailVerified = true,
            EmailVerificationToken = null,
            CreatedAt = DateTime.UtcNow
        };

        await userRepo.CreateAsync(admin, CancellationToken.None);
        Console.WriteLine("[DbSeeder] Default admin created — username: admin / password: Admin@123");
    }
}
