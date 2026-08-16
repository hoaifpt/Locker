import { Link, useLocation } from 'react-router-dom';
import { LayoutDashboard, Users, MessageSquare, Settings, Clock, CreditCard, Wallet, LogOut } from 'lucide-react';
import Logo from '../../../components/ui/Logo';

const adminNav = [
  { to: '/dashboard', label: 'Bảng điều khiển', icon: LayoutDashboard },
  { to: '/users', label: 'Quản lý Users', icon: Users },
  { to: '/bookings', label: 'Quản lý Bookings', icon: Clock },
  { to: '/payments', label: 'Quản lý Payments', icon: CreditCard },
  { to: '/wallet-admin', label: 'Quản lý Wallet', icon: Wallet },
  { to: '/feedbacks', label: 'Feedback', icon: MessageSquare },
  { to: '/settings', label: 'Cài đặt', icon: Settings },
];

export default function AdminSidebar() {
  const location = useLocation();

  const handleLogout = () => {
    localStorage.removeItem('token');
    localStorage.removeItem('role');
    localStorage.removeItem('userId');
    localStorage.removeItem('username');
    window.location.href = '/login';
  };

  return (
    <aside className="fixed left-0 top-0 z-40 flex h-screen w-64 flex-col border-r border-gray-200 bg-white">
      {/* Logo */}
      <div className="flex h-24 items-center gap-3 border-b border-gray-100 px-6">
        <Logo size={72} showText={false} />
        <div>
          <h1 className="text-sm font-bold text-gray-900">E-Box Admin</h1>
          <p className="text-xs text-gray-400">Quản trị hệ thống</p>
        </div>
      </div>

      {/* Navigation */}
      <nav className="flex-1 space-y-1 px-3 py-4">
        {adminNav.map((item) => {
          const Icon = item.icon;
          const isActive = location.pathname === item.to;
          return (
            <Link
              key={item.to}
              to={item.to}
              className={`flex items-center gap-3 rounded-xl px-4 py-3 text-sm font-semibold transition-all ${
                isActive
                  ? 'bg-gradient-to-r from-orange-500 to-orange-600 text-white shadow-md shadow-orange-200/50'
                  : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900'
              }`}
            >
              <Icon size={18} />
              {item.label}
            </Link>
          );
        })}
      </nav>

      {/* Bottom actions */}
      <div className="border-t border-gray-100 p-3">
        <button
          onClick={handleLogout}
          className="flex w-full items-center gap-3 rounded-xl px-4 py-3 text-sm font-semibold text-red-500 transition hover:bg-red-50 hover:text-red-600"
        >
          <LogOut size={18} />
          Đăng xuất
        </button>
      </div>
    </aside>
  );
}
