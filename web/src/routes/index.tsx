import { Routes, Route } from 'react-router-dom';

// Auth
import LoginPage from '../features/auth/pages/LoginPage';
import RegisterPage from '../features/auth/pages/RegisterPage';
import VerifyEmailPage from '../features/auth/pages/VerifyEmailPage';
import ForgotPasswordPage from '../features/auth/pages/ForgotPasswordPage';
import ResetPasswordPage from '../features/auth/pages/ResetPasswordPage';

// Home
import HomePage from '../features/home/pages/HomePage';

// Lockers
import LockersPage from '../features/lockers/pages/LockersPage';
import LockerDetailPage from '../features/lockers/pages/LockerDetailPage';

// Bookings
import BookingsPage from '../features/bookings/pages/BookingsPage';
import BookingDetailPage from '../features/bookings/pages/BookingDetailPage';

// Packages
import PackagesPage from '../features/packages/pages/PackagesPage';

// Profile
import ProfilePage from '../features/profile/pages/ProfilePage';

export default function AppRoutes() {
  return (
    <Routes>
      {/* Public */}
      <Route path="/" element={<HomePage />} />
      <Route path="/login" element={<LoginPage />} />
      <Route path="/register" element={<RegisterPage />} />
      <Route path="/verify-email" element={<VerifyEmailPage />} />
      <Route path="/forgot-password" element={<ForgotPasswordPage />} />
      <Route path="/reset-password" element={<ResetPasswordPage />} />

      {/* App (authenticated) */}
      <Route path="/lockers" element={<LockersPage />} />
      <Route path="/lockers/:id" element={<LockerDetailPage />} />
      <Route path="/packages" element={<PackagesPage />} />
      <Route path="/bookings" element={<BookingsPage />} />
      <Route path="/bookings/:id" element={<BookingDetailPage />} />
      <Route path="/profile" element={<ProfilePage />} />
    </Routes>
  );
}
