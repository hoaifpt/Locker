import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { MapPin, Package, ChevronRight, Search, AlertCircle } from 'lucide-react';
import { Link } from 'react-router-dom';
import AppHeader from '../../../components/layout/AppHeader';
import { hidden, visible, trans } from '../../../lib/animations';
import { apiFetch } from '../../../lib/api';
import { useToast } from '../../../context/ToastContext';

type LockerSlot = {
  index: number;
  status: number; // 0: Available, 1: Used, 2: Maintenance/Other
  size: string;
  sensorState: string;
};

type Locker = {
  id: string;
  name: string;
  location: string;
  latitude: number;
  longitude: number;
  slots: LockerSlot[];
};

const statusColor: Record<string, string> = {
  Available: 'bg-green-400',
  Active: 'bg-orange-400',
  Pending: 'bg-yellow-400',
  Other: 'bg-gray-300',
};

const SLOT_STATUS_MAP: Record<number, string> = {
  0: 'Available',
  1: 'Active',
  2: 'Pending',
};

export default function LockersPage() {
  const [lockers, setLockers] = useState<Locker[]>([]);
  const [search, setSearch] = useState('');
  const [loading, setLoading] = useState(true);
  const { show: showToast } = useToast();

  useEffect(() => {
    const fetchLockers = async () => {
      setLoading(true);
      try {
        const response = await apiFetch('/lockers');
        if (!response.ok) throw new Error('Không thể tải danh sách tủ khóa.');
        const data = (await response.json()) as Locker[];
        setLockers(data);
      } catch (error) {
        showToast(error instanceof Error ? error.message : 'Lỗi không xác định', 'error');
      } finally {
        setLoading(false);
      }
    };
    fetchLockers();
  }, [showToast]);

  const filtered = lockers.filter(
    (l) =>
      l.name.toLowerCase().includes(search.toLowerCase()) ||
      l.location.toLowerCase().includes(search.toLowerCase())
  );

  const availableCount = (l: Locker) => l.slots.filter((s) => s.status === 0).length;

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
        ) : filtered.length === 0 ? (
          <div className="rounded-3xl border bg-white py-16 text-center shadow-sm">
            <AlertCircle size={48} className="mx-auto mb-4 text-gray-300" />
            <h3 className="text-lg font-bold text-gray-900">Không tìm thấy tủ khóa</h3>
            <p className="mt-1 text-sm text-gray-500">Vui lòng thử lại với từ khóa khác.</p>
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
                    {locker.slots.map((slot) => {
                      const statusString = SLOT_STATUS_MAP[slot.status] ?? 'Other';
                      return (
                        <span
                          key={slot.index}
                          title={`Ô ${slot.index}: ${statusString}`}
                          className={`h-4 w-4 rounded-sm ${statusColor[statusString] ?? 'bg-gray-200'}`}
                        />
                      );
                    })}
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
          {Object.entries(SLOT_STATUS_MAP).map(([, label]) => (
            <span key={label} className="flex items-center gap-1.5">
              <span className={`h-3 w-3 rounded-sm ${statusColor[label]}`} />
              {label === 'Available' ? 'Trống' : label === 'Active' ? 'Đang dùng' : 'Khác'}
            </span>
          ))}
        </div>
      </main>
    </div>
  );
}
