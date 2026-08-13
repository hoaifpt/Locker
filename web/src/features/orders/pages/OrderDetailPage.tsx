import { useState, useEffect, useRef } from 'react';
import { motion } from 'framer-motion';
import { Package, MapPin, ArrowLeft, KeyRound, CheckCircle, XCircle, Clock, CreditCard, RefreshCw, QrCode, Timer } from 'lucide-react';
import { Link, useParams, useNavigate } from 'react-router-dom';
import AppHeader from '../../../components/layout/AppHeader';
import { hidden, visible, trans } from '../../../lib/animations';
import { apiFetch } from '../../../lib/api';
import { useToast } from '../../../context/ToastContext';

type Order = {
  id: string;
  lockerId: string;
  slotIndex: number;
  packageId: string;
  status: number;
  checkInTime: string;
  checkOutTime: string;
  durationHours: number;
  baseRate: number;
  subtotal: number;
  taxes: number;
  discount: number;
  totalAmount: number;
  mobileNumber: string;
  cancellationReason: string | null;
  notes: string | null;
  startedAt: string | null;
  completedAt: string | null;
  cancelledAt: string | null;
  pin?: string;
};

type Locker = { id: string; name: string; location: string; slots: { index: number; size: string; status: string }[] };
type Pkg = { id: string; name: string; pricePerHour: number };

const STATUS_STYLE: Record<string, { label: string; cls: string }> = {
  Initiated: { label: 'Chờ thanh toán', cls: 'bg-yellow-100 text-yellow-700' },
  Reserved: { label: 'Đã giữ chỗ', cls: 'bg-blue-100 text-blue-600' },
  Paid: { label: 'Đã thanh toán', cls: 'bg-indigo-100 text-indigo-600' },
  Active: { label: 'Đang sử dụng', cls: 'bg-green-100 text-green-700' },
  Completed: { label: 'Hoàn thành', cls: 'bg-emerald-100 text-emerald-700' },
  Cancelled: { label: 'Đã hủy', cls: 'bg-red-100 text-red-500' },
};

const STATUS_ENUM_MAP: Record<number, string> = {
  0: 'Initiated',
  1: 'Reserved',
  2: 'Paid',
  3: 'Active',
  4: 'Completed',
  5: 'Cancelled',
};

const STATUS_STRING_TO_ENUM: Record<string, number> = {
  'Active': 3,
  'Completed': 4,
  'Cancelled': 5,
};

export default function OrderDetailPage() {
  const { id } = useParams();
  const navigate = useNavigate();
  const { show: showToast } = useToast();
  const [order, setOrder] = useState<Order | null>(null);
  const [locker, setLocker] = useState<Locker | null>(null);
  const [pkg, setPackage] = useState<Pkg | null>(null);
  const [loading, setLoading] = useState(true);
  const [actionLoading, setActionLoading] = useState<string | null>(null);
  const [pin, setPin] = useState(['', '', '', '', '', '']);
  const [extendHours, setExtendHours] = useState(1);
  const pinRefs = useRef<(HTMLInputElement | null)[]>([]);

  useEffect(() => {
    if (!id) { setLoading(false); return; }

    const fetchDetails = async () => {
      setLoading(true);
      try {
        const orderRes = await apiFetch(`/orders/${id}`);
        if (!orderRes.ok) {
          if (orderRes.status === 401) { showToast('Phiên đăng nhập đã hết hạn.', 'error'); navigate('/login', { replace: true }); return; }
          throw new Error('Không thể tải thông tin đơn hàng.');
        }
        const orderData = await orderRes.json() as Order;

        const [lockerRes, packageRes] = await Promise.all([
          apiFetch(`/lockers/${orderData.lockerId}`),
          apiFetch(`/packages/${orderData.packageId}`),
        ]);

        if (!lockerRes.ok) throw new Error('Không thể tải thông tin tủ khóa.');
        if (!packageRes.ok) throw new Error('Không thể tải thông tin gói dịch vụ.');

        setOrder(orderData);
        setLocker(await lockerRes.json() as Locker);
        setPackage(await packageRes.json() as Pkg);

      } catch (error) {
        showToast(error instanceof Error ? error.message : 'Lỗi không xác định', 'error');
        navigate('/orders', { replace: true });
      } finally {
        setLoading(false);
      }
    };
    fetchDetails();
  }, [id, navigate, showToast]);

  const handlePinChange = (i: number, val: string) => {
    if (!/^\d*$/.test(val)) return;
    const next = [...pin]; next[i] = val.slice(-1); setPin(next);
    if (val && i < 5) pinRefs.current[i + 1]?.focus();
  };
  const handlePinKeyDown = (i: number, e: React.KeyboardEvent) => {
    if (e.key === 'Backspace' && !pin[i] && i > 0) pinRefs.current[i - 1]?.focus();
  };

  const doAction = async (action: string) => {
    setActionLoading(action);
    await new Promise(r => setTimeout(r, 800));

    if (action === 'pay') {
      navigate(`/payment/${order?.id}`);
      return;
    }
    if (action === 'set-pin') {
      setOrder(o => o ? { ...o, status: STATUS_STRING_TO_ENUM['Active'], pin: pin.join(''), startedAt: new Date().toISOString() } : o);
      showToast('✓ Mã PIN đã được thiết lập. Tủ khóa đã kích hoạt!', 'success');
    }
    if (action === 'activate') {
      setOrder(o => o ? { ...o, status: STATUS_STRING_TO_ENUM['Active'], startedAt: new Date().toISOString() } : o);
      showToast('✓ Đơn hàng đã được kích hoạt!', 'success');
    }
    if (action === 'complete') {
      setOrder(o => o ? { ...o, status: STATUS_STRING_TO_ENUM['Completed'], completedAt: new Date().toISOString() } : o);
      showToast('✓ Đơn hàng hoàn thành!', 'success');
    }
    if (action === 'cancel') {
      setOrder(o => o ? { ...o, status: STATUS_STRING_TO_ENUM['Cancelled'], cancelledAt: new Date().toISOString(), cancellationReason: 'Người dùng hủy' } : o);
      showToast('✓ Đơn hàng đã bị hủy', 'success');
    }
    if (action === 'extend') {
      const addAmount = (pkg?.pricePerHour ?? 0) * extendHours;
      setOrder(o => o ? {
        ...o,
        durationHours: o.durationHours + extendHours,
        checkOutTime: new Date(new Date(o.checkOutTime).getTime() + extendHours * 3600000).toISOString(),
        subtotal: o.subtotal + addAmount,
        totalAmount: o.totalAmount + addAmount + addAmount * 0.1,
      } : o);
      showToast(`✓ Đã gia hạn thêm ${extendHours} giờ!`, 'success');
    }
    setActionLoading(null);
  };

  if (loading) return <div className="min-h-screen bg-[#F9F8F6]"><AppHeader /><div className="flex h-96 items-center justify-center"><div className="h-8 w-8 animate-spin rounded-full border-4 border-orange-500 border-t-transparent" /></div></div>;
  if (!order || !locker || !pkg) return <div className="min-h-screen bg-[#F9F8F6]"><AppHeader /><div className="py-20 text-center text-gray-400">Không tìm thấy đơn hàng</div></div>;

  const statusString = STATUS_ENUM_MAP[order.status] ?? 'Initiated';
  const st = STATUS_STYLE[statusString];

  return (
    <div className="min-h-screen bg-[#F9F8F6] font-sans antialiased">
      <AppHeader />
      <main className="mx-auto max-w-2xl px-4 py-10 lg:px-8">
        <Link to="/orders" className="mb-6 inline-flex items-center gap-1.5 text-sm font-medium text-gray-500 hover:text-orange-500">
          <ArrowLeft size={15} /> Quay lại
        </Link>

        {/* Order info card */}
        <motion.div initial={hidden} animate={visible} transition={trans(0)} className="mb-6 rounded-3xl border border-gray-100 bg-white p-6 shadow-sm">
          <div className="flex items-start justify-between gap-3">
            <div className="flex items-center gap-3">
              <div className="flex h-11 w-11 items-center justify-center rounded-2xl bg-orange-100"><Package size={20} className="text-orange-500" /></div>
              <div>
                <h1 className="font-bold text-gray-900">{locker?.name ?? 'Locker'}</h1>
                <p className="flex items-center gap-1 text-xs text-gray-500"><MapPin size={11} className="text-orange-400" /> {locker?.location}</p>
              </div>
            </div>
            <span className={`rounded-full px-3 py-1 text-xs font-semibold ${st?.cls}`}>{st?.label}</span>
          </div>

          {/* Details grid */}
          <div className="mt-5 grid grid-cols-2 gap-4 rounded-2xl bg-gray-50 p-4 text-sm">
            <div><p className="text-xs text-gray-400">Ô tủ</p><p className="font-bold text-gray-800">Ô {order.slotIndex + 1} ({locker?.slots[order.slotIndex]?.size ?? 'M'})</p></div>
            <div><p className="text-xs text-gray-400">Gói dịch vụ</p><p className="font-bold text-gray-800">{pkg?.name ?? 'N/A'}</p></div>
            <div><p className="text-xs text-gray-400">Check-in</p><p className="font-bold text-gray-800">{new Date(order.checkInTime).toLocaleString('vi-VN')}</p></div>
            <div><p className="text-xs text-gray-400">Check-out</p><p className="font-bold text-gray-800">{new Date(order.checkOutTime).toLocaleString('vi-VN')}</p></div>
            <div><p className="text-xs text-gray-400">Thời lượng</p><p className="font-bold text-gray-800">{order.durationHours} giờ</p></div>
            <div><p className="text-xs text-gray-400">SĐT liên hệ</p><p className="font-bold text-gray-800">{order.mobileNumber}</p></div>
            {order.notes && <div className="col-span-2"><p className="text-xs text-gray-400">Ghi chú</p><p className="font-bold text-gray-800">{order.notes}</p></div>}
          </div>

          {/* Pricing breakdown */}
          <div className="mt-4 space-y-2 rounded-2xl border border-orange-100 bg-orange-50/50 p-4 text-sm">
            <div className="flex justify-between"><span className="text-gray-500">Đơn giá</span><span className="text-gray-700">{order.baseRate.toLocaleString('vi-VN')}đ/giờ</span></div>
            <div className="flex justify-between"><span className="text-gray-500">Tạm tính ({order.durationHours}h)</span><span className="text-gray-700">{order.subtotal.toLocaleString('vi-VN')}đ</span></div>
            <div className="flex justify-between"><span className="text-gray-500">Thuế (10%)</span><span className="text-gray-700">{order.taxes.toLocaleString('vi-VN')}đ</span></div>
            {order.discount > 0 && <div className="flex justify-between"><span className="text-gray-500">Giảm giá</span><span className="text-green-600">-{order.discount.toLocaleString('vi-VN')}đ</span></div>}
            <div className="border-t border-orange-200 pt-2 flex justify-between">
              <span className="font-bold text-gray-900">Tổng cộng</span>
              <span className="text-xl font-extrabold text-orange-500">{order.totalAmount.toLocaleString('vi-VN')}đ</span>
            </div>
          </div>
        </motion.div>

        {/* Step 1: Initiated — Pay */}
        {statusString === 'Initiated' && (
          <motion.div initial={hidden} animate={visible} transition={trans(0.1)} className="mb-4 rounded-3xl border border-gray-100 bg-white p-6 shadow-sm">
            <h2 className="mb-1 flex items-center gap-2 font-bold text-gray-900"><CreditCard size={16} className="text-orange-500" /> Thanh toán đơn hàng</h2>
            <p className="mb-4 text-xs text-gray-400">Vui lòng thanh toán để giữ chỗ tủ khóa.</p>
            <button onClick={() => doAction('pay')} disabled={actionLoading === 'pay'}
              className="flex w-full items-center justify-center gap-2 rounded-xl bg-orange-500 py-3 text-sm font-semibold text-white shadow-md shadow-orange-200 transition hover:bg-orange-600 disabled:opacity-60">
              {actionLoading === 'pay' ? 'Đang chuyển...' : <><CreditCard size={15} /> Thanh toán ngay</>}
            </button>
          </motion.div>
        )}

        {/* Step 2: Paid — Set PIN */}
        {statusString === 'Paid' && (
          <motion.div initial={hidden} animate={visible} transition={trans(0.1)} className="mb-4 rounded-3xl border border-gray-100 bg-white p-6 shadow-sm">
            <h2 className="mb-1 flex items-center gap-2 font-bold text-gray-900"><KeyRound size={16} className="text-orange-500" /> Thiết lập mã PIN</h2>
            <p className="mb-4 text-xs text-gray-400">Nhập mã PIN 6 chữ số để mở khóa tủ.</p>
            <div className="flex justify-center gap-2 mb-4">
              {pin.map((d, i) => (
                <input key={i} ref={el => { pinRefs.current[i] = el; }} type="text" inputMode="numeric" maxLength={1} value={d}
                  onChange={e => handlePinChange(i, e.target.value)} onKeyDown={e => handlePinKeyDown(i, e)}
                  className="h-12 w-12 rounded-xl border border-gray-200 bg-gray-50 text-center text-lg font-bold text-gray-900 outline-none transition focus:border-orange-400 focus:ring-2 focus:ring-orange-100" />
              ))}
            </div>
            <button disabled={pin.some(d => !d) || actionLoading === 'set-pin'} onClick={() => doAction('set-pin')}
              className="flex w-full items-center justify-center gap-2 rounded-xl bg-orange-500 py-3 text-sm font-semibold text-white shadow-md shadow-orange-200 transition hover:bg-orange-600 disabled:opacity-60">
              {actionLoading === 'set-pin' ? 'Đang kích hoạt...' : <><KeyRound size={15} /> Kích hoạt tủ</>}
            </button>
          </motion.div>
        )}

        {/* Step 3: Active — QR/PIN + Complete + Extend */}
        {statusString === 'Active' && (
          <motion.div initial={hidden} animate={visible} transition={trans(0.1)} className="mb-4 space-y-4">
            {/* Unlock QR/PIN */}
            <div className="rounded-3xl border border-green-200 bg-gradient-to-br from-green-50 to-emerald-50 p-6 shadow-sm">
              <h2 className="mb-1 flex items-center gap-2 font-bold text-gray-900"><QrCode size={16} className="text-green-600" /> Mã mở khóa tủ</h2>
              <p className="mb-4 text-xs text-gray-500">Sử dụng mã PIN hoặc QR code dưới đây để mở tủ.</p>
              <div className="flex flex-col items-center gap-3">
                <div className="flex h-32 w-32 items-center justify-center rounded-2xl bg-white shadow-inner border-2 border-dashed border-green-300">
                  <div className="text-center">
                    <QrCode size={48} className="mx-auto text-green-500" />
                    <p className="mt-1 text-[10px] text-gray-400">QR Code</p>
                  </div>
                </div>
                <div className="rounded-xl bg-white px-6 py-3 shadow-sm">
                  <p className="text-xs text-gray-400 text-center">Mã PIN</p>
                  <p className="text-center text-3xl font-extrabold tracking-[0.3em] text-green-600">{order.pin ?? '------'}</p>
                </div>
              </div>
            </div>

            {/* Extend */}
            <div className="rounded-3xl border border-gray-100 bg-white p-6 shadow-sm">
              <h2 className="mb-3 flex items-center gap-2 font-bold text-gray-900"><Timer size={16} className="text-blue-500" /> Gia hạn thời gian</h2>
              <div className="flex items-center gap-3 mb-3">
                <select value={extendHours} onChange={e => setExtendHours(Number(e.target.value))}
                  className="rounded-xl border border-gray-200 bg-gray-50 px-4 py-2.5 text-sm outline-none focus:border-orange-400 focus:ring-2 focus:ring-orange-100">
                  {[1, 2, 3, 4, 6, 12, 24].map(h => <option key={h} value={h}>{h} giờ (+{((pkg?.pricePerHour ?? 0) * h * 1.1).toLocaleString('vi-VN')}đ)</option>)}
                </select>
                <button onClick={() => doAction('extend')} disabled={actionLoading === 'extend'}
                  className="rounded-xl bg-blue-500 px-4 py-2.5 text-sm font-semibold text-white transition hover:bg-blue-600 disabled:opacity-60">
                  {actionLoading === 'extend' ? 'Đang xử lý...' : <><RefreshCw size={14} className="inline mr-1" />Gia hạn</>}
                </button>
              </div>
            </div>

            {/* Complete */}
            <button onClick={() => doAction('complete')} disabled={actionLoading === 'complete'}
              className="flex w-full items-center justify-center gap-2 rounded-2xl bg-emerald-500 py-3 text-sm font-semibold text-white shadow-md transition hover:bg-emerald-600 disabled:opacity-60">
              {actionLoading === 'complete' ? 'Đang xử lý...' : <><CheckCircle size={15} /> Hoàn tất sử dụng</>}
            </button>
          </motion.div>
        )}

        {/* Cancel button */}
        {(statusString === 'Initiated' || statusString === 'Paid' || statusString === 'Active') && (
          <motion.div initial={hidden} animate={visible} transition={trans(0.2)}>
            <button onClick={() => doAction('cancel')} disabled={actionLoading === 'cancel'}
              className="flex w-full items-center justify-center gap-2 rounded-2xl border border-red-200 bg-white py-3 text-sm font-semibold text-red-500 transition hover:bg-red-50 disabled:opacity-60">
              {actionLoading === 'cancel' ? 'Đang hủy...' : <><XCircle size={15} /> Hủy đơn hàng</>}
            </button>
          </motion.div>
        )}

        {/* Cancellation reason */}
        {statusString === 'Cancelled' && order.cancellationReason && (
          <motion.div initial={hidden} animate={visible} transition={trans(0.1)} className="rounded-2xl border border-red-200 bg-red-50 p-4 text-sm text-red-600">
            <p className="font-semibold">Lý do hủy:</p>
            <p>{order.cancellationReason}</p>
          </motion.div>
        )}
      </main>
    </div>
  );
}
