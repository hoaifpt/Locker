import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { ChevronLeft, ChevronRight, Search, CreditCard } from 'lucide-react';
import AdminSidebar from '../components/AdminSidebar';
import { hidden, visible, trans } from '../../../lib/animations';
import { apiFetch } from '../../../lib/api';
import { useToast } from '../../../context/ToastContext';

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

const PAYMENT_STATUSES = ['all', 'Pending', 'Completed', 'Failed', 'Cancelled', 'Refunded'] as const;
const PAGE_SIZE = 10;

const STATUS_STYLES: Record<string, string> = {
  Pending: 'bg-amber-100 text-amber-700',
  Completed: 'bg-green-100 text-green-600',
  Failed: 'bg-red-100 text-red-500',
  Cancelled: 'bg-gray-100 text-gray-500',
  Refunded: 'bg-purple-100 text-purple-600',
};

const METHOD_LABELS: Record<string, string> = {
  Wallet: 'Ví E-Box',
  SePay: 'SePay (QR)',
  Cash: 'Tiền mặt',
  Card: 'Thẻ',
  BankTransfer: 'Chuyển khoản',
};

export default function AdminPaymentsPage() {
  const [data, setData] = useState<PaginatedPayments | null>(null);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [filterStatus, setFilterStatus] = useState<typeof PAYMENT_STATUSES[number]>('all');
  const [page, setPage] = useState(1);
  const { show: showToast } = useToast();

  const fetchPayments = async (pageNumber: number) => {
    setLoading(true);
    try {
      // Backend filter DateFrom/DateTo không cần — ta filter status
      // ngay client. PageSize cố định 100 cho đủ rộng (backend cap 200).
      const res = await apiFetch(`/admin/payments?pageNumber=${pageNumber}&pageSize=100`);
      if (!res.ok) throw new Error('Không thể tải danh sách payments.');
      const payload = await res.json() as PaginatedPayments;
      setData(payload);
    } catch (error) {
      showToast(error instanceof Error ? error.message : 'Lỗi không xác định', 'error');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    setPage(1);
    fetchPayments(1);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  useEffect(() => {
    fetchPayments(page);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [page]);

  const items = data?.items ?? [];
  const filtered = items.filter(p => {
    if (filterStatus !== 'all' && p.status !== filterStatus) return false;
    if (!search) return true;
    const s = search.toLowerCase();
    return (
      p.id.toLowerCase().includes(s) ||
      p.bookingId.toLowerCase().includes(s) ||
      p.userId.toLowerCase().includes(s) ||
      (p.transactionId ?? '').toLowerCase().includes(s)
    );
  });

  const totalRevenue = items
    .filter(p => p.status === 'Completed')
    .reduce((sum, p) => sum + p.amount, 0);
  const totalPages = Math.max(1, Math.ceil(filtered.length / PAGE_SIZE));
  const paginated = filtered.slice((page - 1) * PAGE_SIZE, page * PAGE_SIZE);

  return (
    <div className="flex min-h-screen bg-[#F9F8F6]">
      <AdminSidebar />
      <main className="ml-64 flex-1 px-8 py-8">
        {/* Header */}
        <motion.div initial={hidden} animate={visible} transition={trans(0)}>
          <span className="inline-flex items-center gap-2 rounded-full border border-purple-200 bg-purple-50 px-4 py-1.5 text-xs font-semibold uppercase tracking-widest text-purple-600">
            <CreditCard size={13} /> Payments
          </span>
          <h1 className="mt-3 text-3xl font-extrabold tracking-tight text-gray-900">Quản lý Payments</h1>
          <p className="mt-1 text-sm text-gray-500">
            Tổng cộng {data?.totalCount ?? 0} giao dịch
            {' · '}Doanh thu (Completed trong trang này) {totalRevenue.toLocaleString('vi-VN')} đ
          </p>
        </motion.div>

        {/* Filters */}
        <motion.div initial={hidden} animate={visible} transition={trans(0.1)} className="mt-6 flex flex-wrap items-center gap-4">
          <div className="relative flex-1 min-w-[240px]">
            <Search size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
            <input
              type="text"
              placeholder="Tìm theo ID, booking, user, mã giao dịch..."
              value={search}
              onChange={e => { setSearch(e.target.value); setPage(1); }}
              className="w-full rounded-xl border border-gray-200 bg-white py-2.5 pl-10 pr-4 text-sm shadow-sm focus:border-orange-300 focus:outline-none focus:ring-2 focus:ring-orange-100"
            />
          </div>
          <select
            value={filterStatus}
            onChange={e => { setFilterStatus(e.target.value as typeof PAYMENT_STATUSES[number]); setPage(1); }}
            className="rounded-xl border border-gray-200 bg-white px-4 py-2.5 text-sm shadow-sm focus:border-orange-300 focus:outline-none"
          >
            {PAYMENT_STATUSES.map(s => (
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
                <th className="px-4 py-3 text-left font-semibold text-gray-600">Booking</th>
                <th className="px-4 py-3 text-left font-semibold text-gray-600">User</th>
                <th className="px-4 py-3 text-left font-semibold text-gray-600">Phương thức</th>
                <th className="px-4 py-3 text-left font-semibold text-gray-600">Mã GD</th>
                <th className="px-4 py-3 text-right font-semibold text-gray-600">Số tiền</th>
                <th className="px-4 py-3 text-left font-semibold text-gray-600">Trạng thái</th>
                <th className="px-4 py-3 text-left font-semibold text-gray-600">Ngày thanh toán</th>
              </tr>
            </thead>
            <tbody>
              {loading ? (
                [...Array(5)].map((_, i) => (
                  <tr key={i} className="border-b border-gray-50">
                    {[...Array(8)].map((_, j) => (
                      <td key={j} className="px-4 py-3"><div className="h-4 w-full animate-pulse rounded bg-gray-200" /></td>
                    ))}
                  </tr>
                ))
              ) : paginated.length === 0 ? (
                <tr>
                  <td colSpan={8} className="px-4 py-12 text-center text-gray-400">Không tìm thấy payment nào</td>
                </tr>
              ) : (
                paginated.map(p => (
                  <tr key={p.id} className="border-b border-gray-50 transition hover:bg-orange-50/30">
                    <td className="px-4 py-3 font-mono text-xs text-gray-500">{p.id.slice(0, 8)}…</td>
                    <td className="px-4 py-3 font-mono text-xs text-gray-500">{p.bookingId.slice(0, 8)}…</td>
                    <td className="px-4 py-3 font-mono text-xs text-gray-500">{p.userId.slice(0, 8)}…</td>
                    <td className="px-4 py-3 text-gray-700">{METHOD_LABELS[p.method] ?? p.method}</td>
                    <td className="px-4 py-3 font-mono text-xs text-gray-500">{p.transactionId ?? '—'}</td>
                    <td className="px-4 py-3 text-right font-semibold text-gray-900">
                      {p.amount.toLocaleString('vi-VN')} đ
                    </td>
                    <td className="px-4 py-3">
                      <span className={`rounded-full px-2 py-0.5 text-xs font-semibold ${
                        STATUS_STYLES[p.status] ?? 'bg-gray-100 text-gray-600'
                      }`}>{p.status}</span>
                    </td>
                    <td className="px-4 py-3 text-gray-500">
                      {p.paidAt ? new Date(p.paidAt).toLocaleString('vi-VN') : new Date(p.createdAt).toLocaleString('vi-VN')}
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