import { useState, useRef } from 'react';
import { motion } from 'framer-motion';
import { Lock, Eye, EyeOff, CheckCircle, ChevronRight } from 'lucide-react';
import { Link, useSearchParams, useNavigate } from 'react-router-dom';
import { hidden, visible, trans } from '../../../lib/animations';

export default function ResetPasswordPage() {
  const [searchParams] = useSearchParams();
  const email = searchParams.get('email') ?? '';
  const navigate = useNavigate();

  const [otp, setOtp] = useState(['', '', '', '', '', '']);
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const [done, setDone] = useState(false);
  const inputRefs = useRef<(HTMLInputElement | null)[]>([]);

  const handleOtpChange = (index: number, val: string) => {
    if (!/^\d*$/.test(val)) return;
    const next = [...otp];
    next[index] = val.slice(-1);
    setOtp(next);
    if (val && index < 5) inputRefs.current[index + 1]?.focus();
  };

  const handleOtpKeyDown = (index: number, e: React.KeyboardEvent) => {
    if (e.key === 'Backspace' && !otp[index] && index > 0) {
      inputRefs.current[index - 1]?.focus();
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    // TODO: POST /api/auth/reset-password { email, otp: otp.join(''), newPassword: password }
    await new Promise((r) => setTimeout(r, 1000));
    setLoading(false);
    setDone(true);
    setTimeout(() => navigate('/login'), 2500);
  };

  return (
    <div className="relative min-h-screen overflow-hidden bg-[#F9F8F6] font-sans antialiased">
      <div className="pointer-events-none absolute -top-40 -right-40 h-[500px] w-[500px] rounded-full bg-orange-100 opacity-50 blur-3xl" />
      <div className="pointer-events-none absolute bottom-0 -left-32 h-96 w-96 rounded-full bg-orange-50 opacity-70 blur-3xl" />

      <header className="relative z-10">
        <div className="mx-auto flex h-16 max-w-7xl items-center justify-between px-6">
          <Link to="/" className="flex items-center gap-2 text-xl font-bold tracking-tight text-gray-900">
            <span className="flex h-8 w-8 items-center justify-center rounded-lg bg-orange-500 text-white">
              <Lock size={16} />
            </span>
            LuxeLock
          </Link>
          <Link to="/forgot-password" className="text-sm font-medium text-gray-600 hover:text-orange-500">
            ← Gửi lại OTP
          </Link>
        </div>
      </header>

      <main className="relative z-10 flex min-h-[calc(100vh-4rem)] items-center justify-center px-4 py-16">
        <div className="w-full max-w-md">
          <motion.div initial={hidden} animate={visible} transition={trans(0)} className="mb-8 text-center">
            <span className="inline-flex items-center gap-2 rounded-full border border-orange-200 bg-orange-50 px-4 py-1.5 text-xs font-semibold uppercase tracking-widest text-orange-600">
              Đặt lại mật khẩu
            </span>
            <h1 className="mt-4 text-3xl font-extrabold tracking-tight text-gray-900">
              Nhập mã <span className="text-orange-500">OTP</span>
            </h1>
            <p className="mt-2 text-sm text-gray-500">
              Mã 6 chữ số đã được gửi đến <span className="font-semibold text-gray-700">{email}</span>
            </p>
          </motion.div>

          <motion.div
            initial={hidden}
            animate={visible}
            transition={trans(0.1)}
            className="rounded-3xl border border-gray-100 bg-white p-8 shadow-xl shadow-orange-100/40"
          >
            {done ? (
              <div className="flex flex-col items-center gap-3 text-center">
                <CheckCircle size={40} className="text-green-500" />
                <h2 className="text-lg font-bold text-gray-800">Mật khẩu đã được cập nhật!</h2>
                <p className="text-sm text-gray-500">Đang chuyển đến trang đăng nhập...</p>
              </div>
            ) : (
              <form onSubmit={handleSubmit} className="space-y-6">
                {/* OTP inputs */}
                <div>
                  <label className="mb-3 block text-center text-sm font-medium text-gray-700">
                    Mã OTP (6 chữ số)
                  </label>
                  <div className="flex justify-center gap-3">
                    {otp.map((digit, i) => (
                      <input
                        key={i}
                        ref={(el) => { inputRefs.current[i] = el; }}
                        type="text"
                        inputMode="numeric"
                        maxLength={1}
                        value={digit}
                        onChange={(e) => handleOtpChange(i, e.target.value)}
                        onKeyDown={(e) => handleOtpKeyDown(i, e)}
                        className="h-12 w-12 rounded-xl border border-gray-200 bg-gray-50 text-center text-lg font-bold text-gray-900 outline-none transition focus:border-orange-400 focus:bg-white focus:ring-2 focus:ring-orange-100"
                      />
                    ))}
                  </div>
                </div>

                {/* New password */}
                <div>
                  <label className="mb-1.5 block text-sm font-medium text-gray-700">
                    Mật khẩu mới <span className="text-orange-500">*</span>
                  </label>
                  <div className="relative">
                    <span className="pointer-events-none absolute inset-y-0 left-4 flex items-center text-gray-400">
                      <Lock size={16} />
                    </span>
                    <input
                      type={showPassword ? 'text' : 'password'}
                      value={password}
                      onChange={(e) => setPassword(e.target.value)}
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

                <button
                  type="submit"
                  disabled={loading || otp.some((d) => !d)}
                  className="flex w-full items-center justify-center gap-2 rounded-xl bg-orange-500 py-3 text-sm font-semibold text-white shadow-md shadow-orange-200 transition hover:bg-orange-600 disabled:opacity-60"
                >
                  {loading ? 'Đang xử lý...' : <>Đặt lại mật khẩu <ChevronRight size={16} /></>}
                </button>
              </form>
            )}
          </motion.div>
        </div>
      </main>
    </div>
  );
}
