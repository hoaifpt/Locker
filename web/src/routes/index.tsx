import { Routes, Route } from 'react-router-dom';
import ProtectedRoute from '../components/layout/ProtectedRoute';

// Auth
import LoginPage from '../features/auth/pages/LoginPage';
import RegisterPage from '../features/auth/pages/RegisterPage';
import VerifyEmailPage from '../features/auth/pages/VerifyEmailPage';
import ForgotPasswordPage from '../features/auth/pages/ForgotPasswordPage';
import ResetPasswordPage from '../features/auth/pages/ResetPasswordPage';

// Home & Dashboard
import HomePage from '../features/home/pages/HomePage';
import DashboardPage from '../features/dashboard/pages/DashboardPage';

// Lockers & Packages
import LockersPage from '../features/lockers/pages/LockersPage';
import LockerDetailPage from '../features/lockers/pages/LockerDetailPage';
import PackagesPage from '../features/packages/pages/PackagesPage';

// Orders & Bookings
import OrdersPage from '../features/orders/pages/OrdersPage';
import OrderDetailPage from '../features/orders/pages/OrderDetailPage';
import CreateOrderPage from '../features/orders/pages/CreateOrderPage';
import BookingsPage from '../features/bookings/pages/BookingsPage';
import BookingDetailPage from '../features/bookings/pages/BookingDetailPage';

// Payments & Wallet
import PaymentPage from '../features/payments/pages/PaymentPage';
import WalletPage from '../features/wallet/pages/WalletPage';

// Delivery & Send-Receive
import DeliveryTasksPage from '../features/delivery/pages/DeliveryTasksPage';
import DeliveryTaskDetailPage from '../features/delivery/pages/DeliveryTaskDetailPage';
import CreateDeliveryPage from '../features/delivery/pages/CreateDeliveryPage';
import TrackDeliveryPage from '../features/delivery/pages/TrackDeliveryPage';
import SendReceivePage from '../features/send-receive/pages/SendReceivePage';
import CreateSendReceivePage from '../features/send-receive/pages/CreateSendReceivePage';
import SendReceiveDetailPage from '../features/send-receive/pages/SendReceiveDetailPage';

// Food Orders
import RestaurantsPage from '../features/food/pages/RestaurantsPage';
import RestaurantDetailPage from '../features/food/pages/RestaurantDetailPage';
import CheckoutFoodPage from '../features/food/pages/CheckoutFoodPage';
import FoodOrdersPage from '../features/food/pages/FoodOrdersPage';
import FoodOrderDetailPage from '../features/food/pages/FoodOrderDetailPage';

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
      <Route path="/track/:trackingCode" element={<TrackDeliveryPage />} />

      {/* Common Authenticated Routes (Any logged in user) */}
      <Route element={<ProtectedRoute />}>
        <Route path="/dashboard" element={<DashboardPage />} />
        <Route path="/profile" element={<ProfilePage />} />
        <Route path="/wallet" element={<WalletPage />} />
        <Route path="/lockers" element={<LockersPage />} />
        <Route path="/lockers/:id" element={<LockerDetailPage />} />
      </Route>

      {/* User Only Routes */}
      <Route element={<ProtectedRoute allowedRoles={['User']} />}>
        <Route path="/packages" element={<PackagesPage />} />
        
        <Route path="/orders" element={<OrdersPage />} />
        <Route path="/orders/new" element={<CreateOrderPage />} />
        <Route path="/orders/:id" element={<OrderDetailPage />} />
        
        <Route path="/bookings" element={<BookingsPage />} />
        <Route path="/bookings/:id" element={<BookingDetailPage />} />
        
        <Route path="/send-receive" element={<SendReceivePage />} />
        <Route path="/send-receive/new" element={<CreateSendReceivePage />} />
        <Route path="/send-receive/:id" element={<SendReceiveDetailPage />} />
        
        <Route path="/food" element={<RestaurantsPage />} />
        <Route path="/food/checkout" element={<CheckoutFoodPage />} />
        <Route path="/food/orders" element={<FoodOrdersPage />} />
        <Route path="/food/orders/:id" element={<FoodOrderDetailPage />} />
        <Route path="/food/:id" element={<RestaurantDetailPage />} />
        
        <Route path="/payment/:orderId" element={<PaymentPage />} />
      </Route>

      {/* Shipper Only Routes */}
      <Route element={<ProtectedRoute allowedRoles={['Shipper']} />}>
        <Route path="/shipper/tasks" element={<DeliveryTasksPage />} />
        <Route path="/shipper/tasks/:id" element={<DeliveryTaskDetailPage />} />
        <Route path="/shipper/delivery/new" element={<CreateDeliveryPage />} />
      </Route>

      {/* Admin Only Routes */}
      <Route element={<ProtectedRoute allowedRoles={['Admin']} />}>
        {/* Placeholder for future admin-only routes */}
      </Route>
    </Routes>
  );
}
