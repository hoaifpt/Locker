import { useState, useEffect } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { Menu, X, User, LogOut, ChevronDown } from 'lucide-react';
import ThemeToggle from '../../../components/ui/ThemeToggle';
import Logo from '../../../components/ui/Logo';

export default function Navbar() {
  const [open, setOpen] = useState(false);
  const [scrolled, setScrolled] = useState(false);
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [dropdownOpen, setDropdownOpen] = useState(false);
  const navigate = useNavigate();

  useEffect(() => {
    const token = localStorage.getItem('token');
    setIsLoggedIn(!!token);
    
    // Listen for storage changes (e.g., logout from other tabs)
    const handleStorage = () => {
      setIsLoggedIn(!!localStorage.getItem('token'));
    };
    window.addEventListener('storage', handleStorage);
    return () => window.removeEventListener('storage', handleStorage);
  }, []);

  const handleLogout = () => {
    localStorage.removeItem('token');
    localStorage.removeItem('username');
    localStorage.removeItem('role');
    localStorage.removeItem('userId');
    setIsLoggedIn(false);
    navigate('/');
  };

  const getDashboardLink = () => {
    const role = localStorage.getItem('role');
    return role === 'Admin' ? '/dashboard' : '/my-dashboard';
  };

  return (
    <header
      className={`fixed inset-x-0 top-0 z-50 transition-all duration-300 ${
        scrolled
          ? 'bg-white/70 shadow-sm backdrop-blur-md dark:bg-slate-950/80 dark:shadow-black/20'
          : 'bg-transparent backdrop-blur-sm'
      }`}
    >
      <div className="mx-auto flex h-24 max-w-7xl items-center justify-between px-6">
        {/* Logo */}
        <Link to="/" className="flex items-center gap-2">
          <Logo size={72} showText={false} />
          <span className="text-xl font-bold tracking-tight text-gray-900 dark:text-white">E-Box</span>
        </Link>

        {/* Desktop nav */}
        <nav className="hidden items-center gap-3 md:flex">
          <ThemeToggle />
          {isLoggedIn ? (
            <>
              <div className="relative">
                <button
                  onClick={() => setDropdownOpen(!dropdownOpen)}
                  className="flex items-center gap-2 rounded-lg px-3 py-2 text-sm font-medium text-gray-700 transition hover:bg-orange-50"
                >
                  <span className="flex h-8 w-8 items-center justify-center rounded-full bg-orange-500 text-xs font-bold text-white">
                    {localStorage.getItem('username')?.[0]?.toUpperCase() ?? 'U'}
                  </span>
                  <span className="font-medium">{localStorage.getItem('username') ?? 'User'}</span>
                  <ChevronDown size={14} className="text-gray-400" />
                </button>
                {dropdownOpen && (
                  <div className="absolute right-0 mt-2 w-48 rounded-xl border border-gray-100 bg-white py-2 shadow-xl shadow-gray-200/50 z-50 dark:border-slate-700 dark:bg-slate-900 dark:shadow-black/30">
                    <Link to={getDashboardLink()} onClick={() => setDropdownOpen(false)} className="flex items-center gap-2 px-4 py-2.5 text-sm font-medium text-gray-700 hover:bg-orange-50 hover:text-orange-600">
                      Bảng điều khiển
                    </Link>
                    <Link to="/profile" onClick={() => setDropdownOpen(false)} className="flex items-center gap-2 px-4 py-2.5 text-sm font-medium text-gray-700 hover:bg-orange-50 hover:text-orange-600">
                      Hồ sơ cá nhân
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
            </>
          ) : (
            <>
              <Link
                to="/login"
                className="rounded-lg px-4 py-2 text-sm font-medium text-gray-700 transition hover:text-orange-500"
              >
                Đăng nhập
              </Link>
              <Link
                to="/register"
                className="rounded-lg bg-orange-500 px-4 py-2 text-sm font-semibold text-white shadow-sm transition hover:bg-orange-600"
              >
                Đăng ký
              </Link>
            </>
          )}
        </nav>

        {/* Mobile hamburger */}
        <button
          className="p-2 text-gray-700 dark:text-slate-200 md:hidden"
          onClick={() => setOpen(!open)}
          aria-label="Toggle menu"
        >
          {open ? <X size={22} /> : <Menu size={22} />}
        </button>
      </div>

      {/* Mobile menu */}
      {open && (
        <div className="space-y-3 bg-white/90 px-6 pb-6 pt-2 shadow-lg backdrop-blur-md dark:bg-slate-950/95 md:hidden">
          <div className="flex items-center justify-between rounded-lg px-4 py-2 text-sm font-semibold text-gray-700 dark:text-slate-200">
            <span>Giao diện</span>
            <ThemeToggle />
          </div>
          {isLoggedIn ? (
            <>
              <div className="flex items-center gap-3 px-4 py-3 bg-orange-50 rounded-lg">
                <span className="flex h-10 w-10 items-center justify-center rounded-full bg-orange-500 text-sm font-bold text-white">
                  {localStorage.getItem('username')?.[0]?.toUpperCase() ?? 'U'}
                </span>
                <div>
                  <p className="font-medium text-gray-900">{localStorage.getItem('username')}</p>
                  <p className="text-xs text-gray-500">{localStorage.getItem('role')}</p>
                </div>
              </div>
              <Link
                to={getDashboardLink()}
                onClick={() => setOpen(false)}
                className="block rounded-lg px-4 py-2 text-sm font-medium text-gray-700 hover:bg-orange-50"
              >
                Bảng điều khiển
              </Link>
              <Link
                to="/profile"
                onClick={() => setOpen(false)}
                className="block rounded-lg px-4 py-2 text-sm font-medium text-gray-700 hover:bg-orange-50"
              >
                Hồ sơ cá nhân
              </Link>
              <button
                onClick={handleLogout}
                className="flex w-full items-center gap-2 rounded-lg px-4 py-2 text-sm font-medium text-red-600 hover:bg-red-50"
              >
                <LogOut size={16} /> Đăng xuất
              </button>
            </>
          ) : (
            <>
              <Link
                to="/login"
                className="block rounded-lg px-4 py-2 text-sm font-medium text-gray-700 hover:bg-orange-50"
              >
                Đăng nhập
              </Link>
              <Link
                to="/register"
                className="block rounded-lg bg-orange-500 px-4 py-2 text-center text-sm font-semibold text-white hover:bg-orange-600"
              >
                Đăng ký
              </Link>
            </>
          )}
        </div>
      )}
    </header>
  );
}
