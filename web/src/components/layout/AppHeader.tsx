import { useState } from 'react';
import { Link, useLocation, useNavigate } from 'react-router-dom';
import { Lock, Menu, X, User, LogOut, ChevronDown } from 'lucide-react';

const NAV_LINKS = [
  { to: '/lockers', label: 'Tủ khóa' },
  { to: '/packages', label: 'Gói dịch vụ' },
  { to: '/bookings', label: 'Đặt chỗ của tôi' },
];

export default function AppHeader() {
  const location = useLocation();
  const navigate = useNavigate();
  const [mobileOpen, setMobileOpen] = useState(false);
  const [dropdownOpen, setDropdownOpen] = useState(false);

  const username = localStorage.getItem('username') ?? 'Người dùng';

  const handleLogout = () => {
    localStorage.removeItem('token');
    localStorage.removeItem('username');
    localStorage.removeItem('role');
    navigate('/login');
  };

  return (
    <header className="sticky top-0 z-50 border-b border-gray-100 bg-white/80 backdrop-blur-md">
      <div className="mx-auto flex h-16 max-w-7xl items-center justify-between px-6">
        {/* Logo */}
        <Link to="/" className="flex items-center gap-2 text-xl font-bold tracking-tight text-gray-900">
          <span className="flex h-8 w-8 items-center justify-center rounded-lg bg-orange-500 text-white">
            <Lock size={16} />
          </span>
          LuxeLock
        </Link>

        {/* Desktop nav */}
        <nav className="hidden items-center gap-1 md:flex">
          {NAV_LINKS.map((link) => (
            <Link
              key={link.to}
              to={link.to}
              className={`rounded-lg px-4 py-2 text-sm font-medium transition ${
                location.pathname === link.to
                  ? 'bg-orange-50 text-orange-500'
                  : 'text-gray-600 hover:text-orange-500'
              }`}
            >
              {link.label}
            </Link>
          ))}
        </nav>

        {/* User menu */}
        <div className="hidden items-center gap-3 md:flex">
          <div className="relative">
            <button
              onClick={() => setDropdownOpen(!dropdownOpen)}
              className="flex items-center gap-2 rounded-xl px-3 py-2 text-sm font-medium text-gray-700 transition hover:bg-orange-50"
            >
              <span className="flex h-7 w-7 items-center justify-center rounded-full bg-orange-500 text-xs font-bold text-white">
                {username[0].toUpperCase()}
              </span>
              {username}
              <ChevronDown size={14} />
            </button>
            {dropdownOpen && (
              <div className="absolute right-0 mt-1 w-44 rounded-2xl border border-gray-100 bg-white py-1 shadow-xl">
                <Link
                  to="/profile"
                  onClick={() => setDropdownOpen(false)}
                  className="flex items-center gap-2 px-4 py-2.5 text-sm text-gray-700 hover:bg-orange-50"
                >
                  <User size={14} />
                  Hồ sơ của tôi
                </Link>
                <div className="my-1 h-px bg-gray-100" />
                <button
                  onClick={handleLogout}
                  className="flex w-full items-center gap-2 px-4 py-2.5 text-sm text-red-500 hover:bg-red-50"
                >
                  <LogOut size={14} />
                  Đăng xuất
                </button>
              </div>
            )}
          </div>
        </div>

        {/* Mobile hamburger */}
        <button
          className="p-2 text-gray-700 md:hidden"
          onClick={() => setMobileOpen(!mobileOpen)}
        >
          {mobileOpen ? <X size={22} /> : <Menu size={22} />}
        </button>
      </div>

      {/* Mobile menu */}
      {mobileOpen && (
        <div className="border-t border-gray-100 bg-white px-6 pb-4 pt-2 md:hidden">
          {NAV_LINKS.map((link) => (
            <Link
              key={link.to}
              to={link.to}
              onClick={() => setMobileOpen(false)}
              className={`block rounded-lg px-4 py-2.5 text-sm font-medium ${
                location.pathname === link.to
                  ? 'bg-orange-50 text-orange-500'
                  : 'text-gray-700 hover:bg-orange-50'
              }`}
            >
              {link.label}
            </Link>
          ))}
          <div className="mt-2 border-t border-gray-100 pt-2">
            <Link
              to="/profile"
              onClick={() => setMobileOpen(false)}
              className="block rounded-lg px-4 py-2.5 text-sm font-medium text-gray-700 hover:bg-orange-50"
            >
              Hồ sơ của tôi
            </Link>
            <button
              onClick={handleLogout}
              className="block w-full rounded-lg px-4 py-2.5 text-left text-sm font-medium text-red-500 hover:bg-red-50"
            >
              Đăng xuất
            </button>
          </div>
        </div>
      )}
    </header>
  );
}
