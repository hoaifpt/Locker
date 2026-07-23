import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { Package, MapPin, Clock, ChevronRight, TrendingUp, Truck, BarChart3, Users, CreditCard, ShieldCheck } from 'lucide-react';
import { Link } from 'react-router-dom';
import AppHeader from '../../../components/layout/AppHeader';
import { hidden, visible, trans } from '../../../lib/animations';
import { getMockUserDashboard, getMockShipperDashboard, SEED_USERS, SEED_ORDERS, SEED_BOOKINGS, SEED_PAYMENTS } from '../../../mocks/seed';

export default function DashboardPage() {
  const role = localStorage.getItem('role') ?? 'User';
  const userId = localStorage.getItem('userId') ?? 'u-001';

  if (role === 'Shipper') return <ShipperDashboard userId={userId} />;
  if (role === 'Admin') return <AdminDashboard />;
  return <UserDashboard userId={userId} />;
}

/* ─── USER DASHBOARD ────────────────────────────────────── */
function UserDashboard({ userId }: { userId: string }) {
  const [data, setData] = useState<ReturnType<typeof getMockUserDashboard> | null>(null);

  useEffect(() => {
    setTimeout(() => setData(getMockUserDashboard(userId)), 300);
  }, [userId]);

  if (!data) return <LoadingSkeleton />;

  return (
    <div className="min-h-screen bg-[#F9F8F6] font-sans antialiased">
      <AppHeader />
      <main className="mx-auto max-w-5xl px-4 py-8 lg:px-8">
        {/* Greeting */}
        <motion.div initial={hidden} animate={visible} transition={trans(0)} className="mb-8">
          <h1 className="text-3xl font-extrabold tracking-tight text-gray-900">{data.user.fullName}</h1>
          <p className="mt-1 flex items-center gap-1.5 text-sm text-gray-500">
            <MapPin size={13} className="text-orange-400" /> {data.user.location}
          </p>
        </motion.div>

        <div className="grid gap-6 lg:grid-cols-3">
          {/* Active Order */}
          <motion.div initial={hidden} animate={visible} transition={trans(0.1)} className="lg:col-span-2">
            {data.activeOrder ? (
              <div className="rounded-3xl border border-orange-200 bg-gradient-to-br from-orange-500 to-orange-600 p-6 text-white shadow-lg shadow-orange-200/50">
                <div className="mb-1 flex items-center gap-2 text-xs font-semibold uppercase tracking-widest text-orange-100">
                  <Package size={14} /> Đơn hàng đang sử dụng
                </div>
                <h2 className="mt-2 text-2xl font-extrabold">{data.activeOrder.orderCode}</h2>
                <p className="mt-1 text-sm text-orange-100">{data.activeOrder.lockerName}</p>
                <p className="text-xs text-orange-200">{data.activeOrder.address}</p>
                <div className="mt-4 flex items-center justify-between">
                  <div className="flex items-center gap-2">
                    <Clock size={16} />
                    <span className="text-lg font-bold">{data.activeOrder.remainingTime}</span>
                    <span className="text-xs text-orange-200">còn lại</span>
                  </div>
                  <Link to="/orders" className="flex items-center gap-1 rounded-xl bg-white/20 px-4 py-2 text-sm font-semibold backdrop-blur-sm transition hover:bg-white/30">
                    Chi tiết <ChevronRight size={14} />
                  </Link>
                </div>
              </div>
            ) : (
              <div className="flex flex-col items-center justify-center rounded-3xl border border-dashed border-gray-300 bg-white p-10 text-center">
                <Package size={40} className="mb-3 text-gray-300" />
                <p className="text-sm text-gray-500">Bạn chưa có đơn hàng nào đang hoạt động.</p>
                <Link to="/lockers" className="mt-4 flex items-center gap-1 rounded-xl bg-orange-500 px-5 py-2.5 text-sm font-semibold text-white shadow-md shadow-orange-200 transition hover:bg-orange-600">
                  Đặt tủ ngay <ChevronRight size={14} />
                </Link>
              </div>
            )}
          </motion.div>

          {/* Quick Actions */}
          <motion.div initial={hidden} animate={visible} transition={trans(0.15)} className="space-y-3">
            {[
              { to: '/lockers', icon: Package, label: 'Tìm tủ khóa', desc: 'Đặt chỗ mới' },
              { to: '/orders', icon: Clock, label: 'Đơn hàng', desc: 'Xem đơn hàng' },
              { to: '/send-receive', icon: Truck, label: 'Gửi - Nhận', desc: 'Gửi hàng cho bạn bè' },
              { to: '/wallet', icon: CreditCard, label: 'Ví E-Box', desc: 'Nạp tiền & thanh toán' },
            ].map((item, i) => (
              <Link key={item.to} to={item.to} className="group flex items-center gap-3 rounded-2xl border border-gray-100 bg-white p-4 shadow-sm transition hover:border-orange-200 hover:shadow-md hover:shadow-orange-100/40">
                <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-orange-100 transition group-hover:bg-orange-500">
                  <item.icon size={18} className="text-orange-500 transition group-hover:text-white" />
                </div>
                <div className="flex-1">
                  <p className="text-sm font-bold text-gray-900">{item.label}</p>
                  <p className="text-xs text-gray-400">{item.desc}</p>
                </div>
                <ChevronRight size={14} className="text-gray-300 transition group-hover:text-orange-500" />
              </Link>
            ))}
          </motion.div>
        </div>

        {/* Suggested Lockers */}
        <motion.div initial={hidden} animate={visible} transition={trans(0.2)} className="mt-8">
          <h2 className="mb-4 text-lg font-bold text-gray-900">Tủ khóa gợi ý gần bạn</h2>
          <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
            {data.suggestedLockers.map((locker, i) => (
              <Link key={locker.id} to={`/lockers/${locker.id}`} className="group rounded-2xl border border-gray-100 bg-white p-5 shadow-sm transition hover:border-orange-200 hover:shadow-md hover:shadow-orange-100/40">
                <div className="flex items-start justify-between">
                  <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-orange-100">
                    <MapPin size={18} className="text-orange-500" />
                  </div>
                  <span className="rounded-full bg-green-100 px-2.5 py-0.5 text-xs font-semibold text-green-600">{locker.availableSlots} trống</span>
                </div>
                <h3 className="mt-3 font-bold text-gray-900 transition group-hover:text-orange-500">{locker.name}</h3>
                <p className="mt-1 text-xs text-gray-400">{locker.distance} từ vị trí của bạn</p>
              </Link>
            ))}
          </div>
        </motion.div>
      </main>
    </div>
  );
}

/* ─── SHIPPER DASHBOARD ─────────────────────────────────── */
function ShipperDashboard({ userId }: { userId: string }) {
  const [data, setData] = useState<ReturnType<typeof getMockShipperDashboard> | null>(null);

  useEffect(() => {
    setTimeout(() => setData(getMockShipperDashboard(userId)), 300);
  }, [userId]);

  if (!data) return <LoadingSkeleton />;

  return (
    <div className="min-h-screen bg-[#F9F8F6] font-sans antialiased">
      <AppHeader />
      <main className="mx-auto max-w-5xl px-4 py-8 lg:px-8">
        <motion.div initial={hidden} animate={visible} transition={trans(0)}>
          <span className="inline-flex items-center gap-2 rounded-full border border-blue-200 bg-blue-50 px-4 py-1.5 text-xs font-semibold uppercase tracking-widest text-blue-600">
            <Truck size={13} /> Bảng điều khiển Shipper
          </span>
          <h1 className="mt-3 text-3xl font-extrabold tracking-tight text-gray-900">Xin chào, Shipper!</h1>
        </motion.div>

        {/* Performance stats */}
        <motion.div initial={hidden} animate={visible} transition={trans(0.1)} className="mt-6 grid grid-cols-2 gap-4 lg:grid-cols-4">
          {[
            { label: 'Đã giao', value: data.performance.deliveredCount, color: 'bg-green-500', icon: TrendingUp },
            { label: 'Chờ giao', value: data.performance.remainingCount, color: 'bg-orange-500', icon: Package },
            { label: 'Tổng km', value: `${data.performance.totalKm}km`, color: 'bg-blue-500', icon: BarChart3 },
            { label: 'Cập nhật', value: data.performance.updatedAt, color: 'bg-purple-500', icon: Clock },
          ].map((s) => (
            <div key={s.label} className="rounded-2xl border border-gray-100 bg-white p-5 shadow-sm">
              <div className={`mb-3 flex h-9 w-9 items-center justify-center rounded-xl ${s.color}`}>
                <s.icon size={16} className="text-white" />
              </div>
              <p className="text-2xl font-extrabold text-gray-900">{s.value}</p>
              <p className="text-xs text-gray-400">{s.label}</p>
            </div>
          ))}
        </motion.div>

        {/* Orders to process */}
        <motion.div initial={hidden} animate={visible} transition={trans(0.15)} className="mt-8">
          <div className="mb-4 flex items-center justify-between">
            <h2 className="text-lg font-bold text-gray-900">Đơn cần giao hôm nay</h2>
            <Link to="/shipper/tasks" className="text-sm font-semibold text-orange-500 hover:text-orange-600">Xem tất cả →</Link>
          </div>
          <div className="space-y-3">
            {data.ordersToProcess.length === 0 ? (
              <div className="rounded-2xl border border-gray-100 bg-white py-10 text-center shadow-sm">
                <Package size={32} className="mx-auto mb-2 text-gray-300" />
                <p className="text-sm text-gray-400">Không có đơn nào cần giao.</p>
              </div>
            ) : data.ordersToProcess.map((order, i) => (
              <Link key={order.orderId} to={`/shipper/tasks/${order.orderId}`} className="group flex items-center gap-4 rounded-2xl border border-gray-100 bg-white p-4 shadow-sm transition hover:border-orange-200 hover:shadow-md hover:shadow-orange-100/40">
                <div className="flex h-11 w-11 items-center justify-center rounded-xl bg-orange-100">
                  <Truck size={18} className="text-orange-500" />
                </div>
                <div className="flex-1">
                  <div className="flex items-center gap-2">
                    <span className="rounded-md bg-orange-500 px-2 py-0.5 text-xs font-bold text-white">{order.type}</span>
                    <span className="text-xs text-gray-400">{order.distance}</span>
                  </div>
                  <p className="mt-1 font-bold text-gray-900">{order.locationName}</p>
                  <p className="text-xs text-gray-500">{order.slotInfo} · {order.code}</p>
                </div>
                <ChevronRight size={16} className="text-gray-300 group-hover:text-orange-500" />
              </Link>
            ))}
          </div>
        </motion.div>

        {/* Available Lockers */}
        <motion.div initial={hidden} animate={visible} transition={trans(0.2)} className="mt-8">
          <h2 className="mb-4 text-lg font-bold text-gray-900">Tủ khóa khả dụng</h2>
          <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
            {data.availableLockers.map((locker) => (
              <div key={locker.id} className="rounded-2xl border border-gray-100 bg-white p-5 shadow-sm">
                <h3 className="font-bold text-gray-900">{locker.name}</h3>
                <p className="mt-1 text-xs text-gray-500">{locker.address}</p>
                <div className="mt-3 flex items-center justify-between text-xs">
                  <span className="rounded-full bg-green-100 px-2 py-0.5 font-semibold text-green-600">{locker.availableSlots} trống</span>
                  <span className="text-gray-400">{locker.distance} · {locker.travelTime}</span>
                </div>
              </div>
            ))}
          </div>
        </motion.div>
      </main>
    </div>
  );
}

/* ─── ADMIN DASHBOARD ───────────────────────────────────── */
function AdminDashboard() {
  const totalUsers = SEED_USERS.length;
  const totalOrders = SEED_ORDERS.length;
  const totalBookings = SEED_BOOKINGS.length;
  const totalPayments = SEED_PAYMENTS.length;
  const totalRevenue = SEED_PAYMENTS.filter(p => p.status === 'Completed').reduce((sum, p) => sum + p.amount, 0);

  return (
    <div className="min-h-screen bg-[#F9F8F6] font-sans antialiased">
      <AppHeader />
      <main className="mx-auto max-w-6xl px-4 py-8 lg:px-8">
        <motion.div initial={hidden} animate={visible} transition={trans(0)}>
          <span className="inline-flex items-center gap-2 rounded-full border border-purple-200 bg-purple-50 px-4 py-1.5 text-xs font-semibold uppercase tracking-widest text-purple-600">
            <ShieldCheck size={13} /> Quản trị viên
          </span>
          <h1 className="mt-3 text-3xl font-extrabold tracking-tight text-gray-900">Bảng điều khiển Admin</h1>
        </motion.div>

        <motion.div initial={hidden} animate={visible} transition={trans(0.1)} className="mt-6 grid grid-cols-2 gap-4 lg:grid-cols-5">
          {[
            { label: 'Tổng Users', value: totalUsers, icon: Users, color: 'bg-blue-500' },
            { label: 'Đơn hàng', value: totalOrders, icon: Package, color: 'bg-orange-500' },
            { label: 'Bookings', value: totalBookings, icon: Clock, color: 'bg-green-500' },
            { label: 'Payments', value: totalPayments, icon: CreditCard, color: 'bg-purple-500' },
            { label: 'Doanh thu', value: `${(totalRevenue / 1000).toFixed(0)}K`, icon: TrendingUp, color: 'bg-emerald-500' },
          ].map((s) => (
            <div key={s.label} className="rounded-2xl border border-gray-100 bg-white p-5 shadow-sm">
              <div className={`mb-3 flex h-9 w-9 items-center justify-center rounded-xl ${s.color}`}>
                <s.icon size={16} className="text-white" />
              </div>
              <p className="text-2xl font-extrabold text-gray-900">{s.value}</p>
              <p className="text-xs text-gray-400">{s.label}</p>
            </div>
          ))}
        </motion.div>

        {/* Recent Users */}
        <motion.div initial={hidden} animate={visible} transition={trans(0.15)} className="mt-8">
          <h2 className="mb-4 text-lg font-bold text-gray-900">Người dùng gần đây</h2>
          <div className="overflow-hidden rounded-2xl border border-gray-100 bg-white shadow-sm">
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
                {SEED_USERS.slice(0, 8).map(u => (
                  <tr key={u.id} className="border-b border-gray-50 transition hover:bg-orange-50/30">
                    <td className="px-4 py-3 font-medium text-gray-900">{u.fullName}</td>
                    <td className="px-4 py-3 text-gray-500">{u.email}</td>
                    <td className="px-4 py-3"><span className={`rounded-full px-2 py-0.5 text-xs font-semibold ${u.role === 'Admin' ? 'bg-purple-100 text-purple-600' : u.role === 'Shipper' ? 'bg-blue-100 text-blue-600' : 'bg-gray-100 text-gray-600'}`}>{u.role}</span></td>
                    <td className="px-4 py-3"><span className={`rounded-full px-2 py-0.5 text-xs font-semibold ${u.isActive ? 'bg-green-100 text-green-600' : 'bg-red-100 text-red-500'}`}>{u.isActive ? 'Active' : 'Inactive'}</span></td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </motion.div>
      </main>
    </div>
  );
}

/* ─── Loading Skeleton ──────────────────────────────────── */
function LoadingSkeleton() {
  return (
    <div className="min-h-screen bg-[#F9F8F6]">
      <AppHeader />
      <div className="mx-auto max-w-5xl px-4 py-8">
        <div className="h-10 w-64 animate-pulse rounded-xl bg-gray-200" />
        <div className="mt-6 grid gap-6 lg:grid-cols-3">
          <div className="h-48 animate-pulse rounded-3xl bg-gray-200 lg:col-span-2" />
          <div className="space-y-3">
            {[...Array(4)].map((_, i) => <div key={i} className="h-16 animate-pulse rounded-2xl bg-gray-200" />)}
          </div>
        </div>
      </div>
    </div>
  );
}
