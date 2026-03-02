import { useState } from 'react';
import { motion } from 'framer-motion';
import { Lock, Mail, RefreshCw, CheckCircle } from 'lucide-react';
import { Link, useSearchParams } from 'react-router-dom';
import { hidden, visible, trans } from '../../../lib/animations';

export default function VerifyEmailPage() {
  const [searchParams] = useSearchParams();
  const email = searchParams.get('email') ?? '';
  const [resending, setResending] = useState(false);
  const [resent, setResent] = useState(false);

  const handleResend = async (e: React.FormEvent) => {
    e.preventDefault();
    setResending(true);
    // TODO: POST /api/auth/resend-verification { email }
    await new Promise((r) => setTimeout(r, 1000));
    setResending(false);
    setResent(true);
  };

  return (
    <div className="relative min-h-screen overflow-hidden bg-[#F9F8F6] font-sans antialiased">
      <div className="pointer-events-none absolute -top-40 -right-40 h-[500px] w-[500px] rounded-full bg-orange-100 opacity-50 blur-3xl" />
      <div className="pointer-events-none absolute bottom-0 -left-32 h-96 w-96 rounded-full bg-orange-50 opacity-70 blur-3xl" />

      {/* Navbar */}
      <header className="relative z-10">
        <div className="mx-auto flex h-16 max-w-7xl items-center px-6">
          <Link to="/" className="flex items-center gap-2 text-xl font-bold tracking-tight text-gray-900">
            <span className="flex h-8 w-8 items-center justify-center rounded-lg bg-orange-500 text-white">
              <Lock size={16} />
            </span>
            LuxeLock
          </Link>
        </div>
      </header>

      <main className="relative z-10 flex min-h-[calc(100vh-4rem)] items-center justify-center px-4 py-16">
        <div className="w-full max-w-md text-center">
          <motion.div initial={hidden} animate={visible} transition={trans(0)}>
            <div className="mx-auto mb-6 flex h-20 w-20 items-center justify-center rounded-full bg-orange-100">
              <Mail size={36} className="text-orange-500" />
            </div>
            <span className="inline-flex items-center gap-2 rounded-full border border-orange-200 bg-orange-50 px-4 py-1.5 text-xs font-semibold uppercase tracking-widest text-orange-600">
              Xác minh email
            </span>
            <h1 className="mt-4 text-3xl font-extrabold tracking-tight text-gray-900">
              Kiểm tra hộp thư của bạn
            </h1>
            <p className="mt-3 text-sm leading-relaxed text-gray-500">
              Chúng tôi đã gửi link xác minh đến{' '}
              {email && (
                <span className="font-semibold text-gray-700">{email}</span>
              )}
              . Vui lòng nhấp vào link trong email để kích hoạt tài khoản.
            </p>
          </motion.div>

          <motion.div
            initial={hidden}
            animate={visible}
            transition={trans(0.1)}
            className="mt-8 rounded-3xl border border-gray-100 bg-white p-8 shadow-xl shadow-orange-100/40"
          >
            {resent ? (
              <div className="flex flex-col items-center gap-3 text-center">
                <CheckCircle size={32} className="text-green-500" />
                <p className="text-sm font-medium text-gray-700">
                  Email xác minh đã được gửi lại!
                </p>
                <p className="text-xs text-gray-400">
                  Hãy kiểm tra cả thư mục spam nếu không thấy.
                </p>
              </div>
            ) : (
              <>
                <p className="mb-5 text-sm text-gray-500">
                  Không nhận được email? Nhập lại địa chỉ email và chúng tôi sẽ gửi lại.
                </p>
                <form onSubmit={handleResend} className="space-y-4">
                  <div className="relative">
                    <span className="pointer-events-none absolute inset-y-0 left-4 flex items-center text-gray-400">
                      <Mail size={16} />
                    </span>
                    <input
                      type="email"
                      defaultValue={email}
                      name="email"
                      placeholder="you@example.com"
                      required
                      className="w-full rounded-xl border border-gray-200 bg-gray-50 py-3 pl-11 pr-4 text-sm text-gray-900 outline-none transition placeholder:text-gray-400 focus:border-orange-400 focus:bg-white focus:ring-2 focus:ring-orange-100"
                    />
                  </div>
                  <button
                    type="submit"
                    disabled={resending}
                    className="flex w-full items-center justify-center gap-2 rounded-xl bg-orange-500 py-3 text-sm font-semibold text-white shadow-md shadow-orange-200 transition hover:bg-orange-600 disabled:opacity-60"
                  >
                    {resending ? (
                      <RefreshCw size={16} className="animate-spin" />
                    ) : (
                      <RefreshCw size={16} />
                    )}
                    Gửi lại email xác minh
                  </button>
                </form>
              </>
            )}
          </motion.div>

          <motion.p
            initial={hidden}
            animate={visible}
            transition={trans(0.2)}
            className="mt-6 text-sm text-gray-500"
          >
            Đã xác minh?{' '}
            <Link to="/login" className="font-semibold text-orange-500 hover:text-orange-600">
              Đăng nhập
            </Link>
          </motion.p>
        </div>
      </main>
    </div>
  );
}
