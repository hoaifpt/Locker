namespace Locker.Backend.Infrastructure.Mongo;

public class MongoSettings
{
    public string ConnectionString { get; set; } = "mongodb://localhost:27017";
    public string DatabaseName { get; set; } = "locker";
    public string UsersCollection { get; set; } = "users";
    public string LockersCollection { get; set; } = "lockers";
    public string RefreshTokensCollection { get; set; } = "refresh_tokens";
    public string PackagesCollection { get; set; } = "packages";
    public string BookingsCollection { get; set; } = "bookings";
    public string PaymentsCollection { get; set; } = "payments";
    public string LockerSlotsCollection { get; set; } = "locker_slots";
    public string TransactionsCollection { get; set; } = "transactions";
    public string FoodOrdersCollection { get; set; } = "food_orders";
    public string PersonalStorageCollection { get; set; } = "personal_storage";
    public string NotificationsCollection { get; set; } = "notifications";
    public string QrCodesCollection { get; set; } = "qr_codes";
    public string OtpCodesCollection { get; set; } = "otp_codes";
}
