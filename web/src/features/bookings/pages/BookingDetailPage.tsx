import { useState, useEffect, useRef } from 'react';
import { motion } from 'framer-motion';
import { MapPin, Package, ArrowLeft, KeyRound, CheckCircle, XCircle, Eye, EyeOff } from 'lucide-react';
import { Link, useParams } from 'react-router-dom';
import AppHeader from '../../../components/layout/AppHeader';
import { hidden, visible, trans } from '../../../lib/animations';
import { getBookingById, SeedBooking as BookingDetail } from '../../../mocks/seed';

const STATUS_STYLE: Record<string, { label: string; cls: string }> = {
  Pending:   { label: 'Chờ PIN',    cls: 'bg-yellow-100 text-yellow-700' },
  Active:    { label: 'Đang dùng',  cls: 'bg-green-100 text-green-700' },
  Completed: { label: 'Hoàn thành', cls: 'bg-blue-100 text-blue-700' },
  Canceled:  { label: 'Đã hủy',     cls: 'bg-gray-100 text-gray-500' },
  Expired:   { label: 'Hết hạn',    cls: 'bg-red-100 text-red-500' },
};

export default function BookingDetailPage() {
  const { id } = useParams();
  const [booking, setBooking] = useState<BookingDetail | null>(null);
  const [loading, setLoading] = useState(true);
  const [pin, setPin] = useState(['', '', '', '', '', '']);
  const [showPin, setShowPin] = useState(false);
  const [verifyPin, setVerifyPin] = useState('');
  const [actionLoading, setActionLoading] = useState<string | null>(null);
  const pinRefs = useRef<(HTMLInputElement | null)[]>([]);

  useEffect(() => {
    // Seed data — swap for GET /api/bookings/:id when backend is ready
    setTimeout(() => { setBooking(getBookingById(id ?? '') ?? null); setLoading(false); }, 300);
  }, [id]);

  const handlePinChange = (i: number, val: string) => {
    if (!/^\d*$/.test(val)) return;
    const next = [...pin]; next[i] = val.slice(-1); setPin(next);
    if (val && i < 5) pinRefs.current[i + 1]?.focus();
  };
  const handlePinKeyDown = (i: number, e: React.KeyboardEvent) => {
    if (e.key === 'Backspace' && !pin[i] && i > 0) pinRefs.current[i - 1]?.focus();
  };

  const doAction = async (action: string, body?: object) => {
    setActionLoading(action);
    // TODO: POST /api/bookings/:id/:action
    await new Promise((r) => setTimeout(r, 800));
    if (action === 'set-pin') setBooking((b) => b ? { ...b, status: 'Active', startedAt: new Date().toISOString() } : b);
    if (action === 'complete') setBooking((b) => b ? { ...b, status: 'Completed', completedAt: new Date().toISOString(), totalAmount: 50000 } : b);
    if (action === 'cancel') setBooking((b) => b ? { ...b, status: 'Canceled' } : b);
    setActionLoading(null);
  };

  if (loading) return (
    <div className="min-h-screen bg-[#F9F8F6]"><AppHeader />
      <div className="flex h-96 items-center justify-center">
        <div className="h-8 w-8 animate-spin rounded-full border-4 border-orange-500 border-t-transparent" />
      </div>
    </div>
  );
  if (!booking) return null;

  const st = STATUS_STYLE[booking.status];

  return (
    <div className="min-h-screen bg-[#F9F8F6] font-sans antialiased">
      <AppHeader />
      <main className="mx-auto max-w-2xl px-4 py-10 lg:px-8">
        <Link to="/bookings" className="mb-6 inline-flex items-center gap-1.5 text-sm font-medium text-gray-500 hover:text-orange-500">
          <ArrowLeft size={15} /> Quay lại
        </Link>

        {/* Booking card */}
        <motion.div initial={hidden} animate={visible} transition={trans(0)} className="mb-6 rounded-3xl border border-gray-100 bg-white p-6 shadow-sm">
          <div className="flex items-start justify-between gap-3">
            <div className="flex items-center gap-3">
              <div className="flex h-11 w-11 items-center justify-center rounded-2xl bg-orange-100">
                <Package size={20} className="text-orange-500" />
              </div>
              <div>
                <h1 className="font-bold text-gray-900">{booking.lockerName}</h1>
                <p className="flex items-center gap-1 text-xs text-gray-500">
                  <MapPin size={11} className="text-orange-400" /> {booking.lockerLocation}
                </p>
              </div>
            </div>
            <span className={`rounded-full px-3 py-1 text-xs font-semibold ${st?.cls}`}>{st?.label}</span>
          </div>

          <div className="mt-5 grid grid-cols-2 gap-4 rounded-2xl bg-gray-50 p-4 text-sm">
            <div><p className="text-xs text-gray-400">Ô tủ</p><p className="font-bold text-gray-800">Ô {booking.slotIndex + 1}</p></div>
            <div><p className="text-xs text-gray-400">Gói dịch vụ</p><p className="font-bold text-gray-800">{booking.packageName}</p></div>
            <div><p className="text-xs text-gray-400">Số điện thoại</p><p className="font-bold text-gray-800">{booking.mobileNumber}</p></div>
            <div><p className="text-xs text-gray-400">Ngày tạo</p><p className="font-bold text-gray-800">{new Date(booking.createdAt).toLocaleDateString('vi-VN')}</p></div>
            {booking.startedAt && <div><p className="text-xs text-gray-400">Bắt đầu</p><p className="font-bold text-gray-800">{new Date(booking.startedAt).toLocaleTimeString('vi-VN')}</p></div>}
            {booking.completedAt && <div><p className="text-xs text-gray-400">Kết thúc</p><p className="font-bold text-gray-800">{new Date(booking.completedAt).toLocaleTimeString('vi-VN')}</p></div>}
            {booking.totalAmount > 0 && (
              <div className="col-span-2">
                <p className="text-xs text-gray-400">Tổng tiền</p>
                <p className="text-xl font-extrabold text-orange-500">{booking.totalAmount.toLocaleString('vi-VN')}đ</p>
              </div>
            )}
          </div>
        </motion.div>

        {/* Actions */}
        {booking.status === 'Pending' && (
          <motion.div initial={hidden} animate={visible} transition={trans(0.1)} className="mb-4 rounded-3xl border border-gray-100 bg-white p-6 shadow-sm">
            <h2 className="mb-1 flex items-center gap-2 font-bold text-gray-900"><KeyRound size={16} className="text-orange-500" /> Thiết lập mã PIN</h2>
            <p className="mb-4 text-xs text-gray-400">Nhập mã PIN 6 chữ số để kích hoạt tủ khóa.</p>
            <div className="flex justify-center gap-2 mb-4">
              {pin.map((d, i) => (
                <input
                  key={i}
                  ref={(el) => { pinRefs.current[i] = el; }}
                  type={showPin ? 'text' : 'password'}
                  inputMode="numeric"
                  maxLength={1}
                  value={d}
                  onChange={(e) => handlePinChange(i, e.target.value)}
                  onKeyDown={(e) => handlePinKeyDown(i, e)}
                  className="h-12 w-12 rounded-xl border border-gray-200 bg-gray-50 text-center text-lg font-bold text-gray-900 outline-none transition focus:border-orange-400 focus:ring-2 focus:ring-orange-100"
                />
              ))}
              <button type="button" onClick={() => setShowPin(!showPin)} className="ml-1 self-center text-gray-400 hover:text-gray-600">
                {showPin ? <EyeOff size={16} /> : <Eye size={16} />}
              </button>
            </div>
            <button
              disabled={pin.some((d) => !d) || actionLoading === 'set-pin'}
              onClick={() => doAction('set-pin', { pin: pin.join('') })}
              className="flex w-full items-center justify-center gap-2 rounded-xl bg-orange-500 py-3 text-sm font-semibold text-white shadow-md shadow-orange-200 transition hover:bg-orange-600 disabled:opacity-60"
            >
              {actionLoading === 'set-pin' ? 'Đang kích hoạt...' : <><KeyRound size={15} /> Kích hoạt tủ</>}
            </button>
          </motion.div>
        )}

        {booking.status === 'Active' && (
          <motion.div initial={hidden} animate={visible} transition={trans(0.1)} className="mb-4 space-y-3">
            <div className="rounded-3xl border border-gray-100 bg-white p-6 shadow-sm">
              <h2 className="mb-1 flex items-center gap-2 font-bold text-gray-900"><Eye size={16} className="text-orange-500" /> Xác minh PIN</h2>
              <p className="mb-3 text-xs text-gray-400">Xác minh mã PIN để mở tủ.</p>
              <div className="flex gap-2">
                <input
                  type="password"
                  value={verifyPin}
                  onChange={(e) => setVerifyPin(e.target.value)}
                  placeholder="Nhập mã PIN"
                  maxLength={6}
                  className="flex-1 rounded-xl border border-gray-200 bg-gray-50 py-2.5 px-4 text-sm outline-none transition focus:border-orange-400 focus:ring-2 focus:ring-orange-100"
                />
                <button
                  onClick={() => doAction('verify-pin', { pin: verifyPin })}
                  disabled={verifyPin.length < 6 || actionLoading === 'verify-pin'}
                  className="rounded-xl bg-orange-500 px-4 py-2.5 text-sm font-semibold text-white transition hover:bg-orange-600 disabled:opacity-60"
                >
                  Xác minh
                </button>
              </div>
            </div>

            <button
              onClick={() => doAction('complete')}
              disabled={actionLoading === 'complete'}
              className="flex w-full items-center justify-center gap-2 rounded-2xl bg-blue-500 py-3 text-sm font-semibold text-white shadow-md transition hover:bg-blue-600 disabled:opacity-60"
            >
              {actionLoading === 'complete' ? 'Đang xử lý...' : <><CheckCircle size={15} /> Hoàn tất sử dụng</>}
            </button>
          </motion.div>
        )}

        {(booking.status === 'Pending' || booking.status === 'Active') && (
          <motion.div initial={hidden} animate={visible} transition={trans(0.2)}>
            <button
              onClick={() => doAction('cancel')}
              disabled={actionLoading === 'cancel'}
              className="flex w-full items-center justify-center gap-2 rounded-2xl border border-red-200 bg-white py-3 text-sm font-semibold text-red-500 transition hover:bg-red-50 disabled:opacity-60"
            >
              {actionLoading === 'cancel' ? 'Đang hủy...' : <><XCircle size={15} /> Hủy đặt chỗ</>}
            </button>
          </motion.div>
        )}
      </main>
    </div>
  );
}
