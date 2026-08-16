import { useState } from 'react';
import { motion } from 'framer-motion';
import {
  Lock,
  Mail,
  Eye,
  EyeOff,
  User,
  Phone,
  ChevronRight,
  AlertCircle,
} from 'lucide-react';
import { Link, useNavigate } from 'react-router-dom';
import { apiFetch } from '../../../lib/api';
import { hidden, visible, trans } from '../../../lib/animations';
import Logo from '../../../components/ui/Logo';
import {
  RegisterForm,
  RegisterErrors,
  extractApiError,
  validateConfirm,
  validateEmail,
  validatePassword,
  validateRegisterForm,
  validateUsername,
  validateVietnamesePhone,
  hasErrors,
} from '../authValidation';

export default function RegisterPage() {
  const navigate = useNavigate();
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirm, setShowConfirm] = useState(false);
  const [form, setForm] = useState<RegisterForm>({
    username: '',
    email: '',
    fullName: '',
    phoneNumber: '',
    password: '',
    confirm: '',
  });
  const [errors, setErrors] = useState<RegisterErrors>({});
  const [touched, setTouched] = useState<Partial<Record<keyof RegisterForm, boolean>>>({});
  const [loading, setLoading] = useState(false);
  const [submitError, setSubmitError] = useState('');

  const updateField = <K extends keyof RegisterForm>(
    key: K,
    value: RegisterForm[K],
  ) => {
    const nextForm = { ...form, [key]: value };
    setForm(nextForm);

    // Real-time validation: re-run only the field that changed, plus
    // `confirm` if the password changed so the mismatch updates
    // immediately.
    const nextErrors: RegisterErrors = { ...errors };
    switch (key) {
      case 'username':
        nextErrors.username = validateUsername(nextForm.username);
        break;
      case 'email':
        nextErrors.email = validateEmail(nextForm.email);
        break;
      case 'phoneNumber':
        nextErrors.phoneNumber = validateVietnamesePhone(nextForm.phoneNumber);
        break;
      case 'password':
        nextErrors.password = validatePassword(nextForm.password);
        nextErrors.confirm = validateConfirm(
          nextForm.confirm,
          nextForm.password,
        );
        break;
      case 'confirm':
        nextErrors.confirm = validateConfirm(nextForm.confirm, nextForm.password);
        break;
    }
    setErrors(nextErrors);
    // Clear the submit error once the user starts editing again.
    if (submitError) setSubmitError('');
  };

  const handleBlur = (field: keyof RegisterForm) => {
    setTouched((t) => ({ ...t, [field]: true }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setSubmitError('');

    // Force validation on every field on submit.
    const allErrors = validateRegisterForm(form);
    setErrors(allErrors);
    setTouched({
      username: true,
      email: true,
      phoneNumber: true,
      password: true,
      confirm: true,
    });
    if (hasErrors(allErrors)) {
      setSubmitError('Vui lòng kiểm tra các trường được tô đỏ.');
      return;
    }

    setLoading(true);
    try {
      const response = await apiFetch('/auth/register', {
        method: 'POST',
        data: {
          username: form.username.trim(),
          email: form.email.trim(),
          password: form.password,
          fullName: form.fullName.trim() || undefined,
          phoneNumber: form.phoneNumber.trim() || undefined,
        },
      });

      if (!response.ok) {
        const errorMessage = await extractApiError(
          response,
          'Đăng ký thất bại. Vui lòng thử lại.',
        );
        throw new Error(errorMessage);
      }

      navigate(`/verify-email?email=${encodeURIComponent(form.email.trim())}`);
    } catch (err: any) {
      setSubmitError(err.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="relative min-h-screen overflow-hidden bg-[#F9F8F6] font-sans antialiased">
      {/* Decorative blobs */}
      <div className="pointer-events-none absolute -top-40 -right-40 h-[500px] w-[500px] rounded-full bg-orange-100 opacity-50 blur-3xl" />
      <div className="pointer-events-none absolute bottom-0 -left-32 h-96 w-96 rounded-full bg-orange-50 opacity-70 blur-3xl" />

      {/* Navbar */}
      <header className="relative z-10">
        <div className="mx-auto flex h-24 max-w-7xl items-center justify-between px-6">
          <Link to="/" className="flex items-center gap-2 text-xl font-bold tracking-tight text-gray-900">
            <Logo size={64} showText={false} />
            E-Box
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
              Đăng ký <span className="text-orange-500">E-box</span>
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
            <form onSubmit={handleSubmit} noValidate className="space-y-5">
              {/* Username */}
              <FormField
                label="Tên đăng nhập"
                required
                icon={<User size={16} />}
                name="username"
                value={form.username}
                onChange={(v) => updateField('username', v)}
                onBlur={() => handleBlur('username')}
                error={touched.username ? errors.username : undefined}
                placeholder="vd: nguyenvana"
                autoComplete="username"
              />

              {/* Full name */}
              <FormField
                label="Họ và tên"
                icon={<User size={16} />}
                name="fullName"
                value={form.fullName}
                onChange={(v) => updateField('fullName', v)}
                onBlur={() => handleBlur('fullName')}
                placeholder="Nguyễn Văn A"
                autoComplete="name"
              />

              {/* Email */}
              <FormField
                label="Email"
                required
                icon={<Mail size={16} />}
                name="email"
                type="email"
                value={form.email}
                onChange={(v) => updateField('email', v)}
                onBlur={() => handleBlur('email')}
                error={touched.email ? errors.email : undefined}
                placeholder="you@example.com"
                autoComplete="email"
              />

              {/* Phone number */}
              <FormField
                label="Số điện thoại"
                icon={<Phone size={16} />}
                name="phoneNumber"
                type="tel"
                value={form.phoneNumber}
                onChange={(v) => updateField('phoneNumber', v)}
                onBlur={() => handleBlur('phoneNumber')}
                error={touched.phoneNumber ? errors.phoneNumber : undefined}
                placeholder="0912345678"
                autoComplete="tel"
              />

              {/* Password */}
              <FormField
                label="Mật khẩu"
                required
                icon={<Lock size={16} />}
                name="password"
                type={showPassword ? 'text' : 'password'}
                value={form.password}
                onChange={(v) => updateField('password', v)}
                onBlur={() => handleBlur('password')}
                error={touched.password ? errors.password : undefined}
                placeholder="Tối thiểu 8 ký tự, có chữ hoa, chữ thường và số"
                autoComplete="new-password"
                trailing={
                  <button
                    type="button"
                    onClick={() => setShowPassword(!showPassword)}
                    className="text-gray-400 transition hover:text-gray-600"
                    aria-label={showPassword ? 'Ẩn mật khẩu' : 'Hiện mật khẩu'}
                  >
                    {showPassword ? <EyeOff size={16} /> : <Eye size={16} />}
                  </button>
                }
              />

              {/* Confirm password */}
              <FormField
                label="Xác nhận mật khẩu"
                required
                icon={<Lock size={16} />}
                name="confirm"
                type={showConfirm ? 'text' : 'password'}
                value={form.confirm}
                onChange={(v) => updateField('confirm', v)}
                onBlur={() => handleBlur('confirm')}
                error={touched.confirm ? errors.confirm : undefined}
                placeholder="Nhập lại mật khẩu"
                autoComplete="new-password"
                trailing={
                  <button
                    type="button"
                    onClick={() => setShowConfirm(!showConfirm)}
                    className="text-gray-400 transition hover:text-gray-600"
                    aria-label={showConfirm ? 'Ẩn mật khẩu' : 'Hiện mật khẩu'}
                  >
                    {showConfirm ? <EyeOff size={16} /> : <Eye size={16} />}
                  </button>
                }
              />

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

              {submitError && (
                <div
                  role="alert"
                  className="flex items-start gap-2 whitespace-pre-line rounded-xl border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-600"
                >
                  <AlertCircle size={16} className="mt-0.5 shrink-0" />
                  <span>{submitError}</span>
                </div>
              )}

              {/* Submit */}
              <button
                type="submit"
                disabled={loading}
                className="flex w-full items-center justify-center gap-2 rounded-xl bg-orange-500 py-3 text-sm font-semibold text-white shadow-md shadow-orange-200 transition hover:bg-orange-600 active:scale-[0.98] disabled:opacity-70"
              >
                {loading ? 'Đang tạo tài khoản...' : <>Tạo tài khoản <ChevronRight size={16} /></>}
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

/**
 * Reusable styled input with an optional inline error.
 * Keeps the JSX of the register page flat. Error takes precedence
 * over the regular focus ring — it switches the border + ring to red
 * and renders the message underneath.
 */
interface FormFieldProps {
  label: string;
  name: string;
  value: string;
  onChange: (value: string) => void;
  onBlur?: () => void;
  icon?: React.ReactNode;
  trailing?: React.ReactNode;
  type?: string;
  required?: boolean;
  error?: string;
  placeholder?: string;
  autoComplete?: string;
}

function FormField({
  label,
  name,
  value,
  onChange,
  onBlur,
  icon,
  trailing,
  type = 'text',
  required,
  error,
  placeholder,
  autoComplete,
}: FormFieldProps) {
  const hasError = !!error;
  return (
    <div>
      <label className="mb-1.5 block text-sm font-medium text-gray-700">
        {label}
        {required && <span className="text-orange-500"> *</span>}
      </label>
      <div className="relative">
        {icon && (
          <span
            className={[
              'pointer-events-none absolute inset-y-0 left-4 flex items-center',
              hasError ? 'text-red-400' : 'text-gray-400',
            ].join(' ')}
          >
            {icon}
          </span>
        )}
        <input
          type={type}
          name={name}
          value={value}
          onChange={(e) => onChange(e.target.value)}
          onBlur={onBlur}
          placeholder={placeholder}
          autoComplete={autoComplete}
          aria-invalid={hasError || undefined}
          className={[
            'w-full rounded-xl border bg-gray-50 py-3 pl-11 pr-4 text-sm outline-none transition placeholder:text-gray-400 focus:bg-white focus:ring-2',
            hasError
              ? 'border-red-300 text-red-900 focus:border-red-400 focus:ring-red-100'
              : 'border-gray-200 text-gray-900 focus:border-orange-400 focus:ring-orange-100',
            trailing ? 'pr-11' : '',
          ].join(' ')}
        />
        {trailing && (
          <span className="absolute inset-y-0 right-4 flex items-center">{trailing}</span>
        )}
      </div>
      {hasError && (
        <p className="mt-1.5 flex items-center gap-1.5 text-xs text-red-600">
          <AlertCircle size={12} />
          <span>{error}</span>
        </p>
      )}
    </div>
  );
}
