import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { ChevronLeft, ChevronRight, Search, Clock } from 'lucide-react';
import AdminSidebar from '../components/AdminSidebar';
import { hidden, visible, trans } from '../../../lib/animations';
import { apiFetch } from '../../../lib/api';
import { useToast } from '../../../context/ToastContext';

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

const BOOKING_STATUSES = ['all', 'Pending', 'Active', 'Completed', 'Cancelled'] as const;
const PAGE_SIZE = 10;

const STATUS_STYLES: Record<string, string> = {
  Pending: 'bg-amber-100 text-amber-700',
  Active: 'bg-blue-100 text-blue-600',
  Completed: 'bg-green-100 text-green-600',
  Cancelled: 'bg-red-100 text-red-500',
  Expired: 'bg-gray-100 text-gray-500',
};

export default function AdminBookingsPage() {
  const [bookings, setBookings] = useState<AdminBooking[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [filterStatus, setFilterStatus] = useState<typeof BOOKING_STATUSES[number]>('all');
  const [page, setPage] = useState(1);
  const { show: showToast } = useToast();

  const fetchBookings = async () => {
    setLoading(true);
    try {
      const statusParam = filterStatus === 'all' ? '' : `?status=${filterStatus}`;
      const res = await apiFetch(`/admin/bookings${statusParam}`);
      if (!res.ok) throw new Error('Không thể tải danh sách bookings.');
      const data = await res.json() as AdminBooking[];
      setBookings(data);
      setPage(1);
    } catch (error) {
      showToast(error instanceof Error ? error.message : 'Lỗi không xác định', 'error');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchBookings();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [filterStatus]);

  const filtered = bookings.filter(b => {
    if (!search) return true;
    const s = search.toLowerCase();
    return (
      b.id.toLowerCase().includes(s) ||
      b.userId.toLowerCase().includes(s) ||
      b.lockerId.toLowerCase().includes(s) ||
      b.mobileNumber.toLowerCase().includes(s)
    );
  });

  const totalPages = Math.max(1, Math.ceil(filtered.length / PAGE_SIZE));
  const paginated = filtered.slice((page - 1) * PAGE_SIZE, page * PAGE_SIZE);

  const totalAmount = bookings.reduce((sum, b) => sum + (b.totalAmount ?? 0), 0);
  const completedAmount = bookings
    .filter(b => b.status === 'Completed')
    .reduce((sum, b) => sum + (b.totalAmount ?? 0), 0);

  return (
    <div className="flex min-h-screen bg-[#F9F8F6]">
      <AdminSidebar />
      <main className="ml-64 flex-1 px-8 py-8">
        {/* Header */}
        <motion.div initial={hidden} animate={visible} transition={trans(0)}>
          <span className="inline-flex items-center gap-2 rounded-full border border-green-200 bg-green-50 px-4 py-1.5 text-xs font-semibold uppercase tracking-widest text-green-700">
            <Clock size={13} /> Bookings
          </span>
          <h1 className="mt-3 text-3xl font-extrabold tracking-tight text-gray-900">Quản lý Bookings</h1>
          <p className="mt-1 text-sm text-gray-500">
            Tổng cộng {bookings.length} đơn đặt tủ
            {' · '}Tổng tiền {totalAmount.toLocaleString('vi-VN')} đ
            {' · '}Đã hoàn thành {completedAmount.toLocaleString('vi-VN')} đ
          </p>
        </motion.div>

        {/* Filters */}
        <motion.div initial={hidden} animate={visible} transition={trans(0.1)} className="mt-6 flex flex-wrap items-center gap-4">
          <div className="relative flex-1 min-w-[240px]">
            <Search size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
            <input
              type="text"
              placeholder="Tìm theo ID, user, locker, số điện thoại..."
              value={search}
              onChange={e => { setSearch(e.target.value); setPage(1); }}
              className="w-full rounded-xl border border-gray-200 bg-white py-2.5 pl-10 pr-4 text-sm shadow-sm focus:border-orange-300 focus:outline-none focus:ring-2 focus:ring-orange-100"
            />
          </div>
          <select
            value={filterStatus}
            onChange={e => setFilterStatus(e.target.value as typeof BOOKING_STATUSES[number])}
            className="rounded-xl border border-gray-200 bg-white px-4 py-2.5 text-sm shadow-sm focus:border-orange-300 focus:outline-none"
          >
            {BOOKING_STATUSES.map(s => (
              <option key={s} value={s}>{s === 'all' ? 'Tất cả trạng thái' : s}</option>
            ))}
          </select>
        </motion.div>

        {/* Table */}
        <motion.div initial={hidden} animate={visible} transition={trans(0.15)} className="mt-6 overflow-hidden rounded-2xl border border-gray-100 bg-white shadow-sm">
          <table className="w-full text-sm">
            <thead className="border-b border-gray-100 bg-gray-50">
              <tr>
                <th className="px-4 py-3 text-left font-semibold text-gray-600">ID</th>
                <th className="px-4 py-3 text-left font-semibold text-gray-600">User</th>
                <th className="px-4 py-3 text-left font-semibold text-gray-600">Locker / Slot</th>
                <th className="px-4 py-3 text-left font-semibold text-gray-600">SĐT</th>
                <th className="px-4 py-3 text-right font-semibold text-gray-600">Tổng tiền</th>
                <th className="px-4 py-3 text-left font-semibold text-gray-600">Trạng thái</th>
                <th className="px-4 py-3 text-left font-semibold text-gray-600">Ngày tạo</th>
              </tr>
            </thead>
            <tbody>
              {loading ? (
                [...Array(5)].map((_, i) => (
                  <tr key={i} className="border-b border-gray-50">
                    {[...Array(7)].map((_, j) => (
                      <td key={j} className="px-4 py-3"><div className="h-4 w-full animate-pulse rounded bg-gray-200" /></td>
                    ))}
                  </tr>
                ))
              ) : paginated.length === 0 ? (
                <tr>
                  <td colSpan={7} className="px-4 py-12 text-center text-gray-400">Không tìm thấy booking nào</td>
                </tr>
              ) : (
                paginated.map(b => (
                  <tr key={b.id} className="border-b border-gray-50 transition hover:bg-orange-50/30">
                    <td className="px-4 py-3 font-mono text-xs text-gray-500">{b.id.slice(0, 8)}…</td>
                    <td className="px-4 py-3 font-mono text-xs text-gray-500">{b.userId.slice(0, 8)}…</td>
                    <td className="px-4 py-3 text-gray-700">
                      <span className="font-mono text-xs">{b.lockerId.slice(0, 8)}</span>
                      <span className="ml-2 text-gray-400">slot {b.slotIndex}</span>
                    </td>
                    <td className="px-4 py-3 text-gray-700">{b.mobileNumber || '—'}</td>
                    <td className="px-4 py-3 text-right font-semibold text-gray-900">
                      {b.totalAmount.toLocaleString('vi-VN')} đ
                    </td>
                    <td className="px-4 py-3">
                      <span className={`rounded-full px-2 py-0.5 text-xs font-semibold ${
                        STATUS_STYLES[b.status] ?? 'bg-gray-100 text-gray-600'
                      }`}>{b.status}</span>
                    </td>
                    <td className="px-4 py-3 text-gray-500">
                      {new Date(b.createdAt).toLocaleString('vi-VN')}
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </motion.div>

        {/* Pagination */}
        {!loading && filtered.length > PAGE_SIZE && (
          <motion.div initial={hidden} animate={visible} transition={trans(0.2)} className="mt-4 flex items-center justify-between">
            <p className="text-sm text-gray-500">
              Hiển thị {(page - 1) * PAGE_SIZE + 1} - {Math.min(page * PAGE_SIZE, filtered.length)} của {filtered.length}
            </p>
            <div className="flex items-center gap-2">
              <button
                onClick={() => setPage(p => Math.max(1, p - 1))}
                disabled={page === 1}
                className="rounded-lg p-2 text-gray-400 transition hover:bg-gray-100 disabled:opacity-50"
              >
                <ChevronLeft size={18} />
              </button>
              {[...Array(totalPages)].map((_, i) => (
                <button
                  key={i + 1}
                  onClick={() => setPage(i + 1)}
                  className={`h-8 w-8 rounded-lg text-sm font-medium transition ${
                    page === i + 1
                      ? 'bg-orange-500 text-white'
                      : 'text-gray-500 hover:bg-gray-100'
                  }`}
                >
                  {i + 1}
                </button>
              ))}
              <button
                onClick={() => setPage(p => Math.min(totalPages, p + 1))}
                disabled={page === totalPages}
                className="rounded-lg p-2 text-gray-400 transition hover:bg-gray-100 disabled:opacity-50"
              >
                <ChevronRight size={18} />
              </button>
            </div>
          </motion.div>
        )}
      </main>
    </div>
  );
}