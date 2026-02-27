import { useState } from 'react';
import { motion } from 'framer-motion';
import { Lock, Mail, ChevronRight } from 'lucide-react';
import { Link } from 'react-router-dom';
import { hidden, visible, trans } from '../../../lib/animations';

export default function ForgotPasswordPage() {
  const [email, setEmail] = useState('');
  const [loading, setLoading] = useState(false);
  const [sent, setSent] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    // TODO: POST /api/auth/forgot-password { email }
    await new Promise((r) => setTimeout(r, 1000));
    setLoading(false);
    setSent(true);
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
          <Link to="/login" className="text-sm font-medium text-gray-600 hover:text-orange-500">
            ← Quay lại đăng nhập
          </Link>
        </div>
      </header>

      <main className="relative z-10 flex min-h-[calc(100vh-4rem)] items-center justify-center px-4 py-16">
        <div className="w-full max-w-md">
          <motion.div initial={hidden} animate={visible} transition={trans(0)} className="mb-8 text-center">
            <span className="inline-flex items-center gap-2 rounded-full border border-orange-200 bg-orange-50 px-4 py-1.5 text-xs font-semibold uppercase tracking-widest text-orange-600">
              Quên mật khẩu
            </span>
            <h1 className="mt-4 text-3xl font-extrabold tracking-tight text-gray-900">
              Khôi phục <span className="text-orange-500">mật khẩu</span>
            </h1>
            <p className="mt-2 text-sm text-gray-500">
              Nhập email của bạn, chúng tôi sẽ gửi mã OTP 6 chữ số để đặt lại mật khẩu.
            </p>
          </motion.div>

          <motion.div
            initial={hidden}
            animate={visible}
            transition={trans(0.1)}
            className="rounded-3xl border border-gray-100 bg-white p-8 shadow-xl shadow-orange-100/40"
          >
            {sent ? (
              <div className="text-center">
                <div className="mx-auto mb-4 flex h-16 w-16 items-center justify-center rounded-full bg-green-100">
                  <Mail size={28} className="text-green-500" />
                </div>
                <h2 className="text-lg font-bold text-gray-800">Đã gửi mã OTP!</h2>
                <p className="mt-2 text-sm text-gray-500">
                  Kiểm tra email <span className="font-semibold text-gray-700">{email}</span> để lấy mã OTP (có hiệu lực 5 phút).
                </p>
                <Link
                  to={`/reset-password?email=${encodeURIComponent(email)}`}
                  className="mt-5 flex w-full items-center justify-center gap-2 rounded-xl bg-orange-500 py-3 text-sm font-semibold text-white shadow-md shadow-orange-200 transition hover:bg-orange-600"
                >
                  Nhập mã OTP <ChevronRight size={16} />
                </Link>
              </div>
            ) : (
              <form onSubmit={handleSubmit} className="space-y-5">
                <div>
                  <label className="mb-1.5 block text-sm font-medium text-gray-700">Email</label>
                  <div className="relative">
                    <span className="pointer-events-none absolute inset-y-0 left-4 flex items-center text-gray-400">
                      <Mail size={16} />
                    </span>
                    <input
                      type="email"
                      value={email}
                      onChange={(e) => setEmail(e.target.value)}
                      placeholder="you@example.com"
                      required
                      className="w-full rounded-xl border border-gray-200 bg-gray-50 py-3 pl-11 pr-4 text-sm text-gray-900 outline-none transition placeholder:text-gray-400 focus:border-orange-400 focus:bg-white focus:ring-2 focus:ring-orange-100"
                    />
                  </div>
                </div>
                <button
                  type="submit"
                  disabled={loading}
                  className="flex w-full items-center justify-center gap-2 rounded-xl bg-orange-500 py-3 text-sm font-semibold text-white shadow-md shadow-orange-200 transition hover:bg-orange-600 disabled:opacity-60"
                >
                  {loading ? 'Đang gửi...' : <>Gửi mã OTP <ChevronRight size={16} /></>}
                </button>
              </form>
            )}
          </motion.div>
        </div>
      </main>
    </div>
  );
}
