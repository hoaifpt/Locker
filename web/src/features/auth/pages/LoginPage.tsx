import { useState } from 'react';
import { motion } from 'framer-motion';
import { Lock, User, Eye, EyeOff, ChevronRight } from 'lucide-react';
import { Link, useNavigate } from 'react-router-dom';
import { hidden, visible, trans } from '../../../lib/animations';
import { mockLogin } from '../../../mocks/seed';

const ERROR_MSG: Record<string, string> = {
  NOT_FOUND: 'Tên đăng nhập hoặc email không tồn tại.',
  WRONG_PASSWORD: 'Mật khẩu không chính xác.',
  INACTIVE: 'Tài khoản của bạn đã bị khóa.',
  EMAIL_NOT_VERIFIED: 'Email chưa được xác minh. Vui lòng kiểm tra hộp thư.',
};

export default function LoginPage() {
  const navigate = useNavigate();
  const [showPassword, setShowPassword] = useState(false);
  const [identifier, setIdentifier] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setLoading(true);
    // Simulate network delay — swap for real API call when backend is ready
    await new Promise((r) => setTimeout(r, 500));
    const result = mockLogin(identifier.trim(), password);
    setLoading(false);
    if ('error' in result) {
      setError(ERROR_MSG[result.error] ?? 'Đăng nhập thất bại.');
      return;
    }
    // Save session to localStorage
    localStorage.setItem('userId', result.user.id);
    localStorage.setItem('username', result.user.username);
    localStorage.setItem('fullName', result.user.fullName);
    localStorage.setItem('role', result.user.role);
    navigate('/lockers');
  };

  return (
    <div className="relative min-h-screen overflow-hidden bg-[#F9F8F6] font-sans antialiased">
      {/* Decorative blobs */}
      <div className="pointer-events-none absolute -top-40 -right-40 h-[500px] w-[500px] rounded-full bg-orange-100 opacity-50 blur-3xl" />
      <div className="pointer-events-none absolute bottom-0 -left-32 h-96 w-96 rounded-full bg-orange-50 opacity-70 blur-3xl" />

      {/* Navbar */}
      <header className="relative z-10">
        <div className="mx-auto flex h-16 max-w-7xl items-center justify-between px-6">
          <Link to="/" className="flex items-center gap-2 text-xl font-bold tracking-tight text-gray-900">
            <span className="flex h-8 w-8 items-center justify-center rounded-lg bg-orange-500 text-white">
              <Lock size={16} />
            </span>
            LuxeLock
          </Link>
          <Link
            to="/register"
            className="rounded-lg bg-orange-500 px-4 py-2 text-sm font-semibold text-white shadow-sm transition hover:bg-orange-600"
          >
            Đăng ký
          </Link>
        </div>
      </header>

      {/* Main content */}
      <main className="relative z-10 flex min-h-[calc(100vh-4rem)] items-center justify-center px-4 py-16">
        <div className="w-full max-w-md">
          {/* Header */}
          <motion.div
            initial={hidden}
            animate={visible}
            transition={trans(0)}
            className="mb-8 text-center"
          >
            <span className="inline-flex items-center gap-2 rounded-full border border-orange-200 bg-orange-50 px-4 py-1.5 text-xs font-semibold uppercase tracking-widest text-orange-600">
              Chào mừng trở lại
            </span>
            <h1 className="mt-4 text-3xl font-extrabold tracking-tight text-gray-900">
              Đăng nhập vào <span className="text-orange-500">LuxeLock</span>
            </h1>
            <p className="mt-2 text-sm text-gray-500">
              Quản lý tủ khóa của bạn mọi lúc, mọi nơi.
            </p>
          </motion.div>

          {/* Card */}
          <motion.div
            initial={hidden}
            animate={visible}
            transition={trans(0.1)}
            className="rounded-3xl border border-gray-100 bg-white p-8 shadow-xl shadow-orange-100/40"
          >
            <form onSubmit={handleSubmit} className="space-y-5">
              {/* Username / Email */}
              <div>
                <label className="mb-1.5 block text-sm font-medium text-gray-700">
                  Tên đăng nhập hoặc Email
                </label>
                <div className="relative">
                  <span className="pointer-events-none absolute inset-y-0 left-4 flex items-center text-gray-400">
                    <User size={16} />
                  </span>
                  <input
                    type="text"
                    value={identifier}
                    onChange={(e) => setIdentifier(e.target.value)}
                    placeholder="username hoặc you@example.com"
                    required
                    className="w-full rounded-xl border border-gray-200 bg-gray-50 py-3 pl-11 pr-4 text-sm text-gray-900 outline-none transition placeholder:text-gray-400 focus:border-orange-400 focus:bg-white focus:ring-2 focus:ring-orange-100"
                  />
                </div>
              </div>

              {/* Password */}
              <div>
                <div className="mb-1.5 flex items-center justify-between">
                  <label className="text-sm font-medium text-gray-700">Mật khẩu</label>
                  <Link to="/forgot-password" className="text-xs font-medium text-orange-500 hover:text-orange-600">
                    Quên mật khẩu?
                  </Link>
                </div>
                <div className="relative">
                  <span className="pointer-events-none absolute inset-y-0 left-4 flex items-center text-gray-400">
                    <Lock size={16} />
                  </span>
                  <input
                    type={showPassword ? 'text' : 'password'}
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    placeholder="••••••••"
                    required
                    className="w-full rounded-xl border border-gray-200 bg-gray-50 py-3 pl-11 pr-11 text-sm text-gray-900 outline-none transition placeholder:text-gray-400 focus:border-orange-400 focus:bg-white focus:ring-2 focus:ring-orange-100"
                  />
                  <button
                    type="button"
                    onClick={() => setShowPassword(!showPassword)}
                    className="absolute inset-y-0 right-4 flex items-center text-gray-400 transition hover:text-gray-600"
                  >
                    {showPassword ? <EyeOff size={16} /> : <Eye size={16} />}
                  </button>
                </div>
              </div>

              {/* Remember me */}
              <label className="flex cursor-pointer items-center gap-2.5">
                <input
                  type="checkbox"
                  className="h-4 w-4 rounded border-gray-300 accent-orange-500"
                />
                <span className="text-sm text-gray-600">Ghi nhớ đăng nhập</span>
              </label>

              {/* Error banner */}
              {error && (
                <div className="rounded-xl border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-600">
                  {error}
                </div>
              )}

              {/* Submit */}
              <button
                type="submit"
                disabled={loading}
                className="flex w-full items-center justify-center gap-2 rounded-xl bg-orange-500 py-3 text-sm font-semibold text-white shadow-md shadow-orange-200 transition hover:bg-orange-600 active:scale-[0.98] disabled:opacity-70"
              >
                {loading ? 'Đang đăng nhập...' : <><span>Đăng nhập</span> <ChevronRight size={16} /></>}
              </button>
            </form>

            {/* Divider */}
            <div className="my-6 flex items-center gap-3">
              <div className="h-px flex-1 bg-gray-100" />
              <span className="text-xs text-gray-400">hoặc tiếp tục với</span>
              <div className="h-px flex-1 bg-gray-100" />
            </div>

            {/* Social login */}
            <div className="grid grid-cols-1 gap-3">
              <button
                type="button"
                className="flex items-center justify-center gap-2 rounded-xl border border-gray-200 bg-white py-2.5 text-sm font-medium text-gray-700 transition hover:border-orange-300 hover:bg-orange-50"
              >
                <svg className="h-4 w-4" viewBox="0 0 24 24">
                  <path
                    d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"
                    fill="#4285F4"
                  />
                  <path
                    d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"
                    fill="#34A853"
                  />
                  <path
                    d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"
                    fill="#FBBC05"
                  />
                  <path
                    d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"
                    fill="#EA4335"
                  />
                </svg>
                Đăng nhập với Google
              </button>
            </div>
          </motion.div>

          {/* Footer link */}
          <motion.p
            initial={hidden}
            animate={visible}
            transition={trans(0.2)}
            className="mt-6 text-center text-sm text-gray-500"
          >
            Chưa có tài khoản?{' '}
            <Link to="/register" className="font-semibold text-orange-500 hover:text-orange-600">
              Đăng ký miễn phí
            </Link>
          </motion.p>
        </div>
      </main>
    </div>
  );
}
