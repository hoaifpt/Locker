import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { ChevronLeft, ChevronRight, Search, Wallet, Calendar, TrendingUp, BarChart3, Activity } from 'lucide-react';
import AdminSidebar from '../components/AdminSidebar';
import { hidden, visible, trans } from '../../../lib/animations';
import { apiFetch } from '../../../lib/api';
import { useToast } from '../../../context/ToastContext';

type AdminWalletTopUp = {
  id: string;
  userId: string;
  userName: string | null;
  amount: number;
  type: 'TopUp' | 'Transfer' | 'Payment' | 'Refund';
  status: 'Pending' | 'Completed' | 'Failed' | 'Cancelled';
  description: string | null;
  referenceId: string | null;
  relatedUserId: string | null;
  createdAt: string;
  updatedAt: string;
};

type AdminWalletSummary = {
  totalTopUpAmount: number;
  topUpCount: number;
  todayAmount: number;
  todayCount: number;
  weekAmount: number;
  weekCount: number;
  monthAmount: number;
  monthCount: number;
  selectedDay: string | null;
  selectedDayAmount: number;
  selectedDayCount: number;
};

const PAGE_SIZE = 10;

function toLocalDateInput(d: Date): string {
  const yyyy = d.getFullYear();
  const mm = String(d.getMonth() + 1).padStart(2, '0');
  const dd = String(d.getDate()).padStart(2, '0');
  return `${yyyy}-${mm}-${dd}`;
}

export default function AdminWalletPage() {
  const [topUps, setTopUps] = useState<AdminWalletTopUp[]>([]);
  const [summary, setSummary] = useState<AdminWalletSummary | null>(null);
  const [loading, setLoading] = useState(true);
  const [selectedDay, setSelectedDay] = useState<string>(toLocalDateInput(new Date()));
  const [search, setSearch] = useState('');
  const [dateFrom, setDateFrom] = useState<string>('');
  const [dateTo, setDateTo] = useState<string>('');
  const [page, setPage] = useState(1);
  const { show: showToast } = useToast();

  const fetchData = async () => {
    setLoading(true);
    try {
      const params = new URLSearchParams();
      if (dateFrom) params.append('dateFrom', new Date(dateFrom).toISOString());
      if (dateTo) {
        // dateTo là end-of-day → cộng 1 ngày để include cả ngày đó
        const end = new Date(dateTo);
        end.setDate(end.getDate() + 1);
        params.append('dateTo', end.toISOString());
      }
      const qs = params.toString();
      const url = `/admin/wallet/top-ups${qs ? `?${qs}` : ''}`;
      const summaryUrl = `/admin/wallet/summary?date=${encodeURIComponent(selectedDay)}`;

      const [topUpsRes, summaryRes] = await Promise.all([
        apiFetch(url),
        apiFetch(summaryUrl),
      ]);
      if (!topUpsRes.ok || !summaryRes.ok) {
        throw new Error('Không thể tải dữ liệu ví.');
      }
      const [topUpsData, summaryData] = await Promise.all([
        topUpsRes.json() as Promise<AdminWalletTopUp[]>,
        summaryRes.json() as Promise<AdminWalletSummary>,
      ]);
      setTopUps(topUpsData);
      setSummary(summaryData);
      setPage(1);
    } catch (error) {
      showToast(error instanceof Error ? error.message : 'Lỗi không xác định', 'error');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchData();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [dateFrom, dateTo, selectedDay]);

  const filtered = topUps.filter(t => {
    if (!search) return true;
    const s = search.toLowerCase();
    return (
      (t.userName ?? '').toLowerCase().includes(s) ||
      t.id.toLowerCase().includes(s) ||
      (t.description ?? '').toLowerCase().includes(s) ||
      (t.referenceId ?? '').toLowerCase().includes(s)
    );
  });

  const totalPages = Math.max(1, Math.ceil(filtered.length / PAGE_SIZE));
  const paginated = filtered.slice((page - 1) * PAGE_SIZE, page * PAGE_SIZE);

  // Reset filters
  const resetFilters = () => {
    setDateFrom('');
    setDateTo('');
    setSearch('');
    setPage(1);
  };

  return (
    <div className="flex min-h-screen bg-[#F9F8F6]">
      <AdminSidebar />
      <main className="ml-64 flex-1 px-8 py-8">
        {/* Header */}
        <motion.div initial={hidden} animate={visible} transition={trans(0)}>
          <span className="inline-flex items-center gap-2 rounded-full border border-emerald-200 bg-emerald-50 px-4 py-1.5 text-xs font-semibold uppercase tracking-widest text-emerald-700">
            <Wallet size={13} /> Wallet
          </span>
          <h1 className="mt-3 text-3xl font-extrabold tracking-tight text-gray-900">Quản lý Wallet</h1>
          <p className="mt-1 text-sm text-gray-500">
            Tổng cộng {summary?.topUpCount ?? 0} giao dịch nạp tiền hoàn thành
            {' · '}Tổng tiền vào {summary?.totalTopUpAmount.toLocaleString('vi-VN') ?? 0} đ
          </p>
        </motion.div>

        {/* Breakdown: today / week / month */}
        <motion.div initial={hidden} animate={visible} transition={trans(0.05)} className="mt-6 grid gap-4 sm:grid-cols-3">
          <div className="rounded-2xl border border-gray-100 bg-white p-5 shadow-sm">
            <div className="flex items-center justify-between gap-2">
              <label className="flex flex-col text-xs font-semibold uppercase tracking-widest text-emerald-600">
                Ngày
                <input
                  type="date"
                  value={selectedDay}
                  onChange={(e) => setSelectedDay(e.target.value)}
                  className="mt-1 rounded-lg border border-gray-200 bg-white px-2 py-1 text-xs font-semibold text-gray-700 focus:border-emerald-300 focus:outline-none focus:ring-2 focus:ring-emerald-100"
                />
              </label>
              <Activity size={16} className="text-emerald-500" />
            </div>
            <p className="mt-3 text-2xl font-extrabold text-gray-900">
              {summary?.selectedDayAmount.toLocaleString('vi-VN') ?? 0} đ
            </p>
            <p className="mt-1 text-xs text-gray-400">
              {summary?.selectedDayCount ?? 0} giao dịch
            </p>
            <p className="mt-2 text-[11px] text-gray-400">
              {selectedDay === toLocalDateInput(new Date())
                ? 'Hôm nay'
                : `Đã chọn: ${new Date(selectedDay).toLocaleDateString('vi-VN')}`}
            </p>
          </div>
          <div className="rounded-2xl border border-gray-100 bg-white p-5 shadow-sm">
            <div className="flex items-center justify-between">
              <span className="text-xs font-semibold uppercase tracking-widest text-blue-600">Tuần này</span>
              <BarChart3 size={16} className="text-blue-500" />
            </div>
            <p className="mt-2 text-2xl font-extrabold text-gray-900">
              {summary?.weekAmount.toLocaleString('vi-VN') ?? 0} đ
            </p>
            <p className="mt-1 text-xs text-gray-400">
              {summary?.weekCount ?? 0} giao dịch
            </p>
          </div>
          <div className="rounded-2xl border border-gray-100 bg-white p-5 shadow-sm">
            <div className="flex items-center justify-between">
              <span className="text-xs font-semibold uppercase tracking-widest text-purple-600">Tháng này</span>
              <TrendingUp size={16} className="text-purple-500" />
            </div>
            <p className="mt-2 text-2xl font-extrabold text-gray-900">
              {summary?.monthAmount.toLocaleString('vi-VN') ?? 0} đ
            </p>
            <p className="mt-1 text-xs text-gray-400">
              {summary?.monthCount ?? 0} giao dịch
            </p>
          </div>
        </motion.div>

        {/* Filters */}
        <motion.div initial={hidden} animate={visible} transition={trans(0.1)} className="mt-6 flex flex-wrap items-center gap-3">
          <div className="relative flex-1 min-w-[240px]">
            <Search size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
            <input
              type="text"
              placeholder="Tìm theo user, ID, mô tả, mã tham chiếu..."
              value={search}
              onChange={e => { setSearch(e.target.value); setPage(1); }}
              className="w-full rounded-xl border border-gray-200 bg-white py-2.5 pl-10 pr-4 text-sm shadow-sm focus:border-orange-300 focus:outline-none focus:ring-2 focus:ring-orange-100"
            />
          </div>

          <div className="flex items-center gap-2 rounded-xl border border-gray-200 bg-white px-3 py-2 shadow-sm">
            <Calendar size={14} className="text-gray-400" />
            <input
              type="date"
              value={dateFrom}
              onChange={e => setDateFrom(e.target.value)}
              className="border-0 bg-transparent text-sm focus:outline-none"
              title="Từ ngày"
            />
            <span className="text-gray-400">→</span>
            <input
              type="date"
              value={dateTo}
              onChange={e => setDateTo(e.target.value)}
              className="border-0 bg-transparent text-sm focus:outline-none"
              title="Đến ngày"
            />
          </div>

          {(dateFrom || dateTo || search) && (
            <button
              onClick={resetFilters}
              className="rounded-xl border border-gray-200 bg-white px-4 py-2.5 text-sm font-medium text-gray-600 shadow-sm transition hover:bg-gray-50"
            >
              Reset
            </button>
          )}
        </motion.div>

        {/* Table */}
        <motion.div initial={hidden} animate={visible} transition={trans(0.15)} className="mt-6 overflow-hidden rounded-2xl border border-gray-100 bg-white shadow-sm">
          <table className="w-full text-sm">
            <thead className="border-b border-gray-100 bg-gray-50">
              <tr>
                <th className="px-4 py-3 text-left font-semibold text-gray-600">Thời gian</th>
                <th className="px-4 py-3 text-left font-semibold text-gray-600">User</th>
                <th className="px-4 py-3 text-left font-semibold text-gray-600">Mô tả</th>
                <th className="px-4 py-3 text-left font-semibold text-gray-600">Mã tham chiếu</th>
                <th className="px-4 py-3 text-right font-semibold text-gray-600">Số tiền</th>
              </tr>
            </thead>
            <tbody>
              {loading ? (
                [...Array(5)].map((_, i) => (
                  <tr key={i} className="border-b border-gray-50">
                    {[...Array(5)].map((_, j) => (
                      <td key={j} className="px-4 py-3"><div className="h-4 w-full animate-pulse rounded bg-gray-200" /></td>
                    ))}
                  </tr>
                ))
              ) : paginated.length === 0 ? (
                <tr>
                  <td colSpan={5} className="px-4 py-12 text-center text-gray-400">Không có giao dịch nạp tiền nào trong khoảng này</td>
                </tr>
              ) : (
                paginated.map(t => (
                  <tr key={t.id} className="border-b border-gray-50 transition hover:bg-emerald-50/30">
                    <td className="px-4 py-3 text-gray-500">{new Date(t.createdAt).toLocaleString('vi-VN')}</td>
                    <td className="px-4 py-3">
                      <div className="font-medium text-gray-900">{t.userName ?? '—'}</div>
                      <div className="font-mono text-xs text-gray-400">{t.userId.slice(0, 8)}…</div>
                    </td>
                    <td className="px-4 py-3 text-gray-700">{t.description ?? '—'}</td>
                    <td className="px-4 py-3 font-mono text-xs text-gray-500">{t.referenceId ?? '—'}</td>
                    <td className="px-4 py-3 text-right font-semibold text-emerald-600">
                      +{t.amount.toLocaleString('vi-VN')} đ
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