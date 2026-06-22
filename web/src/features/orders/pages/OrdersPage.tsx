import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { Package, Clock, ChevronRight, Plus, Filter } from 'lucide-react';
import { Link } from 'react-router-dom';
import AppHeader from '../../../components/layout/AppHeader';
import { hidden, visible, trans } from '../../../lib/animations';
import { getOrdersByUser, SeedOrder, getLockerById } from '../../../mocks/seed';

const STATUS_STYLE: Record<string, { label: string; cls: string }> = {
  Initiated: { label: 'Khởi tạo', cls: 'bg-gray-100 text-gray-600' },
  Reserved: { label: 'Đã giữ chỗ', cls: 'bg-blue-100 text-blue-600' },
  Paid: { label: 'Đã thanh toán', cls: 'bg-indigo-100 text-indigo-600' },
  Active: { label: 'Đang dùng', cls: 'bg-green-100 text-green-700' },
  Completed: { label: 'Hoàn thành', cls: 'bg-emerald-100 text-emerald-700' },
  Cancelled: { label: 'Đã hủy', cls: 'bg-red-100 text-red-500' },
};

const FILTERS = ['Tất cả', 'Active', 'Initiated', 'Paid', 'Completed', 'Cancelled'];

export default function OrdersPage() {
  const userId = localStorage.getItem('userId') ?? 'u-001';
  const [orders, setOrders] = useState<SeedOrder[]>([]);
  const [filter, setFilter] = useState('Tất cả');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    setTimeout(() => { setOrders(getOrdersByUser(userId)); setLoading(false); }, 300);
  }, [userId]);

  const filtered = filter === 'Tất cả' ? orders : orders.filter(o => o.status === filter);

  return (
    <div className="min-h-screen bg-[#F9F8F6] font-sans antialiased">
      <AppHeader />
      <main className="mx-auto max-w-4xl px-4 py-10 lg:px-8">
        <motion.div initial={hidden} animate={visible} transition={trans(0)} className="mb-6 flex items-start justify-between">
          <div>
            <span className="inline-flex items-center gap-2 rounded-full border border-orange-200 bg-orange-50 px-4 py-1.5 text-xs font-semibold uppercase tracking-widest text-orange-600">
              Đơn hàng
            </span>
            <h1 className="mt-3 text-3xl font-extrabold tracking-tight text-gray-900">
              Đơn hàng <span className="text-orange-500">của tôi</span>
            </h1>
          </div>
          <Link to="/lockers" className="flex items-center gap-1.5 rounded-xl bg-orange-500 px-4 py-2.5 text-sm font-semibold text-white shadow-md shadow-orange-200 transition hover:bg-orange-600">
            <Plus size={16} /> Tạo đơn mới
          </Link>
        </motion.div>

        {/* Filter */}
        <motion.div initial={hidden} animate={visible} transition={trans(0.1)} className="mb-6 flex flex-wrap gap-2">
          {FILTERS.map(s => (
            <button key={s} onClick={() => setFilter(s)}
              className={`rounded-xl px-4 py-2 text-sm font-medium transition ${filter === s ? 'bg-orange-500 text-white shadow-md shadow-orange-200' : 'border border-gray-200 bg-white text-gray-600 hover:border-orange-300 hover:text-orange-500'}`}>
              {s === 'Tất cả' ? s : STATUS_STYLE[s]?.label ?? s}
            </button>
          ))}
        </motion.div>

        {/* List */}
        {loading ? (
          <div className="space-y-4">{[...Array(3)].map((_, i) => <div key={i} className="h-28 animate-pulse rounded-3xl bg-gray-200" />)}</div>
        ) : filtered.length === 0 ? (
          <div className="rounded-3xl border border-gray-100 bg-white py-16 text-center shadow-sm">
            <Package size={32} className="mx-auto mb-3 text-gray-300" />
            <p className="text-sm text-gray-400">Không có đơn hàng nào.</p>
          </div>
        ) : (
          <div className="space-y-4">
            {filtered.map((order, i) => {
              const locker = getLockerById(order.lockerId);
              const st = STATUS_STYLE[order.status];
              return (
                <motion.div key={order.id} initial={hidden} animate={visible} transition={trans(0.1 + i * 0.05)}>
                  <Link to={`/orders/${order.id}`} className="group flex items-center gap-4 rounded-3xl border border-gray-100 bg-white p-5 shadow-sm transition hover:border-orange-200 hover:shadow-md hover:shadow-orange-100/40">
                    <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded-2xl bg-orange-100">
                      <Package size={20} className="text-orange-500" />
                    </div>
                    <div className="min-w-0 flex-1">
                      <div className="flex items-start justify-between gap-2">
                        <h3 className="truncate font-bold text-gray-900 transition group-hover:text-orange-500">
                          {locker?.name ?? 'Locker'} — Ô {order.slotIndex + 1}
                        </h3>
                        <span className={`shrink-0 rounded-full px-2.5 py-0.5 text-xs font-semibold ${st?.cls}`}>{st?.label}</span>
                      </div>
                      <div className="mt-1.5 flex flex-wrap items-center gap-3 text-xs text-gray-400">
                        <span className="flex items-center gap-1"><Clock size={11} /> {order.durationHours}h</span>
                        <span>{new Date(order.checkInTime).toLocaleDateString('vi-VN')}</span>
                        <span className="font-semibold text-orange-500">{order.totalAmount.toLocaleString('vi-VN')}đ</span>
                      </div>
                    </div>
                    <ChevronRight size={16} className="shrink-0 text-gray-300 transition group-hover:text-orange-400" />
                  </Link>
                </motion.div>
              );
            })}
          </div>
        )}
      </main>
    </div>
  );
}
