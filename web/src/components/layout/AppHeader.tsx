import { useState } from 'react';
import { Link, useLocation, useNavigate } from 'react-router-dom';
import { Menu, X, User, LogOut, ChevronDown, LayoutDashboard, MessageSquareText, Settings } from 'lucide-react';
import NotificationsDropdown from '../../features/notifications/components/NotificationsDropdown';
import { useFeedback } from '../../features/feedback/context/FeedbackContext';
import ThemeToggle from '../ui/ThemeToggle';
import Logo from '../ui/Logo';

export default function AppHeader() {
  const location = useLocation();
  const navigate = useNavigate();
  const feedback = useFeedback();
  const [mobileOpen, setMobileOpen] = useState(false);
  const [dropdownOpen, setDropdownOpen] = useState(false);

  const username = localStorage.getItem('username') ?? 'Người dùng';
  const role = localStorage.getItem('role') ?? 'User';

  const handleLogout = () => {
    localStorage.removeItem('token');
    localStorage.removeItem('username');
    localStorage.removeItem('role');
    localStorage.removeItem('userId');
    navigate('/login');
  };

  const getNavLinks = () => {
    if (role === 'Shipper') {
      return [
        { to: '/dashboard', label: 'Bảng điều khiển' },
        { to: '/shipper/tasks', label: 'Giao hàng' },
        { to: '/wallet', label: 'Ví E-Box' },
      ];
    }
    if (role === 'Admin') {
      return [
        { to: '/dashboard', label: 'Bảng điều khiển' },
        { to: '/users', label: 'Quản lý Users' },
        { to: '/feedbacks', label: 'Feedback' },
      ];
    }
    return [
      { to: '/my-dashboard', label: 'Dashboard' },
      { to: '/lockers', label: 'Tủ khóa' },
      { to: '/orders', label: 'Đơn hàng' },
      { to: '/food', label: 'Ăn uống' },
      { to: '/send-receive', label: 'Gửi - Nhận' },
      { to: '/wallet', label: 'Ví E-Box' },
    ];
  };

  const NAV_LINKS = getNavLinks();

  return (
    <header className="sticky top-0 z-50 border-b border-gray-100 bg-white/80 backdrop-blur-md dark:border-slate-800 dark:bg-slate-950/85">
      <div className="mx-auto flex h-24 max-w-7xl items-center justify-between px-6">
        {/* Logo */}
        <Link to={role === 'User' ? '/' : '/dashboard'} className="flex items-center gap-2">
          <Logo size={72} showText={false} />
          <span className="text-xl font-bold tracking-tight text-gray-900 dark:text-white">E-Box</span>
        </Link>

        {/* Desktop nav */}
        <nav className="hidden items-center gap-1 md:flex ml-8 flex-1">
          {NAV_LINKS.map((link) => (
            <Link
              key={link.to}
              to={link.to}
              className={`rounded-lg px-3 py-2 text-sm font-medium transition ${location.pathname.startsWith(link.to) && link.to !== '/'
                  ? 'bg-orange-50 text-orange-600'
                  : 'text-gray-600 hover:bg-gray-50 hover:text-orange-500'
                }`}
            >
              {link.label}
            </Link>
          ))}
        </nav>

        {/* Right actions */}
        <div className="hidden items-center gap-3 md:flex">
          <ThemeToggle />

          {/* Notifications */}
          <NotificationsDropdown />

          <div className="h-6 w-px bg-gray-200"></div>

          {/* User menu */}
          <div className="relative">
            <button
              onClick={() => setDropdownOpen(!dropdownOpen)}
              className="flex items-center gap-2 rounded-xl px-2 py-1.5 text-sm font-medium text-gray-700 transition hover:bg-orange-50"
            >
              <span className={`flex h-8 w-8 items-center justify-center rounded-full text-xs font-bold text-white shadow-sm ${role === 'Admin' ? 'bg-purple-500' : role === 'Shipper' ? 'bg-blue-500' : 'bg-orange-500'}`}>
                {username[0]?.toUpperCase() ?? 'U'}
              </span>
              <div className="hidden lg:block text-left">
                <p className="text-sm font-bold text-gray-900 leading-tight">{username}</p>
                <p className="text-[10px] text-gray-500 font-semibold">{role}</p>
              </div>
              <ChevronDown size={14} className="text-gray-400" />
            </button>
            {dropdownOpen && (
              <div className="absolute right-0 mt-2 w-48 rounded-2xl border border-gray-100 bg-white py-2 shadow-xl shadow-gray-200/50 z-50 dark:border-slate-700 dark:bg-slate-900 dark:shadow-black/30">
                <Link to={role === 'Admin' ? '/dashboard' : '/my-dashboard'} onClick={() => setDropdownOpen(false)} className="flex items-center gap-2 px-4 py-2.5 text-sm font-medium text-gray-700 hover:bg-orange-50 hover:text-orange-600">
                  <LayoutDashboard size={16} /> Bảng điều khiển
                </Link>
                <Link to="/profile" onClick={() => setDropdownOpen(false)} className="flex items-center gap-2 px-4 py-2.5 text-sm font-medium text-gray-700 hover:bg-orange-50 hover:text-orange-600">
                  <User size={16} /> Hồ sơ cá nhân
                </Link>
                <Link to="/settings" onClick={() => setDropdownOpen(false)} className="flex items-center gap-2 px-4 py-2.5 text-sm font-medium text-gray-700 hover:bg-orange-50 hover:text-orange-600">
                  <Settings size={16} /> Cài đặt
                </Link>
                <div className="my-1 border-t border-gray-100"></div>
                <button
                  onClick={handleLogout}
                  className="flex w-full items-center gap-2 px-4 py-2.5 text-left text-sm font-medium text-red-600 hover:bg-red-50"
                >
                  <LogOut size={16} /> Đăng xuất
                </button>
              </div>
            )}
          </div>
        </div>

        {/* Mobile menu toggle */}
        <button
          className="flex h-10 w-10 items-center justify-center rounded-xl text-gray-500 hover:bg-gray-100 dark:text-slate-300 dark:hover:bg-slate-800 md:hidden"
          onClick={() => setMobileOpen(!mobileOpen)}
        >
          {mobileOpen ? <X size={24} /> : <Menu size={24} />}
        </button>
      </div>

      {/* Mobile nav */}
      {mobileOpen && (
        <div className="border-t border-gray-100 bg-white px-4 py-4 shadow-lg dark:border-slate-800 dark:bg-slate-900 md:hidden">
          <nav className="flex flex-col gap-2">
            <div className="flex items-center justify-between rounded-xl px-4 py-2 text-sm font-semibold text-gray-700 dark:text-slate-200">
              <span>Giao diện</span>
              <ThemeToggle />
            </div>
            {NAV_LINKS.map((link) => (
              <Link
                key={link.to}
                to={link.to}
                onClick={() => setMobileOpen(false)}
                className={`rounded-xl px-4 py-3 text-sm font-medium ${location.pathname === link.to
                    ? 'bg-orange-50 text-orange-600'
                    : 'text-gray-600 hover:bg-gray-50'
                  }`}
              >
                {link.label}
              </Link>
            ))}
            <div className="my-2 border-t border-gray-100"></div>
            {feedback && (
              <button
                type="button"
                onClick={(event) => {
                  const trigger = event.currentTarget;
                  setMobileOpen(false);
                  feedback.openFeedback(trigger);
                }}
                aria-haspopup="dialog"
                aria-expanded={feedback.isOpen}
                className="flex w-full items-center gap-2 rounded-xl px-4 py-3 text-left text-sm font-medium text-gray-600 transition hover:bg-orange-50 hover:text-orange-600 dark:text-slate-300 dark:hover:bg-orange-950/40 dark:hover:text-orange-400"
              >
                <MessageSquareText aria-hidden="true" size={18} />
                Gửi feedback
              </button>
            )}
            <Link
              to="/profile"
              onClick={() => setMobileOpen(false)}
              className="flex items-center gap-2 rounded-xl px-4 py-3 text-sm font-medium text-gray-600 hover:bg-gray-50"
            >
              <User size={18} /> Hồ sơ cá nhân
            </Link>
            <Link
              to="/settings"
              onClick={() => setMobileOpen(false)}
              className="flex items-center gap-2 rounded-xl px-4 py-3 text-sm font-medium text-gray-600 hover:bg-gray-50"
            >
              <Settings size={18} /> Cài đặt
            </Link>
            <button
              onClick={handleLogout}
              className="flex items-center gap-2 rounded-xl px-4 py-3 text-left text-sm font-medium text-red-600 hover:bg-red-50"
            >
              <LogOut size={18} /> Đăng xuất
            </button>
          </nav>
        </div>
      )}
    </header>
  );
}
