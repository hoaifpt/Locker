import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { CalendarDays, MapPin, ChevronRight, Package } from 'lucide-react';
import { Link } from 'react-router-dom';
import AppHeader from '../../../components/layout/AppHeader';
import { hidden, visible, trans } from '../../../lib/animations';
import { getBookingsByUser, SeedBooking as BookingDto } from '../../../mocks/seed';

// Simulated logged-in user — set by login page, replace with real token when backend is ready
const CURRENT_USER_ID = localStorage.getItem('userId') ?? 'u-001';

const STATUS_STYLE: Record<string, { label: string; cls: string }> = {
  Pending:   { label: 'Chờ PIN',    cls: 'bg-yellow-100 text-yellow-700' },
  Active:    { label: 'Đang dùng',  cls: 'bg-green-100 text-green-700' },
  Completed: { label: 'Hoàn thành', cls: 'bg-blue-100 text-blue-700' },
  Canceled:  { label: 'Đã hủy',     cls: 'bg-gray-100 text-gray-500' },
  Expired:   { label: 'Hết hạn',    cls: 'bg-red-100 text-red-500' },
};

const ALL_STATUSES = ['Tất cả', 'Pending', 'Active', 'Completed', 'Canceled'];

export default function BookingsPage() {
  const [bookings, setBookings] = useState<BookingDto[]>([]);
  const [filter, setFilter] = useState('Tất cả');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Seed data — swap for GET /api/bookings/my when backend is ready
    setTimeout(() => { setBookings(getBookingsByUser(CURRENT_USER_ID)); setLoading(false); }, 300);
  }, []);

  const filtered = filter === 'Tất cả' ? bookings : bookings.filter((b) => b.status === filter);

  return (
    <div className="min-h-screen bg-[#F9F8F6] font-sans antialiased">
      <AppHeader />

      <main className="mx-auto max-w-4xl px-4 py-10 lg:px-8">
        {/* Header */}
        <motion.div initial={hidden} animate={visible} transition={trans(0)} className="mb-8">
          <span className="inline-flex items-center gap-2 rounded-full border border-orange-200 bg-orange-50 px-4 py-1.5 text-xs font-semibold uppercase tracking-widest text-orange-600">
            Lịch sử đặt chỗ
          </span>
          <h1 className="mt-3 text-3xl font-extrabold tracking-tight text-gray-900">
            Đặt chỗ <span className="text-orange-500">của tôi</span>
          </h1>
        </motion.div>

        {/* Filter tabs */}
        <motion.div initial={hidden} animate={visible} transition={trans(0.1)} className="mb-6 flex flex-wrap gap-2">
          {ALL_STATUSES.map((s) => (
            <button
              key={s}
              onClick={() => setFilter(s)}
              className={`rounded-xl px-4 py-2 text-sm font-medium transition ${
                filter === s
                  ? 'bg-orange-500 text-white shadow-md shadow-orange-200'
                  : 'border border-gray-200 bg-white text-gray-600 hover:border-orange-300 hover:text-orange-500'
              }`}
            >
              {s === 'Tất cả' ? s : (STATUS_STYLE[s]?.label ?? s)}
            </button>
          ))}
        </motion.div>

        {/* List */}
        {loading ? (
          <div className="space-y-4">
            {[...Array(3)].map((_, i) => (
              <div key={i} className="h-28 animate-pulse rounded-3xl bg-gray-200" />
            ))}
          </div>
        ) : filtered.length === 0 ? (
          <div className="rounded-3xl border border-gray-100 bg-white py-16 text-center shadow-sm">
            <Package size={32} className="mx-auto mb-3 text-gray-300" />
            <p className="text-sm text-gray-400">Không có đặt chỗ nào.</p>
            <Link to="/lockers" className="mt-4 inline-flex items-center gap-1 text-sm font-semibold text-orange-500 hover:text-orange-600">
              Đặt chỗ ngay <ChevronRight size={14} />
            </Link>
          </div>
        ) : (
          <div className="space-y-4">
            {filtered.map((b, i) => (
              <motion.div key={b.id} initial={hidden} animate={visible} transition={trans(0.1 + i * 0.05)}>
                <Link
                  to={`/bookings/${b.id}`}
                  className="group flex items-center gap-4 rounded-3xl border border-gray-100 bg-white p-5 shadow-sm transition hover:border-orange-200 hover:shadow-md hover:shadow-orange-100/40"
                >
                  <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded-2xl bg-orange-100">
                    <Package size={20} className="text-orange-500" />
                  </div>
                  <div className="min-w-0 flex-1">
                    <div className="flex items-start justify-between gap-2">
                      <h3 className="truncate font-bold text-gray-900 group-hover:text-orange-500 transition">
                        {b.lockerName} — Ô {b.slotIndex + 1}
                      </h3>
                      <span className={`shrink-0 rounded-full px-2.5 py-0.5 text-xs font-semibold ${STATUS_STYLE[b.status]?.cls ?? 'bg-gray-100 text-gray-500'}`}>
                        {STATUS_STYLE[b.status]?.label ?? b.status}
                      </span>
                    </div>
                    <p className="mt-0.5 flex items-center gap-1 text-xs text-gray-500">
                      <MapPin size={11} className="text-orange-400" /> {b.lockerLocation}
                    </p>
                    <div className="mt-1.5 flex flex-wrap items-center gap-3 text-xs text-gray-400">
                      <span className="flex items-center gap-1">
                        <CalendarDays size={11} /> {new Date(b.createdAt).toLocaleDateString('vi-VN')}
                      </span>
                      <span>{b.packageName}</span>
                      {b.totalAmount > 0 && (
                        <span className="font-semibold text-orange-500">
                          {b.totalAmount.toLocaleString('vi-VN')}đ
                        </span>
                      )}
                    </div>
                  </div>
                  <ChevronRight size={16} className="shrink-0 text-gray-300 group-hover:text-orange-400 transition" />
                </Link>
              </motion.div>
            ))}
          </div>
        )}
      </main>
    </div>
  );
}
