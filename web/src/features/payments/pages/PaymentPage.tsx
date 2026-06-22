import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { CreditCard, ArrowLeft, QrCode, CheckCircle, Clock, Smartphone } from 'lucide-react';
import { Link, useParams, useNavigate } from 'react-router-dom';
import AppHeader from '../../../components/layout/AppHeader';
import { hidden, visible, trans } from '../../../lib/animations';
import { getOrderById, SeedOrder, getLockerById } from '../../../mocks/seed';
import { useToast } from '../../../context/ToastContext';

const PAYMENT_METHODS = [
  { id: 'vnpay', name: 'VNPay', icon: '🏦', color: 'border-blue-300 bg-blue-50' },
  { id: 'momo', name: 'MoMo', icon: '💜', color: 'border-pink-300 bg-pink-50' },
  { id: 'zalopay', name: 'ZaloPay', icon: '💙', color: 'border-blue-300 bg-sky-50' },
  { id: 'wallet', name: 'Ví LuxeLock', icon: '🔶', color: 'border-orange-300 bg-orange-50' },
];

export default function PaymentPage() {
  const { orderId } = useParams();
  const navigate = useNavigate();
  const { show: showToast } = useToast();
  const [order, setOrder] = useState<SeedOrder | null>(null);
  const [loading, setLoading] = useState(true);
  const [selectedMethod, setSelectedMethod] = useState('vnpay');
  const [showQR, setShowQR] = useState(false);
  const [paying, setPaying] = useState(false);
  const [countdown, setCountdown] = useState(900); // 15 minutes

  useEffect(() => {
    setTimeout(() => { setOrder(getOrderById(orderId ?? '') ?? null); setLoading(false); }, 300);
  }, [orderId]);

  useEffect(() => {
    if (!showQR) return;
    const timer = setInterval(() => setCountdown(c => Math.max(0, c - 1)), 1000);
    return () => clearInterval(timer);
  }, [showQR]);

  const handleShowQR = () => setShowQR(true);

  const handleSimulatePayment = async () => {
    setPaying(true);
    await new Promise(r => setTimeout(r, 1500));
    showToast('✓ Thanh toán thành công!', 'success');
    showToast(`💳 ${order?.totalAmount.toLocaleString('vi-VN')}đ qua ${PAYMENT_METHODS.find(m => m.id === selectedMethod)?.name}`, 'info');
    setPaying(false);
    navigate(`/orders/${orderId}`);
  };

  const formatCountdown = (s: number) => `${Math.floor(s / 60).toString().padStart(2, '0')}:${(s % 60).toString().padStart(2, '0')}`;

  if (loading) return <div className="min-h-screen bg-[#F9F8F6]"><AppHeader /><div className="flex h-96 items-center justify-center"><div className="h-8 w-8 animate-spin rounded-full border-4 border-orange-500 border-t-transparent" /></div></div>;
  if (!order) return null;

  const locker = getLockerById(order.lockerId);

  return (
    <div className="min-h-screen bg-[#F9F8F6] font-sans antialiased">
      <AppHeader />
      <main className="mx-auto max-w-lg px-4 py-10 lg:px-8">
        <Link to={`/orders/${orderId}`} className="mb-6 inline-flex items-center gap-1.5 text-sm font-medium text-gray-500 hover:text-orange-500">
          <ArrowLeft size={15} /> Quay lại đơn hàng
        </Link>

        <motion.div initial={hidden} animate={visible} transition={trans(0)} className="mb-6 text-center">
          <div className="mx-auto mb-3 flex h-14 w-14 items-center justify-center rounded-2xl bg-orange-100">
            <CreditCard size={24} className="text-orange-500" />
          </div>
          <h1 className="text-2xl font-extrabold text-gray-900">Thanh toán</h1>
          <p className="mt-1 text-sm text-gray-500">{locker?.name} — Ô {order.slotIndex + 1}</p>
        </motion.div>

        {/* Amount */}
        <motion.div initial={hidden} animate={visible} transition={trans(0.05)} className="mb-6 rounded-3xl bg-gradient-to-br from-orange-500 to-orange-600 p-6 text-center text-white shadow-lg shadow-orange-200/50">
          <p className="text-sm text-orange-100">Tổng cần thanh toán</p>
          <p className="mt-1 text-4xl font-extrabold">{order.totalAmount.toLocaleString('vi-VN')}đ</p>
          <p className="mt-2 text-xs text-orange-200">{order.durationHours} giờ · {new Date(order.checkInTime).toLocaleDateString('vi-VN')}</p>
        </motion.div>

        {!showQR ? (
          <>
            {/* Method selection */}
            <motion.div initial={hidden} animate={visible} transition={trans(0.1)} className="mb-6">
              <h2 className="mb-3 text-sm font-bold text-gray-700">Chọn phương thức thanh toán</h2>
              <div className="space-y-2">
                {PAYMENT_METHODS.map(m => (
                  <button key={m.id} onClick={() => setSelectedMethod(m.id)}
                    className={`flex w-full items-center gap-3 rounded-2xl border-2 p-4 text-left transition ${selectedMethod === m.id ? 'border-orange-500 bg-orange-50 shadow-sm' : 'border-gray-200 bg-white hover:border-orange-300'}`}>
                    <span className="text-2xl">{m.icon}</span>
                    <span className="font-semibold text-gray-900">{m.name}</span>
                    {selectedMethod === m.id && <CheckCircle size={18} className="ml-auto text-orange-500" />}
                  </button>
                ))}
              </div>
            </motion.div>

            <motion.div initial={hidden} animate={visible} transition={trans(0.15)}>
              <button onClick={handleShowQR}
                className="flex w-full items-center justify-center gap-2 rounded-xl bg-orange-500 py-3.5 text-sm font-semibold text-white shadow-md shadow-orange-200 transition hover:bg-orange-600">
                <QrCode size={16} /> Hiện mã thanh toán
              </button>
            </motion.div>
          </>
        ) : (
          <motion.div initial={hidden} animate={visible} transition={trans(0)} className="space-y-4">
            {/* QR Code */}
            <div className="rounded-3xl border border-gray-100 bg-white p-6 text-center shadow-sm">
              <p className="mb-3 text-sm font-semibold text-gray-700">Quét mã QR để thanh toán qua {PAYMENT_METHODS.find(m => m.id === selectedMethod)?.name}</p>
              <div className="mx-auto flex h-48 w-48 items-center justify-center rounded-2xl border-2 border-dashed border-orange-300 bg-orange-50">
                <div className="text-center">
                  <QrCode size={80} className="mx-auto text-orange-400" />
                  <p className="mt-2 text-xs text-gray-400">Mock QR Code</p>
                  <p className="text-[10px] text-gray-300">{order.id}</p>
                </div>
              </div>
              <div className="mt-4 flex items-center justify-center gap-2 text-sm">
                <Clock size={14} className="text-red-500" />
                <span className={`font-bold ${countdown < 60 ? 'text-red-500' : 'text-gray-700'}`}>Hết hạn sau: {formatCountdown(countdown)}</span>
              </div>
            </div>

            {/* Simulate button */}
            <button onClick={handleSimulatePayment} disabled={paying}
              className="flex w-full items-center justify-center gap-2 rounded-xl bg-green-500 py-3.5 text-sm font-semibold text-white shadow-md shadow-green-200 transition hover:bg-green-600 disabled:opacity-60">
              {paying ? (
                <><div className="h-4 w-4 animate-spin rounded-full border-2 border-white border-t-transparent" /> Đang xử lý thanh toán...</>
              ) : (
                <><Smartphone size={16} /> Mô phỏng quét mã thành công</>
              )}
            </button>

            <button onClick={() => setShowQR(false)}
              className="flex w-full items-center justify-center rounded-xl border border-gray-200 bg-white py-3 text-sm font-medium text-gray-600 transition hover:bg-gray-50">
              ← Chọn phương thức khác
            </button>
          </motion.div>
        )}
      </main>
    </div>
  );
}
