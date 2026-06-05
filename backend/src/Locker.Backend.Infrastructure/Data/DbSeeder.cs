using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Locker.Backend.Application.Interfaces;
using Locker.Backend.Domain.Entities;
using Locker.Backend.Domain.Enums;
using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace Locker.Backend.Infrastructure.Data;

public static class DbSeeder
{
    public static async Task SeedAsync(IServiceProvider serviceProvider)
    {
        using var scope = serviceProvider.CreateScope();
        var sp = scope.ServiceProvider;

        var config = sp.GetRequiredService<IConfiguration>();
        
        var roleManager = sp.GetRequiredService<RoleManager<Role>>();
        var userManager = sp.GetRequiredService<UserManager<User>>();
        var lockerRepo = sp.GetRequiredService<ILockerRepository>();
        var restaurantRepo = sp.GetRequiredService<IRestaurantRepository>();
        var menuItemRepo = sp.GetRequiredService<IMenuItemRepository>();
        var walletRepo = sp.GetRequiredService<IWalletTransactionRepository>();
        var foodOrderRepo = sp.GetRequiredService<IFoodOrderRepository>();
        var deliveryRepo = sp.GetRequiredService<IDeliveryRequestRepository>();
        var sendReceiveRepo = sp.GetRequiredService<ISendReceiveOrderRepository>();
        var packageRepo = sp.GetRequiredService<IPackageRepository>();
        var orderRepo = sp.GetRequiredService<IOrderRepository>();
        var paymentRepo = sp.GetRequiredService<IPaymentRepository>();
        var lockerEventRepo = sp.GetRequiredService<ILockerEventRepository>();
        var passwordHasher = sp.GetRequiredService<IPasswordHasher>();

        var defaultPassword = config["Seed:DefaultPassword"] ?? "Password123!";
        var adminUsername = config["Admin:Username"] ?? "admin";
        var adminEmail = config["Admin:Email"] ?? "admin@locker.com";
        var adminPassword = config["Admin:Password"] ?? defaultPassword;

        int customersCount = config.GetValue<int>("Seed:CustomersCount", 10);
        int shippersCount = config.GetValue<int>("Seed:ShippersCount", 5);
        int restaurantOwnersCount = config.GetValue<int>("Seed:RestaurantOwnersCount", 5);

        // 1. Roles
        var roles = new[] { "Admin", "Customer", "Shipper", "RestaurantOwner" };
        foreach (var r in roles)
        {
            if (!await roleManager.RoleExistsAsync(r))
            {
                await roleManager.CreateAsync(new Role { Name = r });
            }
        }

        // 2. Admin
        var adminUser = await userManager.FindByNameAsync(adminUsername);
        Guid adminId = adminUser?.Id ?? Guid.NewGuid();
        if (adminUser == null)
        {
            await CreateUserAsync(userManager, adminId, adminUsername, adminEmail, "0000000000", "Admin", adminPassword);
        }

        // 3. Sample Users
        var customerIds = new List<Guid>();
        for (int i = 1; i <= customersCount; i++)
        {
            var uName = $"customer{i}";
            var u = await userManager.FindByNameAsync(uName);
            var id = u?.Id ?? Guid.NewGuid();
            if (u == null) await CreateUserAsync(userManager, id, uName, $"{uName}@locker.com", $"09000000{i:D2}", "Customer", defaultPassword);
            customerIds.Add(id);
        }

        var shipperIds = new List<Guid>();
        for (int i = 1; i <= shippersCount; i++)
        {
            var uName = $"shipper{i}";
            var u = await userManager.FindByNameAsync(uName);
            var id = u?.Id ?? Guid.NewGuid();
            if (u == null) await CreateUserAsync(userManager, id, uName, $"{uName}@locker.com", $"08000000{i:D2}", "Shipper", defaultPassword);
            shipperIds.Add(id);
        }

        var ownerIds = new List<Guid>();
        for (int i = 1; i <= restaurantOwnersCount; i++)
        {
            var uName = $"owner{i}";
            var u = await userManager.FindByNameAsync(uName);
            var id = u?.Id ?? Guid.NewGuid();
            if (u == null) await CreateUserAsync(userManager, id, uName, $"{uName}@locker.com", $"07000000{i:D2}", "RestaurantOwner", defaultPassword);
            ownerIds.Add(id);
        }

        // 4. Lockers
        var existingLockers = await lockerRepo.GetAllAsync(default);
        var lockerIds = new List<Guid>();
        if (existingLockers.Count < 5)
        {
            for (int i = 1; i <= 5; i++)
            {
                var loc = new Locker.Backend.Domain.Entities.Locker
                {
                    Id = Guid.NewGuid(),
                    Name = $"Smart Locker #{i}",
                    Location = $"Location {i}, District 1, HCMC",
                    Latitude = 10.7780 + (i * 0.01),
                    Longitude = 106.7020 + (i * 0.01),
                    IsAutoLockEnabled = true,
                    Slots = new List<LockerSlot>
                    {
                        new LockerSlot { Index = 1, Size = "S", Status = LockerSlotStatus.Available },
                        new LockerSlot { Index = 2, Size = "M", Status = LockerSlotStatus.Available },
                        new LockerSlot { Index = 3, Size = "L", Status = LockerSlotStatus.Available }
                    }
                };
                await lockerRepo.CreateAsync(loc, default);
                lockerIds.Add(loc.Id);
            }
        }
        else
        {
            foreach (var l in existingLockers) lockerIds.Add(l.Id);
        }

        // 5. Packages (Pricing plans)
        var packageIds = new List<Guid>();
        var existingPackages = await packageRepo.GetAllAsync(default);
        if (existingPackages.Count == 0)
        {
            var pkgSmall = new Package { Id = Guid.NewGuid(), Name = "Small Locker (1h)", Size = "S", PricePerHour = 10000, Description = "Suitable for books, small bags" };
            var pkgMedium = new Package { Id = Guid.NewGuid(), Name = "Medium Locker (1h)", Size = "M", PricePerHour = 20000, Description = "Suitable for backpacks" };
            var pkgLarge = new Package { Id = Guid.NewGuid(), Name = "Large Locker (1h)", Size = "L", PricePerHour = 40000, Description = "Suitable for suitcases" };
            
            await packageRepo.CreateAsync(pkgSmall, default);
            await packageRepo.CreateAsync(pkgMedium, default);
            await packageRepo.CreateAsync(pkgLarge, default);

            packageIds.Add(pkgSmall.Id);
            packageIds.Add(pkgMedium.Id);
            packageIds.Add(pkgLarge.Id);
        }
        else
        {
            foreach (var p in existingPackages) packageIds.Add(p.Id);
        }

        // 6. Restaurants & Menu Items
        var existingRestaurants = await restaurantRepo.GetAllAsync(default);
        var restaurantIds = new List<Guid>();
        if (existingRestaurants.Count < restaurantOwnersCount)
        {
            for (int i = 0; i < restaurantOwnersCount; i++)
            {
                var res = new Restaurant
                {
                    Id = Guid.NewGuid(),
                    Name = $"Restaurant {i + 1}",
                    Description = $"Best food in town {i + 1}",
                    Address = $"Street {i + 1}",
                    ImageUrl = $"https://example.com/res{i + 1}.png",
                    Rating = 4.0 + (i * 0.1)
                };
                await restaurantRepo.CreateAsync(res, default);
                restaurantIds.Add(res.Id);

                // Add 5 menus each
                for (int m = 1; m <= 5; m++)
                {
                    var item = new MenuItem
                    {
                        Id = Guid.NewGuid(),
                        RestaurantId = res.Id,
                        Name = $"Dish {m} of Res {i + 1}",
                        Description = "Delicious dish",
                        Price = 50000 + (m * 10000),
                        Category = "Main",
                        ImageUrl = $"https://example.com/dish{m}.png"
                    };
                    await menuItemRepo.CreateAsync(item, default);
                }
            }
        }
        else
        {
            foreach (var r in existingRestaurants) restaurantIds.Add(r.Id);
        }

        // 7. Wallets Topup
        foreach (var cid in customerIds)
        {
            var txs = await walletRepo.GetByUserIdAsync(cid);
            if (txs.Count == 0)
            {
                var topup = new WalletTransaction
                {
                    Id = Guid.NewGuid(),
                    UserId = cid,
                    Amount = 1000000, // 1 mil
                    Type = TransactionType.TopUp,
                    Status = TransactionStatus.Completed,
                    Description = "Initial Topup for Testing"
                };
                await walletRepo.CreateAsync(topup, default);
            }
        }

        // 8. Core Business Data Sample
        // Only seed if empty
        if ((await foodOrderRepo.GetAllAsync(default)).Count == 0 && lockerIds.Count > 0 && restaurantIds.Count > 0 && customerIds.Count > 0)
        {
            var rand = new Random();
            
            // Standard Locker Orders (with Payments & Events)
            for (int i = 0; i < 5; i++)
            {
                var paymentId = Guid.NewGuid();
                var orderId = Guid.NewGuid();

                var payment = new Payment
                {
                    Id = paymentId,
                    BookingId = orderId, // Legacy link
                    UserId = customerIds[i % customerIds.Count],
                    Amount = 20000,
                    Status = PaymentStatus.Completed,
                    Method = "Wallet",
                    TransactionId = Guid.NewGuid().ToString(),
                    PaidAt = DateTime.UtcNow
                };
                await paymentRepo.CreateAsync(payment, default);

                var order = new Order
                {
                    Id = orderId,
                    UserId = customerIds[i % customerIds.Count],
                    LockerId = lockerIds[i % lockerIds.Count],
                    SlotIndex = 2,
                    PackageId = packageIds[1 % packageIds.Count],
                    Status = OrderStatus.Reserved,
                    CheckInTime = DateTime.UtcNow,
                    CheckOutTime = DateTime.UtcNow.AddHours(1),
                    DurationHours = 1,
                    BaseRate = 20000,
                    Subtotal = 20000,
                    TotalAmount = 20000,
                    PaymentId = paymentId,
                    PinHash = passwordHasher.Hash(defaultPassword),
                    MobileNumber = "0900000001",
                    ReservedAt = DateTime.UtcNow
                };
                await orderRepo.CreateAsync(order, default);

                var evt = new LockerEvent
                {
                    Id = Guid.NewGuid(),
                    LockerId = lockerIds[i % lockerIds.Count],
                    SlotIndex = 2,
                    UserId = customerIds[i % customerIds.Count],
                    EventType = "Open",
                    ReferenceId = orderId.ToString(),
                    Notes = "Opened by Customer for Reservation"
                };
                await lockerEventRepo.CreateAsync(evt, default);
            }

            // Generate some food orders
            for (int i = 0; i < 5; i++)
            {
                var menus = await menuItemRepo.GetByRestaurantIdAsync(restaurantIds[i % restaurantIds.Count]);
                if (menus.Count == 0) continue;

                var order = new FoodOrder
                {
                    Id = Guid.NewGuid(),
                    UserId = customerIds[i % customerIds.Count],
                    RestaurantId = restaurantIds[i % restaurantIds.Count],
                    LockerId = lockerIds[i % lockerIds.Count],
                    SlotIndex = 1,
                    Status = FoodOrderStatus.Pending,
                    TotalAmount = menus[0].Price,
                    Items = new List<FoodOrderItem>
                    {
                        new FoodOrderItem
                        {
                            MenuItemId = menus[0].Id,
                            Name = menus[0].Name,
                            Quantity = 1,
                            UnitPrice = menus[0].Price
                        }
                    }
                };
                await foodOrderRepo.CreateAsync(order, default);
            }

            // Generate some delivery requests
            if (shipperIds.Count > 0)
            {
                for (int i = 0; i < 5; i++)
                {
                    var req = new DeliveryRequest
                    {
                        Id = Guid.NewGuid(),
                        UserId = shipperIds[i % shipperIds.Count],
                        SenderName = "Express Delivery",
                        ReceiverPhone = "0900000001",
                        LockerId = lockerIds[i % lockerIds.Count],
                        SlotIndex = 2,
                        PackageSize = "M",
                        TrackingCode = $"TRK-{DateTime.UtcNow:yyyyMMdd}-{rand.Next(1000,9999)}",
                        Status = DeliveryStatus.Pending
                    };
                    await deliveryRepo.CreateAsync(req, default);
                }
            }

            // Generate some send/receive orders
            for (int i = 0; i < 5; i++)
            {
                var sr = new SendReceiveOrder
                {
                    Id = Guid.NewGuid(),
                    SenderId = customerIds[i % customerIds.Count],
                    ReceiverPhone = "0900000002",
                    LockerId = lockerIds[i % lockerIds.Count],
                    SlotIndex = 3,
                    PinHash = passwordHasher.Hash(defaultPassword),
                    Status = SendReceiveStatus.Initiated,
                    Notes = "Sample Send Receive"
                };
                await sendReceiveRepo.CreateAsync(sr, default);
            }
        }
    }

    private static async Task CreateUserAsync(UserManager<User> userManager, Guid id, string username, string email, string phone, string role, string password)
    {
        var existingUser = await userManager.FindByNameAsync(username);
        if (existingUser == null)
        {
            var user = new User
            {
                Id = id,
                UserName = username,
                Email = email,
                PhoneNumber = phone,
                FullName = username.ToUpper(),
                EmailConfirmed = true,
                PhoneNumberConfirmed = true
            };
            var result = await userManager.CreateAsync(user, password);
            if (result.Succeeded)
            {
                await userManager.AddToRoleAsync(user, role);
            }
        }
        else
        {
            bool needUpdate = false;
            if (!existingUser.EmailConfirmed || !existingUser.PhoneNumberConfirmed)
            {
                existingUser.EmailConfirmed = true;
                existingUser.PhoneNumberConfirmed = true;
                needUpdate = true;
            }
            if (!await userManager.CheckPasswordAsync(existingUser, password))
            {
                await userManager.RemovePasswordAsync(existingUser);
                await userManager.AddPasswordAsync(existingUser, password);
                needUpdate = true;
            }
            if (needUpdate)
            {
                await userManager.UpdateAsync(existingUser);
            }
        }
    }
}
