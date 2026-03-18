using Locker.Backend.Application.Interfaces;
using Locker.Backend.Domain.Entities;
using Locker.Backend.Domain.Enums;

namespace Locker.Backend;

public static class DbSeeder
{
    private static readonly CancellationToken _cts = CancellationToken.None;

    public static async Task SeedAsync(IServiceProvider services)
    {
        using var scope = services.CreateScope();
        var userRepo = scope.ServiceProvider.GetRequiredService<IUserRepository>();
        var lockerRepo = scope.ServiceProvider.GetRequiredService<ILockerRepository>();
        var packageRepo = scope.ServiceProvider.GetRequiredService<IPackageRepository>();
        var orderRepo = scope.ServiceProvider.GetRequiredService<IOrderRepository>();
        var paymentRepo = scope.ServiceProvider.GetRequiredService<IPaymentRepository>();
        var bookingRepo = scope.ServiceProvider.GetRequiredService<IBookingRepository>();
        var passwordHasher = scope.ServiceProvider.GetRequiredService<IPasswordHasher>();

        Console.WriteLine("\n========== DATABASE SEEDING START ==========\n");

        try
        {
            await SeedUsersAsync(userRepo, passwordHasher);
            await SeedPackagesAsync(packageRepo);
            await SeedLockersAsync(lockerRepo, packageRepo);
            await SeedOrdersAndPaymentsAsync(userRepo, lockerRepo, packageRepo, orderRepo, paymentRepo);
            await SeedBookingsAsync(bookingRepo, lockerRepo, packageRepo);

            Console.WriteLine("\n========== DATABASE SEEDING COMPLETE ==========\n");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"\n❌ [DbSeeder] Error: {ex.Message}\n");
            throw;
        }
    }

    #region Users Seeding

    private static async Task SeedUsersAsync(IUserRepository userRepo, IPasswordHasher passwordHasher)
    {
        Console.WriteLine("📝 Seeding Users...");

        var existingAdmin = await userRepo.GetByUsernameAsync("admin", _cts);
        if (existingAdmin != null)
        {
            Console.WriteLine("   ✓ Admin already exists, skipping users seed");
            return;
        }

        var users = new[]
        {
            new User
            {
                Username = "admin",
                Email = "admin@locker.com",
                FullName = "Administrator",
                PhoneNumber = "+84901234567",
                PasswordHash = passwordHasher.Hash("Admin@123"),
                Role = "Admin",
                IsActive = true,
                IsEmailVerified = true,
                CreatedAt = DateTime.UtcNow.AddDays(-30)
            },
            new User
            {
                Username = "john_doe",
                Email = "john.doe@example.com",
                FullName = "John Doe",
                PhoneNumber = "+84912345678",
                PasswordHash = passwordHasher.Hash("John@1234"),
                Role = "User",
                IsActive = true,
                IsEmailVerified = true,
                CreatedAt = DateTime.UtcNow.AddDays(-20)
            },
            new User
            {
                Username = "jane_smith",
                Email = "jane.smith@example.com",
                FullName = "Jane Smith",
                PhoneNumber = "+84923456789",
                PasswordHash = passwordHasher.Hash("Jane@1234"),
                Role = "User",
                IsActive = true,
                IsEmailVerified = true,
                CreatedAt = DateTime.UtcNow.AddDays(-15)
            },
            new User
            {
                Username = "mike_wilson",
                Email = "mike.wilson@example.com",
                FullName = "Mike Wilson",
                PhoneNumber = "+84934567890",
                PasswordHash = passwordHasher.Hash("Mike@1234"),
                Role = "User",
                IsActive = true,
                IsEmailVerified = true,
                CreatedAt = DateTime.UtcNow.AddDays(-10)
            },
            new User
            {
                Username = "alice_brown",
                Email = "alice.brown@example.com",
                FullName = "Alice Brown",
                PhoneNumber = "+84945678901",
                PasswordHash = passwordHasher.Hash("Alice@1234"),
                Role = "User",
                IsActive = true,
                IsEmailVerified = true,
                CreatedAt = DateTime.UtcNow.AddDays(-5)
            }
        };

        foreach (var user in users)
        {
            await userRepo.CreateAsync(user, _cts);
        }

        Console.WriteLine($"   ✓ {users.Length} users created");
    }

    #endregion

    #region Packages Seeding

    private static async Task SeedPackagesAsync(IPackageRepository packageRepo)
    {
        Console.WriteLine("📦 Seeding Packages...");

        var existingPackages = await packageRepo.GetAllAsync(_cts);
        if (existingPackages.Count > 0)
        {
            Console.WriteLine("   ✓ Packages already exist, skipping");
            return;
        }

        var packages = new[]
        {
            new Package
            {
                Name = "Small Box",
                Size = "S",
                Description = "Gói nhỏ cho các vật dụng cá nhân (20x20x20cm)",
                PricePerHour = 5000m, // 5000 VND/hour
                IsActive = true
            },
            new Package
            {
                Name = "Medium Box",
                Size = "M",
                Description = "Gói vừa cho hàng hóa tiêu chuẩn (30x30x30cm)",
                PricePerHour = 10000m, // 10000 VND/hour
                IsActive = true
            },
            new Package
            {
                Name = "Large Box",
                Size = "L",
                Description = "Gói lớn cho các gói hàng cỡ lớn (40x40x40cm)",
                PricePerHour = 15000m, // 15000 VND/hour
                IsActive = true
            },
            new Package
            {
                Name = "Extra Large",
                Size = "XL",
                Description = "Gói siêu lớn cho các gói hàng quá khổ (50x50x50cm)",
                PricePerHour = 20000m, // 20000 VND/hour
                IsActive = true
            }
        };

        foreach (var package in packages)
        {
            await packageRepo.CreateAsync(package, _cts);
        }

        Console.WriteLine($"   ✓ {packages.Length} packages created");
    }

    #endregion

    #region Lockers Seeding

    private static async Task SeedLockersAsync(ILockerRepository lockerRepo, IPackageRepository packageRepo)
    {
        Console.WriteLine("🔐 Seeding Lockers and Slots...");

        var existingLockers = await lockerRepo.GetAllAsync(_cts);
        if (existingLockers.Count > 0)
        {
            Console.WriteLine("   ✓ Lockers already exist, skipping");
            return;
        }

        var packages = await packageRepo.GetAllAsync(_cts);
        if (packages.Count == 0)
        {
            Console.WriteLine("   ⚠ No packages found, skipping lockers seed");
            return;
        }

        var lockers = new[]
        {
            new Locker
            {
                Name = "Locker Station A - Thao Dien",
                Location = "Thao Dien, District 2, HCMC - Tầng 1 Tòa nhà Diamond Plaza",
                Latitude = 10.8018,
                Longitude = 106.7643,
                Slots = GenerateSlots(packages, 12)
            },
            new Locker
            {
                Name = "Locker Station B - Binh Thanh",
                Location = "Binh Thanh, District 1, HCMC - Tầng G Tòa nhà Landmark 81",
                Latitude = 10.7975,
                Longitude = 106.7034,
                Slots = GenerateSlots(packages, 15)
            },
            new Locker
            {
                Name = "Locker Station C - Tan Binh",
                Location = "Tan Binh, District 3, HCMC - Ga tàu điện ngầm Tan Binh",
                Latitude = 10.8080,
                Longitude = 106.6845,
                Slots = GenerateSlots(packages, 20)
            },
            new Locker
            {
                Name = "Locker Station D - Ben Thanh",
                Location = "District 1, HCMC - Chợ Bến Thành, Khu vực kinh doanh trung tâm",
                Latitude = 10.7725,
                Longitude = 106.6976,
                Slots = GenerateSlots(packages, 10)
            }
        };

        foreach (var locker in lockers)
        {
            await lockerRepo.CreateAsync(locker, _cts);
        }

        Console.WriteLine($"   ✓ {lockers.Length} lockers with {lockers.Sum(l => l.Slots.Count)} slots created");
    }

    private static List<LockerSlot> GenerateSlots(List<Package> packages, int slotCount)
    {
        var slots = new List<LockerSlot>();
        for (int i = 0; i < slotCount; i++)
        {
            var package = packages[i % packages.Count];
            slots.Add(new LockerSlot
            {
                Index = i,
                PackageId = package.Id,
                Status = LockerSlotStatus.Available,
                BookingId = null,
                CreatedAt = DateTime.UtcNow
            });
        }
        return slots;
    }

    #endregion

    #region Orders and Payments Seeding

    private static async Task SeedOrdersAndPaymentsAsync(
        IUserRepository userRepo,
        ILockerRepository lockerRepo,
        IPackageRepository packageRepo,
        IOrderRepository orderRepo,
        IPaymentRepository paymentRepo)
    {
        Console.WriteLine("📋 Seeding Orders and Payments...");

        var existingOrders = await orderRepo.GetAllAsync(_cts);
        if (existingOrders.Count > 0)
        {
            Console.WriteLine("   ✓ Orders already exist, skipping");
            return;
        }

        var users = await userRepo.GetAllAsync(_cts);
        var lockers = await lockerRepo.GetAllAsync(_cts);
        var packages = await packageRepo.GetAllAsync(_cts);

        if (users.Count == 0 || lockers.Count == 0 || packages.Count == 0)
        {
            Console.WriteLine("   ⚠ Missing users, lockers, or packages");
            return;
        }

        var orders = new List<Order>();
        var payments = new List<Payment>();

        // Order 1: Completed Order
        var user1 = users[1]; // john_doe
        var locker1 = lockers[0];
        var pkg1 = packages[0]; // Small
        var order1 = new Order
        {
            UserId = user1.Id,
            LockerId = locker1.Id,
            SlotIndex = 0,
            PackageId = pkg1.Id,
            MobileNumber = user1.PhoneNumber ?? "+84912345678",
            Status = OrderStatus.Completed,
            CheckInTime = DateTime.UtcNow.AddDays(-3),
            CheckOutTime = DateTime.UtcNow.AddDays(-3).AddHours(2),
            DurationHours = 2,
            BaseRate = pkg1.PricePerHour,
            Subtotal = pkg1.PricePerHour * 2,
            Taxes = (pkg1.PricePerHour * 2) * 0.1m,
            Discount = 0,
            TotalAmount = (pkg1.PricePerHour * 2) * 1.1m,
            PinHash = "hashed_pin_1234",
            CreatedAt = DateTime.UtcNow.AddDays(-3),
            ReservedAt = DateTime.UtcNow.AddDays(-3).AddMinutes(5),
            PaidAt = DateTime.UtcNow.AddDays(-3).AddMinutes(10),
            StartedAt = DateTime.UtcNow.AddDays(-3).AddMinutes(30),
            CompletedAt = DateTime.UtcNow.AddDays(-3).AddHours(2).AddMinutes(5)
        };

        var payment1 = new Payment
        {
            BookingId = order1.Id,
            UserId = user1.Id,
            Amount = order1.TotalAmount,
            Status = PaymentStatus.Completed,
            Method = "card",
            TransactionId = "TXN_001_" + Guid.NewGuid().ToString().Substring(0, 8),
            CreatedAt = DateTime.UtcNow.AddDays(-3).AddMinutes(10),
            PaidAt = DateTime.UtcNow.AddDays(-3).AddMinutes(15)
        };

        order1.PaymentId = payment1.Id;
        orders.Add(order1);
        payments.Add(payment1);

        // Order 2: Active Order
        var user2 = users[2]; // jane_smith
        var locker2 = lockers[1];
        var pkg2 = packages[1]; // Medium
        var order2 = new Order
        {
            UserId = user2.Id,
            LockerId = locker2.Id,
            SlotIndex = 1,
            PackageId = pkg2.Id,
            MobileNumber = user2.PhoneNumber ?? "+84923456789",
            Status = OrderStatus.Active,
            CheckInTime = DateTime.UtcNow.AddHours(-1),
            CheckOutTime = DateTime.UtcNow.AddHours(4),
            DurationHours = 5,
            BaseRate = pkg2.PricePerHour,
            Subtotal = pkg2.PricePerHour * 5,
            Taxes = (pkg2.PricePerHour * 5) * 0.1m,
            Discount = 0,
            TotalAmount = (pkg2.PricePerHour * 5) * 1.1m,
            PinHash = "hashed_pin_5678",
            CreatedAt = DateTime.UtcNow.AddHours(-2),
            ReservedAt = DateTime.UtcNow.AddHours(-2).AddMinutes(5),
            PaidAt = DateTime.UtcNow.AddHours(-2).AddMinutes(10),
            StartedAt = DateTime.UtcNow.AddHours(-1)
        };

        var payment2 = new Payment
        {
            BookingId = order2.Id,
            UserId = user2.Id,
            Amount = order2.TotalAmount,
            Status = PaymentStatus.Completed,
            Method = "momo",
            TransactionId = "TXN_002_" + Guid.NewGuid().ToString().Substring(0, 8),
            CreatedAt = DateTime.UtcNow.AddHours(-2).AddMinutes(10),
            PaidAt = DateTime.UtcNow.AddHours(-2).AddMinutes(15)
        };

        order2.PaymentId = payment2.Id;
        orders.Add(order2);
        payments.Add(payment2);

        // Order 3: Reserved Order (Paid, waiting activation)
        var user3 = users[3]; // mike_wilson
        var locker3 = lockers[0];
        var pkg3 = packages[2]; // Large
        var order3 = new Order
        {
            UserId = user3.Id,
            LockerId = locker3.Id,
            SlotIndex = 5,
            PackageId = pkg3.Id,
            MobileNumber = user3.PhoneNumber ?? "+84934567890",
            Status = OrderStatus.Reserved,
            CheckInTime = DateTime.UtcNow.AddHours(2),
            CheckOutTime = DateTime.UtcNow.AddHours(26),
            DurationHours = 24,
            BaseRate = pkg3.PricePerHour,
            Subtotal = pkg3.PricePerHour * 24,
            Taxes = (pkg3.PricePerHour * 24) * 0.1m,
            Discount = 0,
            TotalAmount = (pkg3.PricePerHour * 24) * 1.1m,
            PinHash = "hashed_pin_9999",
            CreatedAt = DateTime.UtcNow.AddHours(-1),
            ReservedAt = DateTime.UtcNow.AddMinutes(-50),
            PaidAt = DateTime.UtcNow.AddMinutes(-45)
        };

        var payment3 = new Payment
        {
            BookingId = order3.Id,
            UserId = user3.Id,
            Amount = order3.TotalAmount,
            Status = PaymentStatus.Completed,
            Method = "vnpay",
            TransactionId = "TXN_003_" + Guid.NewGuid().ToString().Substring(0, 8),
            CreatedAt = DateTime.UtcNow.AddHours(-1),
            PaidAt = DateTime.UtcNow.AddMinutes(-45)
        };

        order3.PaymentId = payment3.Id;
        orders.Add(order3);
        payments.Add(payment3);

        // Order 4: Initiated Order (pending payment)
        var user4 = users[4]; // alice_brown
        var locker4 = lockers[2];
        var pkg4 = packages[1]; // Medium
        var order4 = new Order
        {
            UserId = user4.Id,
            LockerId = locker4.Id,
            SlotIndex = 10,
            PackageId = pkg4.Id,
            MobileNumber = user4.PhoneNumber ?? "+84945678901",
            Status = OrderStatus.Initiated,
            CheckInTime = DateTime.UtcNow.AddHours(1),
            CheckOutTime = DateTime.UtcNow.AddHours(4),
            DurationHours = 3,
            BaseRate = pkg4.PricePerHour,
            Subtotal = pkg4.PricePerHour * 3,
            Taxes = (pkg4.PricePerHour * 3) * 0.1m,
            Discount = 0,
            TotalAmount = (pkg4.PricePerHour * 3) * 1.1m,
            CreatedAt = DateTime.UtcNow.AddMinutes(-5),
            Notes = "Order pending payment"
        };

        orders.Add(order4);

        // Order 5: Cancelled Order
        var user5 = users[1]; // john_doe
        var locker5 = lockers[3];
        var pkg5 = packages[0]; // Small
        var order5 = new Order
        {
            UserId = user5.Id,
            LockerId = locker5.Id,
            SlotIndex = 3,
            PackageId = pkg5.Id,
            MobileNumber = user5.PhoneNumber ?? "+84912345678",
            Status = OrderStatus.Cancelled,
            CheckInTime = DateTime.UtcNow.AddDays(-2),
            CheckOutTime = DateTime.UtcNow.AddDays(-2).AddHours(3),
            DurationHours = 3,
            BaseRate = pkg5.PricePerHour,
            Subtotal = pkg5.PricePerHour * 3,
            Taxes = (pkg5.PricePerHour * 3) * 0.1m,
            Discount = 0,
            TotalAmount = (pkg5.PricePerHour * 3) * 1.1m,
            CreatedAt = DateTime.UtcNow.AddDays(-2),
            ReservedAt = DateTime.UtcNow.AddDays(-2).AddMinutes(5),
            CancelledAt = DateTime.UtcNow.AddDays(-2).AddMinutes(15),
            CancellationReason = "User changed their mind"
        };

        orders.Add(order5);

        // Order 6: Paid Order (waiting activation)
        var user6 = users[2]; // jane_smith
        var locker6 = lockers[1];
        var pkg6 = packages[3]; // XL
        var order6 = new Order
        {
            UserId = user6.Id,
            LockerId = locker6.Id,
            SlotIndex = 7,
            PackageId = pkg6.Id,
            MobileNumber = user6.PhoneNumber ?? "+84923456789",
            Status = OrderStatus.Paid,
            CheckInTime = DateTime.UtcNow.AddMinutes(30),
            CheckOutTime = DateTime.UtcNow.AddHours(6).AddMinutes(30),
            DurationHours = 6,
            BaseRate = pkg6.PricePerHour,
            Subtotal = pkg6.PricePerHour * 6,
            Taxes = (pkg6.PricePerHour * 6) * 0.1m,
            Discount = 0,
            TotalAmount = (pkg6.PricePerHour * 6) * 1.1m,
            PinHash = "hashed_pin_6789",
            CreatedAt = DateTime.UtcNow.AddMinutes(-10),
            ReservedAt = DateTime.UtcNow.AddMinutes(-9),
            PaidAt = DateTime.UtcNow.AddMinutes(-5)
        };

        var payment6 = new Payment
        {
            BookingId = order6.Id,
            UserId = user6.Id,
            Amount = order6.TotalAmount,
            Status = PaymentStatus.Completed,
            Method = "zalopay",
            TransactionId = "TXN_006_" + Guid.NewGuid().ToString().Substring(0, 8),
            CreatedAt = DateTime.UtcNow.AddMinutes(-10),
            PaidAt = DateTime.UtcNow.AddMinutes(-5)
        };

        order6.PaymentId = payment6.Id;
        orders.Add(order6);
        payments.Add(payment6);

        // Save all orders
        foreach (var order in orders)
        {
            await orderRepo.CreateAsync(order, _cts);
        }

        // Save all payments
        foreach (var payment in payments)
        {
            await paymentRepo.CreateAsync(payment, _cts);
        }

        Console.WriteLine($"   ✓ {orders.Count} orders and {payments.Count} payments created");
    }

    #endregion

    #region Bookings Seeding (Legacy Support)

    private static async Task SeedBookingsAsync(
        IBookingRepository bookingRepo,
        ILockerRepository lockerRepo,
        IPackageRepository packageRepo)
    {
        Console.WriteLine("📅 Seeding Bookings (Legacy)...");

        var existingBookings = await bookingRepo.GetAllAsync(_cts);
        if (existingBookings.Count > 0)
        {
            Console.WriteLine("   ✓ Bookings already exist, skipping");
            return;
        }

        var lockers = await lockerRepo.GetAllAsync(_cts);
        var packages = await packageRepo.GetAllAsync(_cts);

        if (lockers.Count == 0 || packages.Count == 0)
        {
            Console.WriteLine("   ⚠ Missing lockers or packages");
            return;
        }

        var bookings = new List<Booking>
        {
            new Booking
            {
                UserId = "sample_user_1",
                LockerId = lockers[0].Id,
                SlotIndex = 2,
                PackageId = packages[0].Id,
                MobileNumber = "+84901234567",
                Status = BookingStatus.Completed,
                TotalAmount = 25000,
                CreatedAt = DateTime.UtcNow.AddDays(-5),
                CompletedAt = DateTime.UtcNow.AddDays(-4)
            },
            new Booking
            {
                UserId = "sample_user_2",
                LockerId = lockers[1].Id,
                SlotIndex = 4,
                PackageId = packages[1].Id,
                MobileNumber = "+84912345678",
                Status = BookingStatus.Active,
                TotalAmount = 50000,
                CreatedAt = DateTime.UtcNow.AddHours(-2),
                StartedAt = DateTime.UtcNow.AddHours(-1)
            }
        };

        foreach (var booking in bookings)
        {
            await bookingRepo.CreateAsync(booking, _cts);
        }

        Console.WriteLine($"   ✓ {bookings.Count} bookings created");
    }

    #endregion
}
