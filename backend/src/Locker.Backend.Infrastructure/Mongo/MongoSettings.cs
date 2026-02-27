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
    public string OtpCodesCollection { get; set; } = "otp_codes";
}
