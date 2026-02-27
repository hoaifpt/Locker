import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { MapPin, Package, ChevronRight, Phone, ArrowLeft } from 'lucide-react';
import { Link, useParams, useNavigate } from 'react-router-dom';
import AppHeader from '../../../components/layout/AppHeader';
import { hidden, visible, trans } from '../../../lib/animations';
import { getLockerById, SEED_PACKAGES, SeedLocker as Locker, SeedPackage as PackageDto } from '../../../mocks/seed';

const STATUS_STYLE: Record<string, { label: string; cls: string; dotCls: string }> = {
  Available: { label: 'Trống',     cls: 'border-green-300 bg-green-50',   dotCls: 'bg-green-400' },
  Active:    { label: 'Đang dùng', cls: 'border-orange-300 bg-orange-50', dotCls: 'bg-orange-400' },
  Pending:   { label: 'Chờ xử lý', cls: 'border-yellow-300 bg-yellow-50', dotCls: 'bg-yellow-400' },
  Complete:  { label: 'Đã dùng',   cls: 'border-gray-200 bg-gray-50',     dotCls: 'bg-gray-300' },
};

export default function LockerDetailPage() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [locker, setLocker] = useState<Locker | null>(null);
  const [packages, setPackages] = useState<PackageDto[]>([]);
  const [selectedSlot, setSelectedSlot] = useState<number | null>(null);
  const [selectedPackage, setSelectedPackage] = useState('');
  const [mobile, setMobile] = useState('');
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);

  useEffect(() => {
    // Seed data — swap for GET /api/lockers/:id & GET /api/packages when backend is ready
    setTimeout(() => {
      const found = getLockerById(id ?? '') ?? null;
      setLocker(found);
      setPackages(SEED_PACKAGES.filter((p) => p.isActive));
      setLoading(false);
    }, 300);
  }, [id]);

  const handleBook = async (e: React.FormEvent) => {
    e.preventDefault();
    if (selectedSlot === null) return;
    setSubmitting(true);
    // TODO: POST /api/bookings { lockerId: id, slotIndex: selectedSlot, packageId: selectedPackage, mobileNumber: mobile }
    await new Promise((r) => setTimeout(r, 1000));
    setSubmitting(false);
    navigate('/bookings');
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
                  <button
                    key={slot.index}
                    disabled={!isAvailable}
                    onClick={() => setSelectedSlot(slot.index)}
                    className={`relative flex flex-col items-center rounded-xl border-2 p-2.5 text-xs font-semibold transition ${
                      selectedSlot === slot.index
                        ? 'border-orange-500 bg-orange-50 text-orange-600'
                        : isAvailable
                        ? 'border-green-300 bg-green-50 text-green-700 hover:border-orange-400'
                        : 'border-gray-200 bg-gray-50 text-gray-300 cursor-not-allowed'
                    }`}
                  >
                    <span className={`mb-1 h-2 w-2 rounded-full ${selectedSlot === slot.index ? 'bg-orange-500' : style.dotCls}`} />
                    Ô {slot.index + 1}
                  </button>
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

          {/* Booking form */}
          <motion.div initial={hidden} animate={visible} transition={trans(0.15)} className="rounded-3xl border border-gray-100 bg-white p-6 shadow-sm">
            <h2 className="mb-4 font-bold text-gray-900">Thông tin đặt chỗ</h2>
            <form onSubmit={handleBook} className="space-y-4">
              {/* Package select */}
              <div>
                <label className="mb-1.5 block text-sm font-medium text-gray-700">
                  Gói dịch vụ <span className="text-orange-500">*</span>
                </label>
                <select
                  value={selectedPackage}
                  onChange={(e) => setSelectedPackage(e.target.value)}
                  required
                  className="w-full rounded-xl border border-gray-200 bg-gray-50 py-3 px-4 text-sm text-gray-900 outline-none transition focus:border-orange-400 focus:bg-white focus:ring-2 focus:ring-orange-100"
                >
                  <option value="">-- Chọn gói --</option>
                  {packages.map((p) => (
                    <option key={p.id} value={p.id}>
                      {p.name} — {p.pricePerHour.toLocaleString('vi-VN')}đ/giờ
                    </option>
                  ))}
                </select>
              </div>

              {/* Mobile number */}
              <div>
                <label className="mb-1.5 block text-sm font-medium text-gray-700">
                  Số điện thoại nhận thông báo <span className="text-orange-500">*</span>
                </label>
                <div className="relative">
                  <span className="pointer-events-none absolute inset-y-0 left-4 flex items-center text-gray-400">
                    <Phone size={16} />
                  </span>
                  <input
                    type="tel"
                    value={mobile}
                    onChange={(e) => setMobile(e.target.value)}
                    placeholder="0912 345 678"
                    required
                    className="w-full rounded-xl border border-gray-200 bg-gray-50 py-3 pl-11 pr-4 text-sm text-gray-900 outline-none transition placeholder:text-gray-400 focus:border-orange-400 focus:bg-white focus:ring-2 focus:ring-orange-100"
                  />
                </div>
              </div>

              {/* Summary */}
              {selectedSlot !== null && (
                <div className="rounded-xl border border-orange-200 bg-orange-50 p-3 text-sm">
                  <p className="font-semibold text-orange-700">Xác nhận đặt chỗ:</p>
                  <p className="mt-1 text-orange-600">Ô tủ số <strong>{selectedSlot + 1}</strong></p>
                </div>
              )}

              <button
                type="submit"
                disabled={submitting || selectedSlot === null}
                className="flex w-full items-center justify-center gap-2 rounded-xl bg-orange-500 py-3 text-sm font-semibold text-white shadow-md shadow-orange-200 transition hover:bg-orange-600 disabled:opacity-60"
              >
                {submitting ? 'Đang xử lý...' : <>Đặt chỗ ngay <ChevronRight size={16} /></>}
              </button>
            </form>
          </motion.div>
        </div>
      </main>
    </div>
  );
}
