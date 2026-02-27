import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { User, Mail, Phone, Lock, Eye, EyeOff, Save, ChevronRight } from 'lucide-react';
import AppHeader from '../../../components/layout/AppHeader';
import { hidden, visible, trans } from '../../../lib/animations';
import { getUserById, SeedUser as UserProfile } from '../../../mocks/seed';

// Simulated logged-in user — set by login page, replace with real token when backend is ready
const CURRENT_USER_ID = localStorage.getItem('userId') ?? 'u-001';

type Tab = 'profile' | 'password';

export default function ProfilePage() {
  const [tab, setTab] = useState<Tab>('profile');
  const [user, setUser] = useState<UserProfile | null>(null);
  const [loading, setLoading] = useState(true);

  // Profile form
  const [email, setEmail] = useState('');
  const [fullName, setFullName] = useState('');
  const [profileSaving, setProfileSaving] = useState(false);
  const [profileSaved, setProfileSaved] = useState(false);

  // Password form
  const [currentPassword, setCurrentPassword] = useState('');
  const [newPassword, setNewPassword] = useState('');
  const [showCurrent, setShowCurrent] = useState(false);
  const [showNew, setShowNew] = useState(false);
  const [pwSaving, setPwSaving] = useState(false);
  const [pwSaved, setPwSaved] = useState(false);

  useEffect(() => {
    // Seed data — swap for GET /api/users/me when backend is ready
    setTimeout(() => {
      const u = getUserById(CURRENT_USER_ID) ?? null;
      setUser(u);
      setEmail(u?.email ?? '');
      setFullName(u?.fullName ?? '');
      setLoading(false);
    }, 300);
  }, []);

  const handleProfileSave = async (e: React.FormEvent) => {
    e.preventDefault();
    setProfileSaving(true);
    // TODO: PUT /api/users/me { email, fullName }
    await new Promise((r) => setTimeout(r, 800));
    setProfileSaving(false);
    setProfileSaved(true);
    setTimeout(() => setProfileSaved(false), 3000);
  };

  const handlePasswordSave = async (e: React.FormEvent) => {
    e.preventDefault();
    setPwSaving(true);
    // TODO: POST /api/users/me/change-password { currentPassword, newPassword }
    await new Promise((r) => setTimeout(r, 800));
    setPwSaving(false);
    setPwSaved(true);
    setCurrentPassword('');
    setNewPassword('');
    setTimeout(() => setPwSaved(false), 3000);
  };

  if (loading) return (
    <div className="min-h-screen bg-[#F9F8F6]"><AppHeader />
      <div className="flex h-96 items-center justify-center">
        <div className="h-8 w-8 animate-spin rounded-full border-4 border-orange-500 border-t-transparent" />
      </div>
    </div>
  );

  return (
    <div className="min-h-screen bg-[#F9F8F6] font-sans antialiased">
      <AppHeader />

      <main className="mx-auto max-w-2xl px-4 py-10 lg:px-8">
        {/* Header */}
        <motion.div initial={hidden} animate={visible} transition={trans(0)} className="mb-8">
          <span className="inline-flex items-center gap-2 rounded-full border border-orange-200 bg-orange-50 px-4 py-1.5 text-xs font-semibold uppercase tracking-widest text-orange-600">
            Tài khoản
          </span>
          <h1 className="mt-3 text-3xl font-extrabold tracking-tight text-gray-900">
            Hồ sơ <span className="text-orange-500">của tôi</span>
          </h1>
        </motion.div>

        {/* Avatar card */}
        <motion.div initial={hidden} animate={visible} transition={trans(0.1)} className="mb-6 flex items-center gap-4 rounded-3xl border border-gray-100 bg-white p-5 shadow-sm">
          <div className="flex h-16 w-16 items-center justify-center rounded-full bg-gradient-to-br from-orange-400 to-orange-600 text-2xl font-extrabold text-white">
            {user?.fullName?.[0] ?? user?.username?.[0] ?? 'U'}
          </div>
          <div>
            <p className="font-bold text-gray-900">{user?.fullName ?? user?.username}</p>
            <p className="text-sm text-gray-500">@{user?.username}</p>
            <span className="mt-1 inline-block rounded-full bg-orange-100 px-2.5 py-0.5 text-xs font-semibold text-orange-600">
              {user?.role}
            </span>
          </div>
          <div className="ml-auto text-right text-xs text-gray-400">
            <p>Thành viên từ</p>
            <p className="font-medium text-gray-600">{new Date(user!.createdAt).toLocaleDateString('vi-VN')}</p>
          </div>
        </motion.div>

        {/* Tabs */}
        <motion.div initial={hidden} animate={visible} transition={trans(0.15)} className="mb-5 flex gap-2">
          {(['profile', 'password'] as Tab[]).map((t) => (
            <button
              key={t}
              onClick={() => setTab(t)}
              className={`rounded-xl px-5 py-2.5 text-sm font-medium transition ${
                tab === t
                  ? 'bg-orange-500 text-white shadow-md shadow-orange-200'
                  : 'border border-gray-200 bg-white text-gray-600 hover:border-orange-300 hover:text-orange-500'
              }`}
            >
              {t === 'profile' ? 'Thông tin cá nhân' : 'Đổi mật khẩu'}
            </button>
          ))}
        </motion.div>

        {/* Profile tab */}
        {tab === 'profile' && (
          <motion.div initial={hidden} animate={visible} transition={trans(0)} className="rounded-3xl border border-gray-100 bg-white p-6 shadow-sm">
            <form onSubmit={handleProfileSave} className="space-y-5">
              {/* Username (readonly) */}
              <div>
                <label className="mb-1.5 block text-sm font-medium text-gray-700">Tên đăng nhập</label>
                <div className="relative">
                  <span className="pointer-events-none absolute inset-y-0 left-4 flex items-center text-gray-400"><User size={16} /></span>
                  <input value={user?.username} disabled className="w-full rounded-xl border border-gray-200 bg-gray-100 py-3 pl-11 pr-4 text-sm text-gray-500 cursor-not-allowed" />
                </div>
                <p className="mt-1 text-xs text-gray-400">Tên đăng nhập không thể thay đổi.</p>
              </div>

              {/* Full name */}
              <div>
                <label className="mb-1.5 block text-sm font-medium text-gray-700">Họ và tên</label>
                <div className="relative">
                  <span className="pointer-events-none absolute inset-y-0 left-4 flex items-center text-gray-400"><User size={16} /></span>
                  <input
                    type="text"
                    value={fullName}
                    onChange={(e) => setFullName(e.target.value)}
                    placeholder="Nguyễn Văn A"
                    className="w-full rounded-xl border border-gray-200 bg-gray-50 py-3 pl-11 pr-4 text-sm text-gray-900 outline-none transition placeholder:text-gray-400 focus:border-orange-400 focus:bg-white focus:ring-2 focus:ring-orange-100"
                  />
                </div>
              </div>

              {/* Email */}
              <div>
                <label className="mb-1.5 block text-sm font-medium text-gray-700">Email</label>
                <div className="relative">
                  <span className="pointer-events-none absolute inset-y-0 left-4 flex items-center text-gray-400"><Mail size={16} /></span>
                  <input
                    type="email"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    className="w-full rounded-xl border border-gray-200 bg-gray-50 py-3 pl-11 pr-4 text-sm text-gray-900 outline-none transition placeholder:text-gray-400 focus:border-orange-400 focus:bg-white focus:ring-2 focus:ring-orange-100"
                  />
                </div>
              </div>

              {/* Phone (readonly, from registration) */}
              <div>
                <label className="mb-1.5 block text-sm font-medium text-gray-700">Số điện thoại</label>
                <div className="relative">
                  <span className="pointer-events-none absolute inset-y-0 left-4 flex items-center text-gray-400"><Phone size={16} /></span>
                  <input value={user?.phoneNumber ?? ''} disabled className="w-full rounded-xl border border-gray-200 bg-gray-100 py-3 pl-11 pr-4 text-sm text-gray-500 cursor-not-allowed" />
                </div>
              </div>

              <button
                type="submit"
                disabled={profileSaving}
                className="flex w-full items-center justify-center gap-2 rounded-xl bg-orange-500 py-3 text-sm font-semibold text-white shadow-md shadow-orange-200 transition hover:bg-orange-600 disabled:opacity-60"
              >
                {profileSaved ? '✓ Đã lưu!' : profileSaving ? 'Đang lưu...' : <><Save size={15} /> Lưu thay đổi</>}
              </button>
            </form>
          </motion.div>
        )}

        {/* Password tab */}
        {tab === 'password' && (
          <motion.div initial={hidden} animate={visible} transition={trans(0)} className="rounded-3xl border border-gray-100 bg-white p-6 shadow-sm">
            <form onSubmit={handlePasswordSave} className="space-y-5">
              <div>
                <label className="mb-1.5 block text-sm font-medium text-gray-700">Mật khẩu hiện tại <span className="text-orange-500">*</span></label>
                <div className="relative">
                  <span className="pointer-events-none absolute inset-y-0 left-4 flex items-center text-gray-400"><Lock size={16} /></span>
                  <input
                    type={showCurrent ? 'text' : 'password'}
                    value={currentPassword}
                    onChange={(e) => setCurrentPassword(e.target.value)}
                    placeholder="••••••••"
                    required
                    className="w-full rounded-xl border border-gray-200 bg-gray-50 py-3 pl-11 pr-11 text-sm text-gray-900 outline-none transition placeholder:text-gray-400 focus:border-orange-400 focus:bg-white focus:ring-2 focus:ring-orange-100"
                  />
                  <button type="button" onClick={() => setShowCurrent(!showCurrent)} className="absolute inset-y-0 right-4 flex items-center text-gray-400 hover:text-gray-600">
                    {showCurrent ? <EyeOff size={16} /> : <Eye size={16} />}
                  </button>
                </div>
              </div>

              <div>
                <label className="mb-1.5 block text-sm font-medium text-gray-700">Mật khẩu mới <span className="text-orange-500">*</span></label>
                <div className="relative">
                  <span className="pointer-events-none absolute inset-y-0 left-4 flex items-center text-gray-400"><Lock size={16} /></span>
                  <input
                    type={showNew ? 'text' : 'password'}
                    value={newPassword}
                    onChange={(e) => setNewPassword(e.target.value)}
                    placeholder="Tối thiểu 6 ký tự"
                    required
                    minLength={6}
                    className="w-full rounded-xl border border-gray-200 bg-gray-50 py-3 pl-11 pr-11 text-sm text-gray-900 outline-none transition placeholder:text-gray-400 focus:border-orange-400 focus:bg-white focus:ring-2 focus:ring-orange-100"
                  />
                  <button type="button" onClick={() => setShowNew(!showNew)} className="absolute inset-y-0 right-4 flex items-center text-gray-400 hover:text-gray-600">
                    {showNew ? <EyeOff size={16} /> : <Eye size={16} />}
                  </button>
                </div>
              </div>

              <button
                type="submit"
                disabled={pwSaving}
                className="flex w-full items-center justify-center gap-2 rounded-xl bg-orange-500 py-3 text-sm font-semibold text-white shadow-md shadow-orange-200 transition hover:bg-orange-600 disabled:opacity-60"
              >
                {pwSaved ? '✓ Đã đổi mật khẩu!' : pwSaving ? 'Đang xử lý...' : <>Đổi mật khẩu <ChevronRight size={16} /></>}
              </button>
            </form>
          </motion.div>
        )}
      </main>
    </div>
  );
}
