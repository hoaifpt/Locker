import { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { Lock, Menu, X } from 'lucide-react';

export default function Navbar() {
  const [open, setOpen] = useState(false);
  const [scrolled, setScrolled] = useState(false);

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 20);
    window.addEventListener('scroll', onScroll);
    return () => window.removeEventListener('scroll', onScroll);
  }, []);

  return (
    <header
      className={`fixed inset-x-0 top-0 z-50 transition-all duration-300 ${
        scrolled
          ? 'bg-white/70 shadow-sm backdrop-blur-md'
          : 'bg-transparent backdrop-blur-sm'
      }`}
    >
      <div className="mx-auto flex h-16 max-w-7xl items-center justify-between px-6">
        {/* Logo */}
        <Link to="/" className="flex items-center gap-2 text-xl font-bold tracking-tight text-gray-900">
          <span className="flex h-8 w-8 items-center justify-center rounded-lg bg-orange-500 text-white">
            <Lock size={16} />
          </span>
          LuxeLock
        </Link>

        {/* Desktop nav */}
        <nav className="hidden items-center gap-3 md:flex">
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
        </nav>

        {/* Mobile hamburger */}
        <button
          className="p-2 text-gray-700 md:hidden"
          onClick={() => setOpen(!open)}
          aria-label="Toggle menu"
        >
          {open ? <X size={22} /> : <Menu size={22} />}
        </button>
      </div>

      {/* Mobile menu */}
      {open && (
        <div className="space-y-3 bg-white/90 px-6 pb-6 pt-2 shadow-lg backdrop-blur-md md:hidden">
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
        </div>
      )}
    </header>
  );
}
