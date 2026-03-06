import { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { MapPin, Package, ChevronRight, Phone, ArrowLeft, Mail, MessageSquare } from 'lucide-react';
import { Link, useParams, useNavigate } from 'react-router-dom';
import AppHeader from '../../../components/layout/AppHeader';
import BookingConfirmationModal, { BookingConfirmationData } from '../../../components/ui/BookingConfirmationModal';
import MapView from '../../../components/ui/MapView';
import { hidden, visible, trans } from '../../../lib/animations';
import { getLockerById, SEED_PACKAGES, SeedLocker as Locker, SeedPackage as PackageDto } from '../../../mocks/seed';
import { validatePhoneNumber, validateEmail } from '../../../lib/validators';
import { useLockerSizeInfo } from '../../../components/ui/LockerSizeInfo';
import { useToast } from '../../../context/ToastContext';

const STATUS_STYLE: Record<string, { label: string; cls: string; dotCls: string }> = {
  Available: { label: 'Trống', cls: 'border-green-300 bg-green-50', dotCls: 'bg-green-400' },
  Active: { label: 'Đang dùng', cls: 'border-orange-300 bg-orange-50', dotCls: 'bg-orange-400' },
  Pending: { label: 'Chờ xử lý', cls: 'border-yellow-300 bg-yellow-50', dotCls: 'bg-yellow-400' },
  Complete: { label: 'Đã dùng', cls: 'border-gray-200 bg-gray-50', dotCls: 'bg-gray-300' },
};

export default function LockerDetailPage() {
  const { id } = useParams();
  const navigate = useNavigate();
  const { show: showToast } = useToast();
  const [locker, setLocker] = useState<Locker | null>(null);
  const [packages, setPackages] = useState<PackageDto[]>([]);
  const [selectedSlot, setSelectedSlot] = useState<number | null>(null);
  const [selectedPackage, setSelectedPackage] = useState('');
  const [selectedSize, setSelectedSize] = useState<'S' | 'M' | 'L' | 'XL' | null>(null);
  const [mobile, setMobile] = useState('');
  const [email, setEmail] = useState('');
  const [productNote, setProductNote] = useState('');
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [showConfirmation, setShowConfirmation] = useState(false);
  const [confirmationData, setConfirmationData] = useState<BookingConfirmationData | null>(null);
  const [errors, setErrors] = useState<Record<string, string>>({});

  const lockerSizeInfo = useLockerSizeInfo(selectedSize ?? 'S');

  useEffect(() => {
    // Seed data — swap for GET /api/lockers/:id & GET /api/packages when backend is ready
    setTimeout(() => {
      const found = getLockerById(id ?? '') ?? null;
      setLocker(found);
      setPackages(SEED_PACKAGES.filter((p) => p.isActive));
      setLoading(false);
    }, 300);
  }, [id]);

  const validateForm = (): boolean => {
    const newErrors: Record<string, string> = {};

    if (!selectedPackage) newErrors.selectedPackage = 'Vui lòng chọn gói dịch vụ';
    if (selectedSlot === null) newErrors.selectedSlot = 'Vui lòng chọn ô tủ';

    const phoneValidation = validatePhoneNumber(mobile);
    if (!phoneValidation.valid) newErrors.mobile = phoneValidation.error || 'Số điện thoại không hợp lệ';

    if (email && !validateEmail(email).valid) {
      newErrors.email = 'Email không hợp lệ';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleBook = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!validateForm()) return;
    if (selectedSlot === null) return;

    const selectedPkg = packages.find((p) => p.id === selectedPackage);
    if (!selectedPkg) return;

    // Create confirmation data
    const data: BookingConfirmationData = {
      bookingId: `BK-${Date.now().toString().slice(-6)}`,
      selectedSlot,
      selectedPackageName: selectedPkg.name,
      selectedPackagePrice: selectedPkg.pricePerHour,
      selectedSize: selectedPkg.size,
      mobileNumber: mobile,
      email: email || undefined,
      productNote: productNote || undefined,
      lockerName: locker?.name || '',
      lockerLocation: locker?.location || '',
    };

    setConfirmationData(data);
    setShowConfirmation(true);
  };

  const handleConfirmBooking = async () => {
    setSubmitting(true);
    // TODO: POST /api/bookings
    await new Promise((r) => setTimeout(r, 1000));
    setSubmitting(false);
    setShowConfirmation(false);

    showToast('✓ Đặt chỗ thành công!', 'success');
    showToast('📧 Hướng dẫn đã được gửi đến email của bạn', 'notification');

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
                    className={`relative flex flex-col items-center rounded-xl border-2 p-2.5 text-xs font-semibold transition ${selectedSlot === slot.index
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
                <label className="mb-1.5 flex items-center gap-1 text-sm font-medium text-gray-700">
                  Gói dịch vụ <span className="text-orange-500">*</span>
                </label>
                <select
                  value={selectedPackage}
                  onChange={(e) => {
                    setSelectedPackage(e.target.value);
                    const pkg = packages.find((p) => p.id === e.target.value);
                    if (pkg) setSelectedSize(pkg.size);
                  }}
                  className={`w-full rounded-xl border py-3 px-4 text-sm text-gray-900 outline-none transition bg-gray-50 ${errors.selectedPackage ? 'border-red-400 focus:ring-red-100' : 'border-gray-200 focus:ring-orange-100'
                    } focus:border-orange-400 focus:bg-white focus:ring-2`}
                >
                  <option value="">-- Chọn gói --</option>
                  {packages.map((p) => (
                    <option key={p.id} value={p.id}>
                      {p.name} — {p.pricePerHour.toLocaleString('vi-VN')}đ/giờ
                    </option>
                  ))}
                </select>
                {errors.selectedPackage && <p className="mt-1 text-xs text-red-500">{errors.selectedPackage}</p>}
              </div>

              {/* Locker size info (if selected) */}
              {selectedSize && lockerSizeInfo && (
                <div className="rounded-2xl border border-blue-200 bg-blue-50 p-3 text-sm">
                  <p className="font-semibold text-blue-700">Kích thước: Size {selectedSize}</p>
                  <div className="mt-2 grid grid-cols-3 gap-2 text-xs text-blue-600">
                    <div>
                      <p className="font-semibold">Cao: {lockerSizeInfo.dimensions.height}cm</p>
                    </div>
                    <div>
                      <p className="font-semibold">Rộng: {lockerSizeInfo.dimensions.width}cm</p>
                    </div>
                    <div>
                      <p className="font-semibold">Sâu: {lockerSizeInfo.dimensions.depth}cm</p>
                    </div>
                  </div>
                </div>
              )}

              {/* Mobile number */}
              <div>
                <label className="mb-1.5 flex items-center gap-1 text-sm font-medium text-gray-700">
                  Số điện thoại <span className="text-orange-500">*</span>
                </label>
                <div className="relative">
                  <span className="pointer-events-none absolute inset-y-0 left-4 flex items-center text-gray-400">
                    <Phone size={16} />
                  </span>
                  <input
                    type="tel"
                    value={mobile}
                    onChange={(e) => {
                      setMobile(e.target.value);
                      if (errors.mobile) setErrors({ ...errors, mobile: '' });
                    }}
                    placeholder="0912 345 678"
                    className={`w-full rounded-xl border py-3 pl-11 pr-4 text-sm text-gray-900 outline-none transition bg-gray-50 placeholder:text-gray-400 ${errors.mobile ? 'border-red-400 focus:ring-red-100' : 'border-gray-200 focus:ring-orange-100'
                      } focus:border-orange-400 focus:bg-white focus:ring-2`}
                  />
                </div>
                {errors.mobile && <p className="mt-1 text-xs text-red-500">{errors.mobile}</p>}
              </div>

              {/* Email (optional) */}
              <div>
                <label className="mb-1.5 flex items-center gap-1 text-sm font-medium text-gray-700">
                  Email <span className="text-xs text-gray-400">(tùy chọn)</span>
                </label>
                <div className="relative">
                  <span className="pointer-events-none absolute inset-y-0 left-4 flex items-center text-gray-400">
                    <Mail size={16} />
                  </span>
                  <input
                    type="email"
                    value={email}
                    onChange={(e) => {
                      setEmail(e.target.value);
                      if (errors.email) setErrors({ ...errors, email: '' });
                    }}
                    placeholder="your@email.com"
                    className={`w-full rounded-xl border py-3 pl-11 pr-4 text-sm text-gray-900 outline-none transition bg-gray-50 placeholder:text-gray-400 ${errors.email ? 'border-red-400 focus:ring-red-100' : 'border-gray-200 focus:ring-orange-100'
                      } focus:border-orange-400 focus:bg-white focus:ring-2`}
                  />
                </div>
                {errors.email && <p className="mt-1 text-xs text-red-500">{errors.email}</p>}
              </div>

              {/* Product note (optional) */}
              <div>
                <label className="mb-1.5 flex items-center gap-1 text-sm font-medium text-gray-700">
                  Ghi chú về sản phẩm <span className="text-xs text-gray-400">(tùy chọn)</span>
                </label>
                <div className="relative">
                  <span className="pointer-events-none absolute top-3 left-4 flex items-center text-gray-400">
                    <MessageSquare size={16} />
                  </span>
                  <textarea
                    value={productNote}
                    onChange={(e) => {
                      setProductNote(e.target.value);
                      if (errors.productNote) setErrors({ ...errors, productNote: '' });
                    }}
                    placeholder="Mô tả sản phẩm mà bạn sắp gửi..."
                    maxLength={500}
                    rows={3}
                    className={`w-full rounded-xl border py-3 pl-11 pr-4 text-sm text-gray-900 outline-none transition bg-gray-50 placeholder:text-gray-400 ${errors.productNote ? 'border-red-400 focus:ring-red-100' : 'border-gray-200 focus:ring-orange-100'
                      } focus:border-orange-400 focus:bg-white focus:ring-2 resize-none`}
                  />
                </div>
                <p className="mt-1 text-xs text-gray-400">{productNote.length}/500</p>
              </div>

              {/* Summary */}
              {selectedSlot !== null && (
                <div className="rounded-xl border border-orange-200 bg-orange-50 p-3 text-sm">
                  <p className="font-semibold text-orange-700">Xác nhận đặt chỗ:</p>
                  <p className="mt-1 text-orange-600">Ô tủ số <strong>{selectedSlot + 1}</strong></p>
                </div>
              )}

              {errors.selectedSlot && <p className="text-xs text-red-500">{errors.selectedSlot}</p>}

              <button
                type="submit"
                disabled={submitting || selectedSlot === null}
                className="flex w-full items-center justify-center gap-2 rounded-xl bg-orange-500 py-3 text-sm font-semibold text-white shadow-md shadow-orange-200 transition hover:bg-orange-600 disabled:opacity-60"
              >
                {submitting ? 'Đang xử lý...' : <>Tiếp tục <ChevronRight size={16} /></>}
              </button>
            </form>
          </motion.div>
        </div>

        {/* Booking confirmation modal */}
        <AnimatePresence>
          {showConfirmation && confirmationData && (
            <BookingConfirmationModal
              data={confirmationData}
              onConfirm={handleConfirmBooking}
              onEdit={() => setShowConfirmation(false)}
              isSubmitting={submitting}
            />
          )}
        </AnimatePresence>

        {/* Location map - Bottom */}
        <motion.div initial={hidden} animate={visible} transition={trans(0.3)} className="mt-12">
          <MapView locker={locker} height="400px" />
        </motion.div>
      </main>
    </div>
  );
}
