import { useState } from 'react';
import { motion } from 'framer-motion';
import { Lock, Mail, Eye, EyeOff, User, Phone, ChevronRight } from 'lucide-react';
import { Link } from 'react-router-dom';
import { hidden, visible, trans } from '../../../lib/animations';

export default function RegisterPage() {
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirm, setShowConfirm] = useState(false);
  const [form, setForm] = useState({
    username: '',
    email: '',
    fullName: '',
    phoneNumber: '',
    password: '',
    confirm: '',
  });

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setForm({ ...form, [e.target.name]: e.target.value });
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    // TODO: connect API
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
            to="/login"
            className="rounded-lg px-4 py-2 text-sm font-medium text-gray-700 transition hover:text-orange-500"
          >
            Đăng nhập
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
              Tạo tài khoản
            </span>
            <h1 className="mt-4 text-3xl font-extrabold tracking-tight text-gray-900">
              Đăng ký <span className="text-orange-500">LuxeLock</span>
            </h1>
            <p className="mt-2 text-sm text-gray-500">
              Miễn phí. Không cần thẻ tín dụng.
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
              {/* Username */}
              <div>
                <label className="mb-1.5 block text-sm font-medium text-gray-700">
                  Tên đăng nhập <span className="text-orange-500">*</span>
                </label>
                <div className="relative">
                  <span className="pointer-events-none absolute inset-y-0 left-4 flex items-center text-gray-400">
                    <User size={16} />
                  </span>
                  <input
                    type="text"
                    name="username"
                    value={form.username}
                    onChange={handleChange}
                    placeholder="vd: nguyenvana"
                    required
                    className="w-full rounded-xl border border-gray-200 bg-gray-50 py-3 pl-11 pr-4 text-sm text-gray-900 outline-none transition placeholder:text-gray-400 focus:border-orange-400 focus:bg-white focus:ring-2 focus:ring-orange-100"
                  />
                </div>
              </div>

              {/* Full name */}
              <div>
                <label className="mb-1.5 block text-sm font-medium text-gray-700">
                  Họ và tên
                </label>
                <div className="relative">
                  <span className="pointer-events-none absolute inset-y-0 left-4 flex items-center text-gray-400">
                    <User size={16} />
                  </span>
                  <input
                    type="text"
                    name="fullName"
                    value={form.fullName}
                    onChange={handleChange}
                    placeholder="Nguyễn Văn A"
                    className="w-full rounded-xl border border-gray-200 bg-gray-50 py-3 pl-11 pr-4 text-sm text-gray-900 outline-none transition placeholder:text-gray-400 focus:border-orange-400 focus:bg-white focus:ring-2 focus:ring-orange-100"
                  />
                </div>
              </div>

              {/* Email */}
              <div>
                <label className="mb-1.5 block text-sm font-medium text-gray-700">
                  Email <span className="text-orange-500">*</span>
                </label>
                <div className="relative">
                  <span className="pointer-events-none absolute inset-y-0 left-4 flex items-center text-gray-400">
                    <Mail size={16} />
                  </span>
                  <input
                    type="email"
                    name="email"
                    value={form.email}
                    onChange={handleChange}
                    placeholder="you@example.com"
                    required
                    className="w-full rounded-xl border border-gray-200 bg-gray-50 py-3 pl-11 pr-4 text-sm text-gray-900 outline-none transition placeholder:text-gray-400 focus:border-orange-400 focus:bg-white focus:ring-2 focus:ring-orange-100"
                  />
                </div>
              </div>

              {/* Phone number */}
              <div>
                <label className="mb-1.5 block text-sm font-medium text-gray-700">
                  Số điện thoại
                </label>
                <div className="relative">
                  <span className="pointer-events-none absolute inset-y-0 left-4 flex items-center text-gray-400">
                    <Phone size={16} />
                  </span>
                  <input
                    type="tel"
                    name="phoneNumber"
                    value={form.phoneNumber}
                    onChange={handleChange}
                    placeholder="0912 345 678"
                    className="w-full rounded-xl border border-gray-200 bg-gray-50 py-3 pl-11 pr-4 text-sm text-gray-900 outline-none transition placeholder:text-gray-400 focus:border-orange-400 focus:bg-white focus:ring-2 focus:ring-orange-100"
                  />
                </div>
              </div>

              {/* Password */}
              <div>
                <label className="mb-1.5 block text-sm font-medium text-gray-700">
                  Mật khẩu <span className="text-orange-500">*</span>
                </label>
                <div className="relative">
                  <span className="pointer-events-none absolute inset-y-0 left-4 flex items-center text-gray-400">
                    <Lock size={16} />
                  </span>
                  <input
                    type={showPassword ? 'text' : 'password'}
                    name="password"
                    value={form.password}
                    onChange={handleChange}
                    placeholder="Tối thiểu 6 ký tự"
                    required
                    minLength={6}
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

              {/* Confirm password */}
              <div>
                <label className="mb-1.5 block text-sm font-medium text-gray-700">
                  Xác nhận mật khẩu <span className="text-orange-500">*</span>
                </label>
                <div className="relative">
                  <span className="pointer-events-none absolute inset-y-0 left-4 flex items-center text-gray-400">
                    <Lock size={16} />
                  </span>
                  <input
                    type={showConfirm ? 'text' : 'password'}
                    name="confirm"
                    value={form.confirm}
                    onChange={handleChange}
                    placeholder="Nhập lại mật khẩu"
                    required
                    className="w-full rounded-xl border border-gray-200 bg-gray-50 py-3 pl-11 pr-11 text-sm text-gray-900 outline-none transition placeholder:text-gray-400 focus:border-orange-400 focus:bg-white focus:ring-2 focus:ring-orange-100"
                  />
                  <button
                    type="button"
                    onClick={() => setShowConfirm(!showConfirm)}
                    className="absolute inset-y-0 right-4 flex items-center text-gray-400 transition hover:text-gray-600"
                  >
                    {showConfirm ? <EyeOff size={16} /> : <Eye size={16} />}
                  </button>
                </div>
              </div>

              {/* Terms */}
              <label className="flex cursor-pointer items-start gap-2.5">
                <input
                  type="checkbox"
                  required
                  className="mt-0.5 h-4 w-4 rounded border-gray-300 accent-orange-500"
                />
                <span className="text-sm text-gray-600">
                  Tôi đồng ý với{' '}
                  <a href="#" className="font-medium text-orange-500 hover:text-orange-600">
                    Điều khoản dịch vụ
                  </a>{' '}
                  và{' '}
                  <a href="#" className="font-medium text-orange-500 hover:text-orange-600">
                    Chính sách bảo mật
                  </a>
                </span>
              </label>

              {/* Submit */}
              <button
                type="submit"
                className="flex w-full items-center justify-center gap-2 rounded-xl bg-orange-500 py-3 text-sm font-semibold text-white shadow-md shadow-orange-200 transition hover:bg-orange-600 active:scale-[0.98]"
              >
                Tạo tài khoản <ChevronRight size={16} />
              </button>
            </form>

            {/* Divider */}
            <div className="my-6 flex items-center gap-3">
              <div className="h-px flex-1 bg-gray-100" />
              <span className="text-xs text-gray-400">hoặc tiếp tục với</span>
              <div className="h-px flex-1 bg-gray-100" />
            </div>

            {/* Google */}
            <button
              type="button"
              className="flex w-full items-center justify-center gap-2 rounded-xl border border-gray-200 bg-white py-2.5 text-sm font-medium text-gray-700 transition hover:border-orange-300 hover:bg-orange-50"
            >
              <svg className="h-4 w-4" viewBox="0 0 24 24">
                <path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" fill="#4285F4" />
                <path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" fill="#34A853" />
                <path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z" fill="#FBBC05" />
                <path d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" fill="#EA4335" />
              </svg>
              Đăng ký với Google
            </button>
          </motion.div>

          {/* Footer link */}
          <motion.p
            initial={hidden}
            animate={visible}
            transition={trans(0.2)}
            className="mt-6 text-center text-sm text-gray-500"
          >
            Đã có tài khoản?{' '}
            <Link to="/login" className="font-semibold text-orange-500 hover:text-orange-600">
              Đăng nhập
            </Link>
          </motion.p>
        </div>
      </main>
    </div>
  );
}
