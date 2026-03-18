namespace Locker.Backend.Application;

/// <summary>
/// Centralized API endpoint constants for easy frontend integration.
/// Use these constants to construct API URLs across the application.
/// </summary>
public static class ApiEndpoints
{
    private const string ApiBase = "/api";

    public static class Auth
    {
        private const string Base = $"{ApiBase}/auth";
        public const string Login = $"{Base}/login";
        public const string Register = $"{Base}/register";
        public const string VerifyEmail = $"{Base}/verify-email";
        public const string ResendVerification = $"{Base}/resend-verification";
        public const string Refresh = $"{Base}/refresh";
        public const string Logout = $"{Base}/logout";
        public const string LogoutAll = $"{Base}/logout-all";
        public const string ForgotPassword = $"{Base}/forgot-password";
        public const string ResetPassword = $"{Base}/reset-password";
    }

    public static class Users
    {
        private const string Base = $"{ApiBase}/users";
        public const string GetMe = $"{Base}/me";
        public const string UpdateMe = $"{Base}/me";
        public const string ChangePassword = $"{Base}/me/change-password";
    }

    public static class Lockers
    {
        private const string Base = $"{ApiBase}/lockers";
        public const string GetAll = Base;
        public const string Create = Base;
        public const string GetById = $"{Base}/{{id}}";
        public const string Update = $"{Base}/{{id}}";
        public const string Delete = $"{Base}/{{id}}";
        public const string GetAvailable = $"{Base}/available";
        public const string UpdateSlotStatus = $"{Base}/{{id}}/slots/{{slotIndex}}/status";
    }

    public static class Bookings
    {
        private const string Base = $"{ApiBase}/bookings";
        public const string GetById = $"{Base}/{{id}}";
        public const string GetMy = $"{Base}/my";
        public const string Create = Base;
        public const string SetPin = $"{Base}/{{id}}/set-pin";
        public const string VerifyPin = $"{Base}/{{id}}/verify-pin";
        public const string Complete = $"{Base}/{{id}}/complete";
        public const string Cancel = $"{Base}/{{id}}/cancel";
    }

    public static class Packages
    {
        private const string Base = $"{ApiBase}/packages";
        public const string GetAll = Base;
        public const string Create = Base;
        public const string GetById = $"{Base}/{{id}}";
        public const string Update = $"{Base}/{{id}}";
        public const string Delete = $"{Base}/{{id}}";
    }

    public static class Orders
    {
        private const string Base = $"{ApiBase}/orders";
        public const string GetById = $"{Base}/{{id}}";
        public const string GetMy = $"{Base}/my";
        public const string Reserve = $"{Base}/reserve";
        public const string Confirm = $"{Base}/{{id}}/confirm";
        public const string SetPin = $"{Base}/{{id}}/set-pin";
        public const string Activate = $"{Base}/{{id}}/activate";
        public const string Complete = $"{Base}/{{id}}/complete";
        public const string Cancel = $"{Base}/{{id}}/cancel";
        public const string Extend = $"{Base}/{{id}}/extend";
        public const string GetAvailableSlots = $"{Base}/availability/slots";
        public const string LinkPayment = $"{Base}/{{id}}/payment";
    }

    public static class Payments
    {
        private const string Base = $"{ApiBase}/payments";
        public const string GetById = $"{Base}/{{id}}";
        public const string GetByBookingId = $"{Base}/booking/{{bookingId}}";
        public const string GetMy = $"{Base}/my";
        public const string Create = Base;
        public const string Complete = $"{Base}/{{id}}/complete";
    }

    public static class Admin
    {
        private const string Base = $"{ApiBase}/admin";

        public static class Users
        {
            private const string BaseUsers = $"{Base}/users";
            public const string GetAll = BaseUsers;
            public const string UpdateRole = $"{BaseUsers}/{{id}}/role";
            public const string Deactivate = $"{BaseUsers}/{{id}}/deactivate";
            public const string Activate = $"{BaseUsers}/{{id}}/activate";
        }

        public static class Bookings
        {
            private const string BaseBookings = $"{Base}/bookings";
            public const string GetAll = BaseBookings;
        }

        public static class Payments
        {
            private const string BasePayments = $"{Base}/payments";
            public const string GetAll = BasePayments;
        }
    }

    public static class Health
    {
        public const string Check = $"{ApiBase}/health";
    }
}
