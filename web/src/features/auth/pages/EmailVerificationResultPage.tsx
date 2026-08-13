import { useEffect, useState } from 'react';
import { motion } from 'framer-motion';
import { Lock, Mail, CheckCircle, XCircle, Loader2, ArrowRight } from 'lucide-react';
import { Link, useSearchParams } from 'react-router-dom';
import { hidden, visible, trans } from '../../../lib/animations';
import { api } from '../../../lib/api';
import { authEndpoints } from '../../../constants/api-endpoints';

type VerificationStatus = 'loading' | 'success' | 'error';

export default function EmailVerificationResultPage() {
  const [searchParams] = useSearchParams();
  const token = searchParams.get('token') ?? '';
  const email = searchParams.get('email') ?? '';
  
  const [status, setStatus] = useState<VerificationStatus>('loading');
  const [errorMessage, setErrorMessage] = useState<string>('');

  useEffect(() => {
    const verifyEmail = async () => {
      if (!token) {
        setStatus('error');
        setErrorMessage('Token xác thực không hợp lệ.');
        return;
      }

      try {
        const response = await api.get(`${authEndpoints.verifyEmail}?token=${encodeURIComponent(token)}`);
        
        if (response.ok) {
          setStatus('success');
        } else {
          const data = await response.json().catch(() => ({ error: 'Đã xảy ra lỗi' }));
          setStatus('error');
          setErrorMessage(data.error || 'Xác thực email thất bại.');
        }
      } catch (error) {
        setStatus('error');
        setErrorMessage('Không thể kết nối đến server. Vui lòng thử lại sau.');
      }
    };

    verifyEmail();
  }, [token]);

  return (
    <div className="relative min-h-screen overflow-hidden bg-[#F9F8F6] font-sans antialiased">
      {/* Background decorations */}
      <div className="pointer-events-none absolute -top-40 -right-40 h-[500px] w-[500px] rounded-full bg-orange-100 opacity-50 blur-3xl" />
      <div className="pointer-events-none absolute bottom-0 -left-32 h-96 w-96 rounded-full bg-orange-50 opacity-70 blur-3xl" />

      {/* Navbar */}
      <header className="relative z-10">
        <div className="mx-auto flex h-16 max-w-7xl items-center px-6">
          <Link to="/" className="flex items-center gap-2 text-xl font-bold tracking-tight text-gray-900">
            <span className="flex h-8 w-8 items-center justify-center rounded-lg bg-orange-500 text-white">
              <Lock size={16} />
            </span>
            E-Box
          </Link>
        </div>
      </header>

      <main className="relative z-10 flex min-h-[calc(100vh-4rem)] items-center justify-center px-4 py-16">
        <div className="w-full max-w-md text-center">
          {/* Loading State */}
          {status === 'loading' && (
            <motion.div
              initial={hidden}
              animate={visible}
              transition={trans(0)}
              className="flex flex-col items-center gap-6"
            >
              <motion.div
                animate={{ rotate: 360 }}
                transition={{ duration: 1, repeat: Infinity, ease: 'linear' }}
                className="mx-auto flex h-24 w-24 items-center justify-center rounded-full bg-orange-100"
              >
                <Loader2 size={48} className="text-orange-500" />
              </motion.div>
              <div>
                <h1 className="text-2xl font-bold tracking-tight text-gray-900">
                  Đang xác thực email...
                </h1>
                <p className="mt-2 text-sm text-gray-500">
                  Vui lòng chờ trong giây lát
                </p>
              </div>
            </motion.div>
          )}

          {/* Success State */}
          {status === 'success' && (
            <motion.div
              initial={{ opacity: 0, scale: 0.9 }}
              animate={{ opacity: 1, scale: 1 }}
              transition={{ duration: 0.5, ease: 'easeOut' }}
              className="flex flex-col items-center gap-6"
            >
              <motion.div
                initial={{ scale: 0 }}
                animate={{ scale: 1 }}
                transition={{ delay: 0.2, type: 'spring', stiffness: 200 }}
                className="mx-auto flex h-24 w-24 items-center justify-center rounded-full bg-green-100"
              >
                <CheckCircle size={56} className="text-green-500" />
              </motion.div>
              
              <div>
                <span className="inline-flex items-center gap-2 rounded-full border border-green-200 bg-green-50 px-4 py-1.5 text-xs font-semibold uppercase tracking-widest text-green-600">
                  Xác thực thành công
                </span>
                <h1 className="mt-4 text-3xl font-extrabold tracking-tight text-gray-900">
                  Email đã được xác minh!
                </h1>
                <p className="mt-3 text-sm leading-relaxed text-gray-500">
                  Chúc mừng bạn! Tài khoản của bạn đã được kích hoạt. 
                  Bây giờ bạn có thể đăng nhập để sử dụng dịch vụ E-Box.
                </p>
              </div>

              <motion.div
                initial={hidden}
                animate={visible}
                transition={trans(0.3)}
                className="mt-2 w-full"
              >
                <Link
                  to="/login"
                  className="flex w-full items-center justify-center gap-2 rounded-xl bg-orange-500 py-3.5 text-sm font-semibold text-white shadow-md shadow-orange-200 transition hover:bg-orange-600 hover:shadow-lg"
                >
                  Đăng nhập ngay
                  <ArrowRight size={16} />
                </Link>
              </motion.div>

              <p className="mt-4 text-sm text-gray-400">
                <Link to="/" className="hover:text-orange-500 transition-colors">
                  Quay về trang chủ
                </Link>
              </p>
            </motion.div>
          )}

          {/* Error State */}
          {status === 'error' && (
            <motion.div
              initial={{ opacity: 0, scale: 0.9 }}
              animate={{ opacity: 1, scale: 1 }}
              transition={{ duration: 0.5, ease: 'easeOut' }}
              className="flex flex-col items-center gap-6"
            >
              <motion.div
                initial={{ scale: 0 }}
                animate={{ scale: 1 }}
                transition={{ delay: 0.2, type: 'spring', stiffness: 200 }}
                className="mx-auto flex h-24 w-24 items-center justify-center rounded-full bg-red-100"
              >
                <XCircle size={56} className="text-red-500" />
              </motion.div>
              
              <div>
                <span className="inline-flex items-center gap-2 rounded-full border border-red-200 bg-red-50 px-4 py-1.5 text-xs font-semibold uppercase tracking-widest text-red-600">
                  Xác thực thất bại
                </span>
                <h1 className="mt-4 text-3xl font-extrabold tracking-tight text-gray-900">
                  Không thể xác minh email
                </h1>
                <p className="mt-3 text-sm leading-relaxed text-gray-500">
                  {errorMessage || 'Có thể link đã hết hạn hoặc không hợp lệ.'}
                </p>
              </div>

              <motion.div
                initial={hidden}
                animate={visible}
                transition={trans(0.3)}
                className="mt-2 w-full space-y-3"
              >
                {email && (
                  <Link
                    to={`/verify-email?email=${encodeURIComponent(email)}`}
                    className="flex w-full items-center justify-center gap-2 rounded-xl border border-gray-200 bg-white py-3.5 text-sm font-semibold text-gray-700 shadow-sm transition hover:bg-gray-50"
                  >
                    <Mail size={16} />
                    Yêu cầu email xác minh mới
                  </Link>
                )}
                <Link
                  to="/login"
                  className="flex w-full items-center justify-center gap-2 rounded-xl bg-orange-500 py-3.5 text-sm font-semibold text-white shadow-md shadow-orange-200 transition hover:bg-orange-600 hover:shadow-lg"
                >
                  Đăng nhập
                  <ArrowRight size={16} />
                </Link>
              </motion.div>

              <p className="mt-4 text-sm text-gray-400">
                <Link to="/" className="hover:text-orange-500 transition-colors">
                  Quay về trang chủ
                </Link>
              </p>
            </motion.div>
          )}
        </div>
      </main>
    </div>
  );
}
