import { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { MapPin, Package, ChevronRight, ArrowLeft } from 'lucide-react';
import { Link, useParams, useNavigate } from 'react-router-dom';
import AppHeader from '../../../components/layout/AppHeader';
import MapView from '../../../components/ui/MapView';
import { hidden, visible, trans } from '../../../lib/animations';
import { getLockerById, SeedLocker as Locker } from '../../../mocks/seed';

const STATUS_STYLE: Record<string, { label: string; cls: string; dotCls: string }> = {
  Available: { label: 'Trống', cls: 'border-green-300 bg-green-50', dotCls: 'bg-green-400' },
  Active: { label: 'Đang dùng', cls: 'border-orange-300 bg-orange-50', dotCls: 'bg-orange-400' },
  Pending: { label: 'Chờ xử lý', cls: 'border-yellow-300 bg-yellow-50', dotCls: 'bg-yellow-400' },
  Complete: { label: 'Đã dùng', cls: 'border-gray-200 bg-gray-50', dotCls: 'bg-gray-300' },
};

export default function LockerDetailPage() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [locker, setLocker] = useState<Locker | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Seed data — swap for GET /api/lockers/:id when backend is ready
    setTimeout(() => {
      const found = getLockerById(id ?? '') ?? null;
      setLocker(found);
      setLoading(false);
    }, 300);
  }, [id]);

  const handleBook = () => {
    navigate(`/orders/new?lockerId=${id}`);
  };

  if (loading) return (
    <div className="min-h-screen bg-[#F9F8F6]">
      <AppHeader />
      <div className="flex h-96 items-center justify-center">
        <div className="h-8 w-8 animate-spin rounded-full border-4 border-orange-500 border-t-transparent" />
      </div>
    </div>
  );

  if (!locker) return null;

  return (
    <div className="min-h-screen bg-[#F9F8F6] font-sans antialiased">
      <AppHeader />

      <main className="mx-auto max-w-4xl px-4 py-10 lg:px-8">
        {/* Back */}
        <Link to="/lockers" className="mb-6 inline-flex items-center gap-1.5 text-sm font-medium text-gray-500 hover:text-orange-500">
          <ArrowLeft size={15} /> Quay lại
        </Link>

        {/* Locker info */}
        <motion.div initial={hidden} animate={visible} transition={trans(0)} className="mb-8 rounded-3xl border border-gray-100 bg-white p-6 shadow-sm">
          <div className="flex items-start gap-4">
            <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded-2xl bg-orange-100">
              <Package size={22} className="text-orange-500" />
            </div>
            <div>
              <h1 className="text-2xl font-extrabold text-gray-900">{locker.name}</h1>
              <p className="mt-1 flex items-center gap-1.5 text-sm text-gray-500">
                <MapPin size={13} className="text-orange-400" /> {locker.location}
              </p>
            </div>
          </div>
        </motion.div>

        <div className="grid gap-6 lg:grid-cols-2">
          {/* Slot picker */}
          <motion.div initial={hidden} animate={visible} transition={trans(0.1)} className="rounded-3xl border border-gray-100 bg-white p-6 shadow-sm">
            <h2 className="mb-1 font-bold text-gray-900">Chọn ô tủ</h2>
            <p className="mb-4 text-xs text-gray-400">Chỉ các ô trống mới có thể đặt.</p>
            <div className="grid grid-cols-4 gap-2">
              {locker.slots.map((slot) => {
                const style = STATUS_STYLE[slot.status] ?? STATUS_STYLE['Active'];
                const isAvailable = slot.status === 'Available';
                return (
                  <div
                    key={slot.index}
                    className={`relative flex flex-col items-center rounded-xl border-2 p-2.5 text-xs font-semibold transition ${
                          isAvailable
                          ? 'border-green-300 bg-green-50 text-green-700'
                          : 'border-gray-200 bg-gray-50 text-gray-300 cursor-not-allowed'
                      }`}
                  >
                    <span className={`mb-1 h-2 w-2 rounded-full ${style.dotCls}`} />
                    Ô {slot.index + 1}
                  </div>
                );
              })}
            </div>
            {/* Legend */}
            <div className="mt-4 flex gap-4 text-xs text-gray-400">
              {Object.entries(STATUS_STYLE).map(([key, v]) => (
                <span key={key} className="flex items-center gap-1">
                  <span className={`h-2 w-2 rounded-full ${v.dotCls}`} /> {v.label}
                </span>
              ))}
            </div>
          </motion.div>

          {/* Create Order redirect */}
          <motion.div initial={hidden} animate={visible} transition={trans(0.15)} className="rounded-3xl border border-gray-100 bg-white p-6 shadow-sm flex flex-col justify-center items-center text-center">
            <Package size={48} className="text-orange-500 mb-4" />
            <h2 className="mb-2 text-xl font-bold text-gray-900">Tiến hành đặt tủ</h2>
            <p className="mb-6 text-sm text-gray-500">Bạn có thể chọn gói dịch vụ, thời gian thuê và thanh toán ngay trên ứng dụng.</p>
            <button
              onClick={handleBook}
              className="flex w-full max-w-xs items-center justify-center gap-2 rounded-xl bg-orange-500 py-3.5 text-sm font-semibold text-white shadow-md shadow-orange-200 transition hover:bg-orange-600 active:scale-95"
            >
              Đặt tủ khóa này <ChevronRight size={16} />
            </button>
          </motion.div>
        </div>



        {/* Location map - Bottom */}
        <motion.div initial={hidden} animate={visible} transition={trans(0.3)} className="mt-12">
          <MapView locker={locker} height="400px" />
        </motion.div>
      </main>
    </div>
  );
}
