import { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { motion } from 'framer-motion';
import { Users, Clock, CreditCard, TrendingUp, ChevronRight, ShieldCheck, MessageSquare, UserPlus, BarChart3 } from 'lucide-react';
import AdminSidebar from '../components/AdminSidebar';
import { hidden, visible, trans } from '../../../lib/animations';
import { apiFetch } from '../../../lib/api';
import { useToast } from '../../../context/ToastContext';

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

type AdminBooking = {
  id: string;
  userId: string;
  lockerId: string;
  slotIndex: number;
  packageId: string;
  mobileNumber: string;
  status: string;            // "Pending" | "Active" | "Completed" | "Cancelled"
  totalAmount: number;
  paymentId: string | null;
  createdAt: string;
  startedAt: string | null;
  completedAt: string | null;
};

type AdminPayment = {
  id: string;
  bookingId: string;
  userId: string;
  amount: number;
  status: string;            // "Pending" | "Completed" | "Failed" | "Cancelled" | "Refunded"
  method: string;
  transactionId: string | null;
  createdAt: string;
  paidAt: string | null;
};

type PaginatedPayments = {
  items: AdminPayment[];
  totalCount: number;
  pageNumber: number;
  pageSize: number;
};

const stats = [
  { label: 'Tổng Users', key: 'users', icon: Users, color: 'bg-blue-500' },
  { label: 'Bookings', key: 'bookings', icon: Clock, color: 'bg-green-500' },
  { label: 'Payments', key: 'payments', icon: CreditCard, color: 'bg-purple-500' },
  { label: 'Doanh thu', key: 'revenue', icon: TrendingUp, color: 'bg-emerald-500' },
];

const quickActions = [
  { to: '/users', icon: Users, label: 'Quản lý Users', desc: 'Xem, thêm, sửa, xóa người dùng', color: 'from-blue-500 to-blue-600', bgColor: 'bg-blue-500' },
  { to: '/bookings', icon: Clock, label: 'Quản lý Bookings', desc: 'Theo dõi các đơn đặt tủ', color: 'from-green-500 to-green-600', bgColor: 'bg-green-500' },
  { to: '/payments', icon: CreditCard, label: 'Quản lý Payments', desc: 'Đối soát giao dịch', color: 'from-purple-500 to-purple-600', bgColor: 'bg-purple-500' },
  { to: '/feedbacks', icon: MessageSquare, label: 'Xem Feedback', desc: 'Review phản hồi từ người dùng', color: 'from-amber-500 to-amber-600', bgColor: 'bg-amber-500' },
];

export default function AdminDashboardPage() {
  const [users, setUsers] = useState<AdminUser[]>([]);
  const [bookings, setBookings] = useState<AdminBooking[]>([]);
  const [payments, setPayments] = useState<PaginatedPayments | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const { show: showToast } = useToast();

  useEffect(() => {
    const fetchAdminData = async () => {
      setLoading(true);
      setError(null);
      try {
        // Fire 3 requests in parallel — they share the same auth header
        // and don't depend on each other's results. Payments uses
        // pageSize=200 (backend MaxPageSize) so the dashboard revenue
        // figure covers as many records as possible without paging.
        const [usersRes, bookingsRes, paymentsRes] = await Promise.all([
          apiFetch('/admin/users'),
          apiFetch('/admin/bookings'),
          apiFetch('/admin/payments?pageNumber=1&pageSize=200'),
        ]);

        if (!usersRes.ok || !bookingsRes.ok || !paymentsRes.ok) {
          const status = usersRes.status === 401 || usersRes.status === 403
            ? usersRes.status
            : bookingsRes.status === 401 || bookingsRes.status === 403
              ? bookingsRes.status
              : paymentsRes.status;
          if (status === 401 || status === 403) {
            throw new Error('Bạn không có quyền truy cập trang này. Vui lòng đăng nhập tài khoản Admin.');
          }
          throw new Error('Không thể tải dữ liệu.');
        }

        const [usersData, bookingsData, paymentsData] = await Promise.all([
          usersRes.json() as Promise<AdminUser[]>,
          bookingsRes.json() as Promise<AdminBooking[]>,
          paymentsRes.json() as Promise<PaginatedPayments>,
        ]);

        setUsers(usersData);
        setBookings(bookingsData);
        setPayments(paymentsData);
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

  // Revenue = tổng amount các payment Completed. Backend trả Paginated
  // Result với totalCount nhưng không có field tổng tiền, nên
  // dashboard sum trên trang đầu (pageSize=200, backend cap). Với
  // dataset vài trăm payments thì chính xác; nếu vượt 200 cần endpoint
  // riêng — TODO thêm /admin/payments/summary nếu scale lên.
  const completedPayments = payments?.items.filter(p => p.status === 'Completed') ?? [];
  const revenue = completedPayments.reduce((sum, p) => sum + (p.amount ?? 0), 0);

  const recentUsers = [...users]
    .sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime())
    .slice(0, 6);

  const statsValues = {
    users: users.length,
    bookings: bookings.length,
    payments: payments?.totalCount ?? 0,
    revenue: revenue.toLocaleString('vi-VN') + ' đ',
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
        <motion.div initial={hidden} animate={visible} transition={trans(0.1)} className="mt-6 grid grid-cols-2 gap-4 lg:grid-cols-4">
          {stats.map((s) => (
            <Link
              key={s.key}
              to={s.key === 'users' ? '/users' : s.key === 'bookings' ? '/bookings' : '/payments'}
              className="group rounded-2xl border border-gray-100 bg-white p-5 shadow-sm transition hover:border-orange-200 hover:shadow-md hover:shadow-orange-100/40"
            >
              <div className="mb-3 flex items-center justify-between">
                <div className={`flex h-9 w-9 items-center justify-center rounded-xl ${s.color}`}>
                  <s.icon size={16} className="text-white" />
                </div>
                <ChevronRight size={14} className="text-gray-300 transition group-hover:text-orange-500" />
              </div>
              {loading ? (
                <div className="h-7 w-12 animate-pulse rounded-md bg-gray-200" />
              ) : (
                <p className="text-2xl font-extrabold text-gray-900">{statsValues[s.key as keyof typeof statsValues]}</p>
              )}
              <p className="mt-1 text-xs text-gray-400">{s.label}</p>
            </Link>
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
                  <span className="font-semibold text-gray-700">{loading ? '...' : users.length}</span>
                </div>
                <div className="flex justify-between">
                  <span>Bookings</span>
                  <span className="font-semibold text-gray-700">{loading ? '...' : bookings.length}</span>
                </div>
                <div className="flex justify-between">
                  <span>Payments</span>
                  <span className="font-semibold text-gray-700">{loading ? '...' : (payments?.totalCount ?? 0)}</span>
                </div>
              </div>
            </div>
          </motion.div>
        </div>
      </main>
    </div>
  );
}