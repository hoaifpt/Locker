import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { MapPin, Package, ChevronRight, Search } from 'lucide-react';
import { Link } from 'react-router-dom';
import AppHeader from '../../../components/layout/AppHeader';
import { hidden, visible, trans } from '../../../lib/animations';
import { getAvailableLockers, SeedLocker as Locker } from '../../../mocks/seed';

const statusColor: Record<string, string> = {
  Available: 'bg-green-400',
  Active: 'bg-orange-400',
  Pending: 'bg-yellow-400',
  Complete: 'bg-gray-300',
};

export default function LockersPage() {
  const [lockers, setLockers] = useState<Locker[]>([]);
  const [search, setSearch] = useState('');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Seed data — swap for GET /api/lockers/available when backend is ready
    setTimeout(() => { setLockers(getAvailableLockers()); setLoading(false); }, 300);
  }, []);

  const filtered = lockers.filter(
    (l) =>
      l.name.toLowerCase().includes(search.toLowerCase()) ||
      l.location.toLowerCase().includes(search.toLowerCase())
  );

  const availableCount = (l: Locker) => l.slots.filter((s) => s.status === 'Available').length;

  return (
    <div className="min-h-screen bg-[#F9F8F6] font-sans antialiased">
      <AppHeader />

      <main className="mx-auto max-w-7xl px-4 py-10 lg:px-8">
        {/* Page header */}
        <motion.div initial={hidden} animate={visible} transition={trans(0)} className="mb-8">
          <span className="inline-flex items-center gap-2 rounded-full border border-orange-200 bg-orange-50 px-4 py-1.5 text-xs font-semibold uppercase tracking-widest text-orange-600">
            Tủ khóa khả dụng
          </span>
          <h1 className="mt-3 text-3xl font-extrabold tracking-tight text-gray-900">
            Tìm tủ khóa <span className="text-orange-500">gần bạn</span>
          </h1>
          <p className="mt-2 text-sm text-gray-500">Chọn địa điểm và đặt chỗ trong vài giây.</p>
        </motion.div>

        {/* Search */}
        <motion.div initial={hidden} animate={visible} transition={trans(0.1)} className="mb-6">
          <div className="relative max-w-md">
            <span className="pointer-events-none absolute inset-y-0 left-4 flex items-center text-gray-400">
              <Search size={16} />
            </span>
            <input
              type="text"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              placeholder="Tìm theo tên hoặc địa điểm..."
              className="w-full rounded-xl border border-gray-200 bg-white py-3 pl-11 pr-4 text-sm text-gray-900 shadow-sm outline-none transition placeholder:text-gray-400 focus:border-orange-400 focus:ring-2 focus:ring-orange-100"
            />
          </div>
        </motion.div>

        {/* Locker grid */}
        {loading ? (
          <div className="grid gap-5 sm:grid-cols-2 lg:grid-cols-3">
            {[...Array(3)].map((_, i) => (
              <div key={i} className="h-52 animate-pulse rounded-3xl bg-gray-200" />
            ))}
          </div>
        ) : (
          <div className="grid gap-5 sm:grid-cols-2 lg:grid-cols-3">
            {filtered.map((locker, i) => (
              <motion.div
                key={locker.id}
                initial={hidden}
                animate={visible}
                transition={trans(0.1 + i * 0.05)}
              >
                <Link
                  to={`/lockers/${locker.id}`}
                  className="group flex h-full flex-col rounded-3xl border border-gray-100 bg-white p-6 shadow-sm shadow-orange-50 transition hover:border-orange-200 hover:shadow-md hover:shadow-orange-100/50"
                >
                  <div className="flex items-start justify-between">
                    <div className="flex h-11 w-11 items-center justify-center rounded-2xl bg-orange-100">
                      <Package size={20} className="text-orange-500" />
                    </div>
                    <span className={`rounded-full px-3 py-1 text-xs font-semibold ${availableCount(locker) > 0 ? 'bg-green-100 text-green-600' : 'bg-red-100 text-red-500'}`}>
                      {availableCount(locker) > 0 ? `${availableCount(locker)} trống` : 'Hết chỗ'}
                    </span>
                  </div>

                  <h3 className="mt-4 font-bold text-gray-900 group-hover:text-orange-500 transition">
                    {locker.name}
                  </h3>
                  <p className="mt-1 flex items-start gap-1.5 text-xs text-gray-500">
                    <MapPin size={12} className="mt-0.5 shrink-0 text-orange-400" />
                    {locker.location}
                  </p>

                  {/* Slot visual */}
                  <div className="mt-4 flex flex-wrap gap-1.5">
                    {locker.slots.map((slot) => (
                      <span
                        key={slot.index}
                        title={`Ô ${slot.index + 1}: ${slot.status}`}
                        className={`h-4 w-4 rounded-sm ${statusColor[slot.status] ?? 'bg-gray-200'}`}
                      />
                    ))}
                  </div>

                  <div className="mt-4 flex items-center gap-1 text-xs font-medium text-orange-500 opacity-0 transition group-hover:opacity-100">
                    Xem chi tiết <ChevronRight size={14} />
                  </div>
                </Link>
              </motion.div>
            ))}
          </div>
        )}

        {/* Legend */}
        <div className="mt-8 flex flex-wrap items-center gap-4 text-xs text-gray-500">
          {Object.entries(statusColor).map(([label, cls]) => (
            <span key={label} className="flex items-center gap-1.5">
              <span className={`h-3 w-3 rounded-sm ${cls}`} /> {label}
            </span>
          ))}
        </div>
      </main>
    </div>
  );
}
