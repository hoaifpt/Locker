import { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { motion } from 'framer-motion';
import { Users, Package, Clock, CreditCard, TrendingUp, ChevronRight, ShieldCheck, MessageSquare, UserPlus, BarChart3 } from 'lucide-react';
import AdminSidebar from '../components/AdminSidebar';
import { hidden, visible, trans } from '../../../lib/animations';
import { apiFetch } from '../../../lib/api';
import { useToast } from '../../../context/ToastContext';
import { SEED_ORDERS, SEED_BOOKINGS, SEED_PAYMENTS } from '../../../mocks/seed';

type AdminUser = {
  id: string;
  username: string;
  email: string;
  fullName: string | null;
  phoneNumber: string | null;
  role: string;
  isActive: boolean;
  createdAt: string;
};

const stats = [
  { label: 'Tổng Users', key: 'users', icon: Users, color: 'bg-blue-500' },
  { label: 'Đơn hàng', key: 'orders', icon: Package, color: 'bg-orange-500' },
  { label: 'Bookings', key: 'bookings', icon: Clock, color: 'bg-green-500' },
  { label: 'Payments', key: 'payments', icon: CreditCard, color: 'bg-purple-500' },
  { label: 'Doanh thu', key: 'revenue', icon: TrendingUp, color: 'bg-emerald-500' },
];

const quickActions = [
  { to: '/users', icon: Users, label: 'Quản lý Users', desc: 'Xem, thêm, sửa, xóa người dùng', color: 'from-blue-500 to-blue-600', bgColor: 'bg-blue-500' },
  { to: '/feedbacks', icon: MessageSquare, label: 'Xem Feedback', desc: 'Review phản hồi từ người dùng', color: 'from-purple-500 to-purple-600', bgColor: 'bg-purple-500' },
  { to: '/users', icon: UserPlus, label: 'Thêm User mới', desc: 'Tạo tài khoản người dùng', color: 'from-emerald-500 to-emerald-600', bgColor: 'bg-emerald-500' },
];

export default function AdminDashboardPage() {
  const [users, setUsers] = useState<AdminUser[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const { show: showToast } = useToast();

  useEffect(() => {
    const fetchAdminData = async () => {
      setLoading(true);
      setError(null);
      try {
        const res = await apiFetch('/admin/users');
        if (!res.ok) {
          if (res.status === 401 || res.status === 403) {
            throw new Error('Bạn không có quyền truy cập trang này. Vui lòng đăng nhập tài khoản Admin.');
          }
          throw new Error('Không thể tải dữ liệu.');
        }
        const data = await res.json() as AdminUser[];
        setUsers(data);
      } catch (err) {
        const message = err instanceof Error ? err.message : 'Lỗi không xác định';
        setError(message);
        showToast(message, 'error');
      } finally {
        setLoading(false);
      }
    };
    fetchAdminData();
  }, [showToast]);

  const otherStats = {
    users: users.length,
    orders: SEED_ORDERS.length,
    bookings: SEED_BOOKINGS.length,
    payments: SEED_PAYMENTS.length,
    revenue: SEED_PAYMENTS.filter(p => p.status === 'Completed').reduce((sum, p) => sum + p.amount, 0),
  };

  const recentUsers = [...users]
    .sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime())
    .slice(0, 6);

  const statsValues = {
    users: otherStats.users,
    orders: otherStats.orders,
    bookings: otherStats.bookings,
    payments: otherStats.payments,
    revenue: (otherStats.revenue / 1000000).toFixed(1) + 'M',
  };

  return (
    <div className="flex min-h-screen bg-[#F9F8F6]">
      <AdminSidebar />
      <main className="ml-64 flex-1 px-8 py-8">
        {/* Header */}
        <motion.div initial={hidden} animate={visible} transition={trans(0)}>
          <span className="inline-flex items-center gap-2 rounded-full border border-purple-200 bg-purple-50 px-4 py-1.5 text-xs font-semibold uppercase tracking-widest text-purple-600">
            <ShieldCheck size={13} /> Quản trị viên
          </span>
          <h1 className="mt-3 text-3xl font-extrabold tracking-tight text-gray-900">Bảng điều khiển</h1>
          <p className="mt-1 text-sm text-gray-500">Xem tổng quan hệ thống E-Box Locker</p>
        </motion.div>

        {/* Stats Cards */}
        <motion.div initial={hidden} animate={visible} transition={trans(0.1)} className="mt-6 grid grid-cols-2 gap-4 lg:grid-cols-5">
          {stats.map((s) => (
            <div key={s.key} className="rounded-2xl border border-gray-100 bg-white p-5 shadow-sm">
              <div className={`mb-3 flex h-9 w-9 items-center justify-center rounded-xl ${s.color}`}>
                <s.icon size={16} className="text-white" />
              </div>
              {loading && s.key === 'users' ? (
                <div className="h-7 w-12 animate-pulse rounded-md bg-gray-200" />
              ) : (
                <p className="text-2xl font-extrabold text-gray-900">{statsValues[s.key as keyof typeof statsValues]}</p>
              )}
              <p className="mt-1 text-xs text-gray-400">{s.label}</p>
            </div>
          ))}
        </motion.div>

        {/* Main Content Grid */}
        <div className="mt-8 grid gap-6 lg:grid-cols-3">
          {/* Recent Users Table */}
          <motion.div initial={hidden} animate={visible} transition={trans(0.15)} className="lg:col-span-2">
            <div className="flex items-center justify-between">
              <h2 className="text-lg font-bold text-gray-900">Người dùng gần đây</h2>
              <Link to="/users" className="flex items-center gap-1 text-sm font-semibold text-orange-500 hover:text-orange-600">
                Xem tất cả <ChevronRight size={14} />
              </Link>
            </div>
            <div className="mt-4 overflow-hidden rounded-2xl border border-gray-100 bg-white shadow-sm">
              <table className="w-full text-sm">
                <thead className="border-b border-gray-100 bg-gray-50">
                  <tr>
                    <th className="px-4 py-3 text-left font-semibold text-gray-600">Tên</th>
                    <th className="px-4 py-3 text-left font-semibold text-gray-600">Email</th>
                    <th className="px-4 py-3 text-left font-semibold text-gray-600">Role</th>
                    <th className="px-4 py-3 text-left font-semibold text-gray-600">Trạng thái</th>
                  </tr>
                </thead>
                <tbody>
                  {loading ? (
                    [...Array(5)].map((_, i) => (
                      <tr key={i} className="border-b border-gray-50">
                        <td className="px-4 py-3"><div className="h-4 w-3/4 animate-pulse rounded bg-gray-200" /></td>
                        <td className="px-4 py-3"><div className="h-4 w-full animate-pulse rounded bg-gray-200" /></td>
                        <td className="px-4 py-3"><div className="h-4 w-1/2 animate-pulse rounded bg-gray-200" /></td>
                        <td className="px-4 py-3"><div className="h-4 w-1/2 animate-pulse rounded bg-gray-200" /></td>
                      </tr>
                    ))
                  ) : recentUsers.length === 0 ? (
                    <tr>
                      <td colSpan={4} className="px-4 py-10 text-center text-gray-400">Chưa có người dùng nào</td>
                    </tr>
                  ) : (
                    recentUsers.map(u => (
                      <tr key={u.id} className="border-b border-gray-50 transition hover:bg-orange-50/30">
                        <td className="px-4 py-3 font-medium text-gray-900">{u.fullName ?? u.username}</td>
                        <td className="px-4 py-3 text-gray-500">{u.email}</td>
                        <td className="px-4 py-3">
                          <span className={`rounded-full px-2 py-0.5 text-xs font-semibold ${
                            u.role === 'Admin' ? 'bg-purple-100 text-purple-600' :
                            u.role === 'Shipper' ? 'bg-blue-100 text-blue-600' :
                            'bg-gray-100 text-gray-600'
                          }`}>{u.role}</span>
                        </td>
                        <td className="px-4 py-3">
                          <span className={`rounded-full px-2 py-0.5 text-xs font-semibold ${
                            u.isActive ? 'bg-green-100 text-green-600' : 'bg-red-100 text-red-500'
                          }`}>{u.isActive ? 'Active' : 'Inactive'}</span>
                        </td>
                      </tr>
                    ))
                  )}
                </tbody>
              </table>
            </div>
          </motion.div>

          {/* Quick Actions */}
          <motion.div initial={hidden} animate={visible} transition={trans(0.2)} className="space-y-4">
            <h2 className="text-lg font-bold text-gray-900">Thao tác nhanh</h2>
            {quickActions.map((action) => (
              <Link
                key={action.label}
                to={action.to}
                className="group flex items-center gap-4 rounded-2xl border border-gray-100 bg-white p-4 shadow-sm transition hover:border-orange-200 hover:shadow-md hover:shadow-orange-100/40"
              >
                <div className={`flex h-12 w-12 items-center justify-center rounded-xl bg-gradient-to-br ${action.color} shadow-md`}>
                  <action.icon size={20} className="text-white" />
                </div>
                <div className="flex-1">
                  <p className="font-bold text-gray-900 transition group-hover:text-orange-500">{action.label}</p>
                  <p className="text-xs text-gray-400">{action.desc}</p>
                </div>
                <ChevronRight size={16} className="text-gray-300 transition group-hover:text-orange-500" />
              </Link>
            ))}

            {/* System Info */}
            <div className="mt-6 rounded-2xl border border-gray-100 bg-white p-5 shadow-sm">
              <h3 className="flex items-center gap-2 text-sm font-bold text-gray-900">
                <BarChart3 size={16} className="text-purple-500" />
                Thông tin hệ thống
              </h3>
              <div className="mt-3 space-y-2 text-xs text-gray-500">
                <div className="flex justify-between">
                  <span>Phiên bản</span>
                  <span className="font-semibold text-gray-700">v1.0.0</span>
                </div>
                <div className="flex justify-between">
                  <span>Ngày</span>
                  <span className="font-semibold text-gray-700">{new Date().toLocaleDateString('vi-VN')}</span>
                </div>
                <div className="flex justify-between">
                  <span>Users</span>
                  <span className="font-semibold text-gray-700">{loading ? '...' : otherStats.users}</span>
                </div>
              </div>
            </div>
          </motion.div>
        </div>
      </main>
    </div>
  );
}
