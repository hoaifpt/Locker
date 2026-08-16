import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { CreditCard, ArrowLeft, QrCode, CheckCircle, Clock, Smartphone, Loader2 } from 'lucide-react';
import { Link, useParams, useNavigate } from 'react-router-dom';
import AppHeader from '../../../components/layout/AppHeader';
import { hidden, visible, trans } from '../../../lib/animations';
import { useToast } from '../../../context/ToastContext';

const PAYMENT_METHODS = [
  { id: 'vnpay', name: 'VNPay', icon: '🏦', color: 'border-blue-300 bg-blue-50' },
  { id: 'momo', name: 'MoMo', icon: '💜', color: 'border-pink-300 bg-pink-50' },
  { id: 'zalopay', name: 'ZaloPay', icon: '💙', color: 'border-blue-300 bg-sky-50' },
  { id: 'wallet', name: 'Ví E-Box', icon: '🔶', color: 'border-orange-300 bg-orange-50' },
];

export default function PaymentPage() {
  const { orderId } = useParams();
  const navigate = useNavigate();
  const { show: showToast } = useToast();

  const [order, setOrder] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [selectedMethod, setSelectedMethod] = useState('vnpay');
  const [showQR, setShowQR] = useState(false);
  const [paying, setPaying] = useState(false);
  const [countdown, setCountdown] = useState(900);

  useEffect(() => {
    const fetchOrder = async () => {
      try {
        const token = localStorage.getItem('token');
        const response = await fetch(`https://api.hoaitran.online/api/orders/${orderId}`, {
          headers: { 'Authorization': `Bearer ${token}` }
        });
        if (!response.ok) throw new Error('Không tải được đơn hàng');
        const data = await response.json();
        setOrder(data);
      } catch (err) {
        showToast('Lỗi tải thông tin đơn hàng', 'error');
      } finally {
        setLoading(false);
      }
    };
    fetchOrder();
  }, [orderId, showToast]);

  const handlePayment = async () => {
    setPaying(true);
    const token = localStorage.getItem('token');

    try {
      // 1. Tạo thanh toán
      const payRes = await fetch('https://api.hoaitran.online/api/payments', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json', // Bắt buộc phải có
          'Accept': 'application/json',       // Thêm header này để Backend biết ta muốn nhận JSON
          'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify({
          BookingId: orderId, // Backend mong đợi bookingId
          Method: selectedMethod // Backend mong đợi method
        })
      });

      if (!payRes.ok) {
        const errData = await payRes.json();
        throw new Error(errData.title || 'Không thể tạo yêu cầu thanh toán');
      }

      const paymentData = await payRes.json();

      // 2. Hoàn tất thanh toán
      const completeRes = await fetch(`https://api.hoaitran.online/api/payments/${paymentData.id}/complete`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify({
          transactionId: paymentData.transactionId || "TXN_" + Date.now() // Hoặc ID thực tế từ cổng thanh toán
        })
      });

      if (!completeRes.ok) throw new Error('Thanh toán thất bại');

      showToast('✓ Thanh toán thành công!', 'success');
      navigate('/bookings');
    } catch (err: any) {
      showToast(err.message || 'Thanh toán thất bại', 'error');
    } finally {
      setPaying(false);
    }
  };

  // Logic nhấn nút chính
  const handleMainAction = () => {
    if (selectedMethod === 'wallet') {
      handlePayment(); // Trừ tiền ví trực tiếp
    } else {
      setShowQR(true); // Hiển thị mã QR
    }
  };

  if (loading) return <div className="min-h-screen bg-[#F9F8F6]"><AppHeader /><div className="flex h-96 items-center justify-center"><Loader2 className="animate-spin text-orange-500" size={32} /></div></div>;
  if (!order) return <div className="p-10 text-center">Không tìm thấy đơn hàng.</div>;

  return (
    <div className="min-h-screen bg-[#F9F8F6] font-sans antialiased">
      <AppHeader />
      <main className="mx-auto max-w-lg px-4 py-10 lg:px-8">
        <Link to={`/orders/${orderId}`} className="mb-6 inline-flex items-center gap-1.5 text-sm font-medium text-gray-500 hover:text-orange-500">
          <ArrowLeft size={15} /> Quay lại đơn hàng
        </Link>

        <motion.div initial={hidden} animate={visible} transition={trans(0)} className="mb-6 text-center">
          <h1 className="text-2xl font-extrabold text-gray-900">Thanh toán</h1>
          <p className="mt-1 text-sm text-gray-500">Đơn hàng: {orderId}</p>
        </motion.div>

        <motion.div initial={hidden} animate={visible} transition={trans(0.05)} className="mb-6 rounded-3xl bg-gradient-to-br from-orange-500 to-orange-600 p-6 text-center text-white shadow-lg">
          <p className="text-sm text-orange-100">Tổng cần thanh toán</p>
          <p className="mt-1 text-4xl font-extrabold">{order.totalAmount?.toLocaleString('vi-VN')}đ</p>
        </motion.div>

        {!showQR ? (
          <>
            <div className="mb-6">
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
            </div>

            <button onClick={handleMainAction} disabled={paying} className="flex w-full items-center justify-center gap-2 rounded-xl bg-orange-500 py-3.5 text-sm font-semibold text-white shadow-md transition hover:bg-orange-600">
              {paying ? <Loader2 className="animate-spin" size={16} /> : (selectedMethod === 'wallet' ? 'Xác nhận thanh toán ví' : 'Hiện mã thanh toán')}
            </button>
          </>
        ) : (
          <motion.div initial={hidden} animate={visible} transition={trans(0)} className="space-y-4 text-center">
            <div className="rounded-3xl border bg-white p-6 shadow-sm">
              <p className="text-sm font-semibold text-gray-700">Quét mã QR qua {PAYMENT_METHODS.find(m => m.id === selectedMethod)?.name}</p>
              <div className="mx-auto my-4 flex h-48 w-48 items-center justify-center rounded-2xl border-2 border-dashed border-orange-300 bg-orange-50">
                <QrCode size={80} className="text-orange-400" />
              </div>
            </div>
            <button onClick={handlePayment} disabled={paying} className="flex w-full items-center justify-center gap-2 rounded-xl bg-green-500 py-3.5 text-sm font-semibold text-white transition hover:bg-green-600">
              {paying ? 'Đang xử lý...' : 'Mô phỏng quét mã thành công'}
            </button>
            <button onClick={() => setShowQR(false)} className="w-full py-3 text-sm text-gray-500">← Chọn lại phương thức</button>
          </motion.div>
        )}
      </main>
    </div>
  );
}