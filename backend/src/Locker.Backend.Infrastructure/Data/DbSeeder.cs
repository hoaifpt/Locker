using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.Linq;
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
        var notificationRepo = sp.GetRequiredService<INotificationRepository>();
        var passwordHasher = sp.GetRequiredService<IPasswordHasher>();

        var defaultPassword = config["Seed:DefaultPassword"] ?? "Password123!";
        var adminUsername = config["Admin:Username"] ?? "admin";
        var adminEmail = config["Admin:Email"] ?? "admin@locker.com";
        var adminPassword = config["Admin:Password"] ?? defaultPassword;

        int customersCount = config.GetValue<int>("Seed:CustomersCount", 10);
        int shippersCount = config.GetValue<int>("Seed:ShippersCount", 5);
        int restaurantOwnersCount = config.GetValue<int>("Seed:RestaurantOwnersCount", 5);

        // 1. Roles
        var roles = new[] { "Admin", "User", "Shipper" };
        foreach (var r in roles)
        {
            if (!await roleManager.RoleExistsAsync(r))
            {
                await roleManager.CreateAsync(new Role { Name = r });
            }
        }

        // 2. Admin
        var adminUser = await userManager.FindByNameAsync(adminUsername)
                ?? await userManager.FindByEmailAsync(adminEmail);
        Guid adminId = adminUser?.Id ?? Guid.NewGuid();
        await CreateUserAsync(userManager, adminId, adminUsername, adminEmail, "0000000000", "Admin", "Administrator", adminPassword);

        // 3. Sample Users
        var customerIds = new List<Guid>();
        var customerNames = new[] { "Nguyễn Văn An", "Trần Thị Mai", "Lê Hoàng Tuấn", "Phạm Ngọc Bích", "Vũ Xuân Đạt" };
        var customerUsernames = new[] { "nguyenvanan", "tranthimai", "lehoangtuan", "phamngocbich", "vuxuandat" };
        var customerPhones = new[] { "0901234567", "0912345678", "0923456789", "0934567890", "0945678901" };

        for (int i = 0; i < customersCount; i++)
        {
            var idx = i % customerNames.Length;
            var uName = customerUsernames[idx] + (i >= customerNames.Length ? (i + 1).ToString() : "");
            var fullName = customerNames[idx];
            var phone = customerPhones[idx];
            var email = $"{uName}@gmail.com";

            var u = await userManager.FindByNameAsync(uName);
            var id = u?.Id ?? Guid.NewGuid();
            await CreateUserAsync(userManager, id, uName, email, phone, "User", fullName, defaultPassword);
            customerIds.Add(id);
        }

        var shipperIds = new List<Guid>();
        var shipperNames = new[] { "Đinh Văn Giao", "Lý Thanh Hải", "Bùi Trọng Hiếu", "Đỗ Văn Toàn" };
        var shipperUsernames = new[] { "dinhvangiao", "lythanhhai", "buitronghieu", "dovantoan" };
        var shipperPhones = new[] { "0812345678", "0823456789", "0834567890", "0845678901" };

        for (int i = 0; i < shippersCount; i++)
        {
            var idx = i % shipperNames.Length;
            var uName = shipperUsernames[idx] + (i >= shipperNames.Length ? (i + 1).ToString() : "");
            var fullName = shipperNames[idx];
            var phone = shipperPhones[idx];
            var email = $"{uName}@fastdelivery.com";

            var u = await userManager.FindByNameAsync(uName);
            var id = u?.Id ?? Guid.NewGuid();
            await CreateUserAsync(userManager, id, uName, email, phone, "Shipper", fullName, defaultPassword);
            shipperIds.Add(id);
        }

        // 4. Packages (Pricing plans)
        var packageIds = new List<Guid>();
        var existingPackages = await packageRepo.GetAllAsync(default);
        if (existingPackages.Count == 0)
        {
            var now = DateTime.UtcNow;
            var pkgSmall = new Package
            {
                Id = Guid.NewGuid(),
                Name = "Small Locker",
                Size = "S",
                PricePerHour = 10000,
                Description = "Suitable for books, small bags, documents",
                IsActive = true,
                IsDeleted = false
            };
            var pkgMedium = new Package
            {
                Id = Guid.NewGuid(),
                Name = "Medium Locker",
                Size = "M",
                PricePerHour = 20000,
                Description = "Suitable for backpacks, small luggage",
                IsActive = true,
                IsDeleted = false
            };
            var pkgLarge = new Package
            {
                Id = Guid.NewGuid(),
                Name = "Large Locker",
                Size = "L",
                PricePerHour = 40000,
                Description = "Suitable for large suitcases, multiple bags",
                IsActive = true,
                IsDeleted = false
            };

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

        // 5. Lockers
        var existingLockers = await lockerRepo.GetAllAsync(default);
        var lockerIds = new List<Guid>();
        if (existingLockers.Count < 5)
        {
            var now = DateTime.UtcNow;
            for (int i = 1; i <= 5; i++)
            {
                var loc = new Locker.Backend.Domain.Entities.Locker
                {
                    Id = Guid.NewGuid(),
                    Name = $"Smart Locker #{i}",
                    Location = $"{i} Le Loi Street, District 1, Ho Chi Minh City",
                    Latitude = 10.7780 + (i * 0.01),
                    Longitude = 106.7020 + (i * 0.01),
                    IsAutoLockEnabled = true,
                    IsIntrusionAlertEnabled = true,
                    IsDeleted = false,
                    Slots = new List<LockerSlot>
                    {
                        new LockerSlot { Index = 1, Size = "S", Status = LockerSlotStatus.Available, SensorState = "Closed" },
                        new LockerSlot { Index = 2, Size = "M", Status = LockerSlotStatus.Available, SensorState = "Closed" },
                        new LockerSlot { Index = 3, Size = "L", Status = LockerSlotStatus.Available, SensorState = "Closed" },
                        new LockerSlot { Index = 4, Size = "S", Status = LockerSlotStatus.Available, SensorState = "Closed" },
                        new LockerSlot { Index = 5, Size = "M", Status = LockerSlotStatus.Available, SensorState = "Closed" },
                        new LockerSlot { Index = 6, Size = "L", Status = LockerSlotStatus.Available, SensorState = "Closed" }
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

        // 6. Restaurants & Menu Items
        var existingRestaurants = await restaurantRepo.GetAllAsync(default);
        var restaurantIds = new List<Guid>();
        if (existingRestaurants.Count < restaurantOwnersCount)
        {
            var now = DateTime.UtcNow;
            var restaurantNames = new[]
            {
                ("Pho Saigon", "Famous Vietnamese pho restaurant with rich bone broth", "123 Nguyen Hue, District 1, HCMC", 4.5),
                ("Bun Cha Huong Lien", "Authentic Hanoi-style bun cha", "45 Le Lai, District 1, HCMC", 4.3),
                ("Com Tam Oi Den", "Best broken rice in the city", "78 Pasteur, District 1, HCMC", 4.2),
                ("Banh Mi Thuong", "Fresh and crispy Vietnamese sandwiches", "15 Dong Khoi, District 1, HCMC", 4.6),
                ("My Ga Ro Ti", "Delicious clay pot chicken rice", "99 Hai Ba Trung, District 1, HCMC", 4.4)
            };
            var categories = new[] { "Soup", "Grilled", "Rice", "Sandwich", "Clay Pot" };
            var menuItemNames = new[]
            {
                new[] { "Pho Bo", "Pho Ga", "Banh Da Cua", "Huyet Bo Vien", "Bun Rieu Cua" },
                new[] { "Bun Cha", "Bun Nem Nuong", "Bun Thit Nuong", "Bun Dau Mam Tom", "Bun Cha Ca" },
                new[] { "Com Tam Suon Bi", "Com Tam Bo Kho", "Com Tam Ga Xoi", "Com Tam Ca Tim", "Com Tam Thit Kho" },
                new[] { "Banh Mi Bo", "Banh Mi Ga", "Banh Mi Cha Ca", "Banh Mi Xiu Mai", "Banh Mi Dac Biet" },
                new[] { "Ga Kho Tau", "Ga Xoi Muc", "Ca Kho To", "Suon Kho Tieu", "Dau Hu Kho Tieu" }
            };

            for (int i = 0; i < restaurantOwnersCount; i++)
            {
                var (name, desc, addr, rating) = restaurantNames[i];
                var res = new Restaurant
                {
                    Id = Guid.NewGuid(),
                    Name = name,
                    Description = desc,
                    Address = addr,
                    ImageUrl = $"https://example.com/restaurants/res{i + 1}.png",
                    IsActive = true,
                    IsDeleted = false,
                    Rating = rating,
                    CreatedAt = now,
                    UpdatedAt = now
                };
                await restaurantRepo.CreateAsync(res, default);
                restaurantIds.Add(res.Id);

                for (int m = 0; m < 5; m++)
                {
                    var item = new MenuItem
                    {
                        Id = Guid.NewGuid(),
                        RestaurantId = res.Id,
                        Name = menuItemNames[i][m],
                        Description = $"Delicious {menuItemNames[i][m]} - authentic taste",
                        Price = 35000 + (m * 15000),
                        Category = categories[i],
                        ImageUrl = $"https://example.com/dishes/dish{i + 1}_{m + 1}.png",
                        IsAvailable = true,
                        IsDeleted = false
                    };
                    await menuItemRepo.CreateAsync(item, default);
                }
            }
        }
        else
        {
            foreach (var r in existingRestaurants) restaurantIds.Add(r.Id);
        }

        // 7. Wallets Topup for customers
        foreach (var cid in customerIds)
        {
            var txs = await walletRepo.GetByUserIdAsync(cid);
            if (txs.Count == 0)
            {
                var now = DateTime.UtcNow;
                var topup = new WalletTransaction
                {
                    Id = Guid.NewGuid(),
                    UserId = cid,
                    Amount = 1000000,
                    Type = TransactionType.TopUp,
                    Status = TransactionStatus.Completed,
                    Description = "Initial Topup for Testing",
                    CreatedAt = now,
                    UpdatedAt = now
                };
                await walletRepo.CreateAsync(topup, default);
            }
        }

        // 8. Core Business Data Sample - Only seed if empty
        if ((await foodOrderRepo.GetAllAsync(default)).Count == 0 && lockerIds.Count > 0 && restaurantIds.Count > 0 && customerIds.Count > 0)
        {
            var now = DateTime.UtcNow;

            // 8a. Standard Locker Orders (with Payments & Events)
            for (int i = 0; i < 5; i++)
            {
                var paymentId = Guid.NewGuid();
                var orderId = Guid.NewGuid();
                var customerIdx = i % customerIds.Count;
                var lockerIdx = i % lockerIds.Count;
                var slotIdx = (i % 6) + 1; // Slots 1-6
                var packageIdx = i % packageIds.Count;
                var phoneNum = $"090{i + 1:D8}";
                var checkIn = now.AddHours(-1);
                var checkOut = checkIn.AddHours(1);

                var payment = new Payment
                {
                    Id = paymentId,
                    BookingId = orderId,
                    UserId = customerIds[customerIdx],
                    Amount = 20000,
                    Status = PaymentStatus.Completed,
                    Method = "Wallet",
                    TransactionId = Guid.NewGuid().ToString(),
                    PaidAt = now.AddMinutes(-30),
                    CreatedAt = now.AddMinutes(-45)
                };
                await paymentRepo.CreateAsync(payment, default);

                var order = new Order
                {
                    Id = orderId,
                    UserId = customerIds[customerIdx],
                    LockerId = lockerIds[lockerIdx],
                    SlotIndex = slotIdx,
                    PackageId = packageIds[packageIdx],
                    Status = OrderStatus.Reserved,
                    CheckInTime = checkIn,
                    CheckOutTime = checkOut,
                    DurationHours = 1,
                    BaseRate = 20000,
                    Subtotal = 20000,
                    Taxes = 0,
                    Discount = 0,
                    TotalAmount = 20000,
                    PaymentId = paymentId,
                    PinHash = passwordHasher.Hash(defaultPassword),
                    MobileNumber = phoneNum,
                    ReservedAt = now.AddMinutes(-30),
                    PaidAt = now.AddMinutes(-30),
                    CreatedAt = now.AddHours(-1)
                };
                await orderRepo.CreateAsync(order, default);

                var evt = new LockerEvent
                {
                    Id = Guid.NewGuid(),
                    LockerId = lockerIds[lockerIdx],
                    SlotIndex = slotIdx,
                    UserId = customerIds[customerIdx],
                    EventType = "OrderReserved",
                    ReferenceId = orderId.ToString(),
                    Notes = "Order reserved via app",
                    CreatedAt = now.AddMinutes(-30)
                };
                await lockerEventRepo.CreateAsync(evt, default);
            }

            // 8b. Generate Food Orders
            for (int i = 0; i < 5; i++)
            {
                var menus = await menuItemRepo.GetByRestaurantIdAsync(restaurantIds[i % restaurantIds.Count]);
                if (menus.Count == 0) continue;

                var customerIdx = i % customerIds.Count;
                var lockerIdx = i % lockerIds.Count;
                var slotIdx = ((i + 3) % 6) + 1;
                var now2 = now.AddHours(-i);
                var orderId = Guid.NewGuid();
                var paymentId = Guid.NewGuid();

                var payment = new Payment
                {
                    Id = paymentId,
                    BookingId = orderId,
                    UserId = customerIds[customerIdx],
                    Amount = menus[0].Price,
                    Status = i < 2 ? PaymentStatus.Completed : PaymentStatus.Pending,
                    Method = "Wallet",
                    TransactionId = i < 2 ? Guid.NewGuid().ToString() : null,
                    PaidAt = i < 2 ? now2.AddMinutes(-15) : null,
                    CreatedAt = now2
                };
                await paymentRepo.CreateAsync(payment, default);

                decimal total = menus[0].Price;
                var items = new List<FoodOrderItem>();
                foreach (var menu in menus.Take(2))
                {
                    total += menu.Price;
                    items.Add(new FoodOrderItem
                    {
                        MenuItemId = menu.Id,
                        Name = menu.Name,
                        Quantity = 1,
                        UnitPrice = menu.Price
                    });
                }

                var order = new FoodOrder
                {
                    Id = orderId,
                    UserId = customerIds[customerIdx],
                    RestaurantId = restaurantIds[i % restaurantIds.Count],
                    LockerId = lockerIds[lockerIdx],
                    SlotIndex = slotIdx,
                    Items = items,
                    TotalAmount = total,
                    PaymentId = paymentId,
                    Status = i < 2 ? FoodOrderStatus.Completed : FoodOrderStatus.Pending,
                    DeliveryNotes = i < 2 ? null : "Please add extra sauce",
                    CreatedAt = now2
                };
                await foodOrderRepo.CreateAsync(order, default);
            }

            // 8c. Generate Delivery Requests
            if (shipperIds.Count > 0)
            {
                for (int i = 0; i < 5; i++)
                {
                    var shipperIdx = i % shipperIds.Count;
                    var lockerIdx = i % lockerIds.Count;
                    var slotIdx = ((i + 1) % 6) + 1;
                    var now2 = now.AddMinutes(-i * 15);
                    var sizes = new[] { "Small", "Medium", "Large" };

                    var req = new DeliveryRequest
                    {
                        Id = Guid.NewGuid(),
                        UserId = shipperIds[shipperIdx],
                        SenderName = $"Shipper {shipperIdx + 1}",
                        ReceiverPhone = $"090{1000 + i:D8}",
                        LockerId = lockerIds[lockerIdx],
                        SlotIndex = slotIdx,
                        PackageSize = sizes[i % sizes.Length],
                        TrackingCode = $"TRK-{now:yyyyMMdd}-{1000 + i}",
                        Status = i < 3 ? DeliveryStatus.Completed : DeliveryStatus.Pending,
                        CreatedAt = now2
                    };
                    await deliveryRepo.CreateAsync(req, default);

                    var evt = new LockerEvent
                    {
                        Id = Guid.NewGuid(),
                        LockerId = lockerIds[lockerIdx],
                        SlotIndex = slotIdx,
                        UserId = shipperIds[shipperIdx],
                        EventType = "DeliveryCreated",
                        ReferenceId = req.Id.ToString(),
                        Notes = req.TrackingCode,
                        CreatedAt = now2
                    };
                    await lockerEventRepo.CreateAsync(evt, default);
                }
            }

            // 8d. Generate Send/Receive Orders
            for (int i = 0; i < 5; i++)
            {
                var customerIdx = i % customerIds.Count;
                var lockerIdx = i % lockerIds.Count;
                var slotIdx = ((i + 2) % 6) + 1;
                var now2 = now.AddMinutes(-i * 20);
                var statuses = new[] {
                    SendReceiveStatus.Received,
                    SendReceiveStatus.Deposited,
                    SendReceiveStatus.Deposited,
                    SendReceiveStatus.Initiated,
                    SendReceiveStatus.Initiated
                };

                var sr = new SendReceiveOrder
                {
                    Id = Guid.NewGuid(),
                    SenderId = customerIds[customerIdx],
                    ReceiverPhone = $"090{2000 + i:D8}",
                    LockerId = lockerIds[lockerIdx],
                    SlotIndex = slotIdx,
                    PinHash = passwordHasher.Hash(defaultPassword),
                    Status = statuses[i],
                    Notes = $"Sample send/receive order #{i + 1}",
                    DepositedAt = i < 3 ? now2.AddMinutes(10) : null,
                    ReceivedAt = i < 1 ? now2.AddMinutes(30) : null,
                    CreatedAt = now2
                };
                await sendReceiveRepo.CreateAsync(sr, default);
            }

            // 8e. Generate Notifications for customers
            var notificationTitles = new[]
            {
                "Welcome to Locker App!",
                "Your order has been confirmed",
                "Delivery arrived at locker",
                "Package ready for pickup",
                "Reminder: Locker booking expires soon"
            };
            var notificationMessages = new[]
            {
                "Thank you for registering. Start using our locker services today!",
                "Your locker reservation has been confirmed. Please proceed to payment.",
                "Your delivery has been dropped off at the locker. Use your PIN to open.",
                "Your package is ready for pickup at the locker.",
                "Your locker booking will expire in 30 minutes. Don't forget your items."
            };

            for (int i = 0; i < customerIds.Count && i < notificationTitles.Length; i++)
            {
                var notif = new Notification
                {
                    Id = Guid.NewGuid(),
                    UserId = customerIds[i],
                    Title = notificationTitles[i],
                    Message = notificationMessages[i],
                    IsRead = i % 2 == 0,
                    CreatedAt = now.AddMinutes(-i * 5)
                };
                await notificationRepo.CreateAsync(notif, default);
            }
        }
    }

    private static async Task CreateUserAsync(
        UserManager<User> userManager,
        Guid id,
        string username,
        string email,
        string phone,
        string role,
        string fullName,
        string password)
    {
        var existingUser = await userManager.FindByNameAsync(username);

        if (existingUser == null)
        {
            existingUser = await userManager.FindByEmailAsync(email);
        }

        if (existingUser == null)
        {
            var user = new User
            {
                Id = id,
                UserName = username,
                Email = email,
                PhoneNumber = phone,
                FullName = fullName,
                EmailConfirmed = true,
                PhoneNumberConfirmed = true,
                IsActive = true,
                CreatedAt = DateTime.UtcNow
            };

            var result = await userManager.CreateAsync(user, password);

            if (result.Succeeded)
            {
                await userManager.AddToRoleAsync(user, role);
            }
            else
            {
                var errors = string.Join(", ", result.Errors.Select(e => e.Description));
                throw new Exception($"Failed to create user {username}: {errors}");
            }
        }
        else
        {
            if (!await userManager.IsInRoleAsync(existingUser, role))
            {
                await userManager.AddToRoleAsync(existingUser, role);
            }

            bool needUpdate = false;

            if (!existingUser.EmailConfirmed)
            {
                existingUser.EmailConfirmed = true;
                needUpdate = true;
            }

            if (!existingUser.PhoneNumberConfirmed)
            {
                existingUser.PhoneNumberConfirmed = true;
                needUpdate = true;
            }

            if (needUpdate)
            {
                await userManager.UpdateAsync(existingUser);
            }
        }
    }
}
