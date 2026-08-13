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
    public string OrdersCollection { get; set; } = "orders";
    public string PaymentsCollection { get; set; } = "payments";
    public string OtpCodesCollection { get; set; } = "otp_codes";
    public string NotificationsCollection { get; set; } = "notifications";
    public string DeviceTokensCollection { get; set; } = "device_tokens";
    public string WalletTransactionsCollection { get; set; } = "wallet_transactions";
    public string RestaurantsCollection { get; set; } = "restaurants";
    public string MenuItemsCollection { get; set; } = "menu_items";
    public string FoodOrdersCollection { get; set; } = "food_orders";
    public string DeliveryRequestsCollection { get; set; } = "delivery_requests";
    public string SendReceiveOrdersCollection { get; set; } = "send_receive_orders";
    public string LockerEventsCollection { get; set; } = "locker_events";
    public string FeedbacksCollection { get; set; } = "feedbacks";
}
