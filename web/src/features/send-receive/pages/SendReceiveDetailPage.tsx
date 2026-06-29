import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { Send, ArrowLeft, MapPin, CheckCircle, Package, Lock, KeyRound, Copy, Share2 } from 'lucide-react';
import { Link, useParams } from 'react-router-dom';
import AppHeader from '../../../components/layout/AppHeader';
import { hidden, visible, trans } from '../../../lib/animations';
import { SEED_SEND_RECEIVE_ORDERS, getLockerById, SeedSendReceiveOrder } from '../../../mocks/seed';
import { useToast } from '../../../context/ToastContext';

const STATUS_STYLE: Record<string, { label: string; cls: string }> = {
  Initiated: { label: 'Chờ gửi hàng', cls: 'bg-yellow-100 text-yellow-700' },
  Deposited: { label: 'Chờ người nhận', cls: 'bg-blue-100 text-blue-600' },
  Received: { label: 'Đã nhận thành công', cls: 'bg-green-100 text-green-700' },
  Cancelled: { label: 'Đã hủy', cls: 'bg-red-100 text-red-500' },
};

export default function SendReceiveDetailPage() {
  const { id } = useParams();
  const { show: showToast } = useToast();
  const [order, setOrder] = useState<SeedSendReceiveOrder | null>(null);
  const [loading, setLoading] = useState(true);
  const [actionLoading, setActionLoading] = useState(false);

  useEffect(() => {
    setTimeout(() => { setOrder(SEED_SEND_RECEIVE_ORDERS.find(o => o.id === id) ?? null); setLoading(false); }, 300);
  }, [id]);

  const doAction = async (action: string) => {
    setActionLoading(true);
    await new Promise(r => setTimeout(r, 800));
    
    if (action === 'deposit') {
      setOrder(o => o ? { ...o, status: 'Deposited' } : o);
      showToast('✓ Bạn đã bỏ hàng vào tủ thành công!', 'success');
    }
    if (action === 'receive') {
      setOrder(o => o ? { ...o, status: 'Received' } : o);
      showToast('✓ Người nhận đã lấy hàng!', 'success');
    }
    if (action === 'cancel') {
      setOrder(o => o ? { ...o, status: 'Cancelled' } : o);
      showToast('✓ Đơn gửi hàng đã bị hủy', 'success');
    }
    
    setActionLoading(false);
  };

  if (loading) return <div className="min-h-screen bg-[#F9F8F6]"><AppHeader /><div className="flex h-96 items-center justify-center"><div className="h-8 w-8 animate-spin rounded-full border-4 border-orange-500 border-t-transparent" /></div></div>;
  if (!order) return null;

  const locker = getLockerById(order.lockerId);
  const st = STATUS_STYLE[order.status];
  const isSender = true; // In a real app, determine this by comparing userId

  return (
    <div className="min-h-screen bg-[#F9F8F6] font-sans antialiased">
      <AppHeader />
      <main className="mx-auto max-w-lg px-4 py-10 lg:px-8">
        <Link to="/send-receive" className="mb-6 inline-flex items-center gap-1.5 text-sm font-medium text-gray-500 hover:text-orange-500"><ArrowLeft size={15} /> Quay lại</Link>

        {/* Order Info */}
        <motion.div initial={hidden} animate={visible} transition={trans(0)} className="mb-6 rounded-3xl border border-gray-100 bg-white p-6 shadow-sm">
          <div className="flex items-center justify-between mb-4">
            <div className="flex items-center gap-3">
              <div className="flex h-11 w-11 items-center justify-center rounded-2xl bg-orange-100"><Send size={20} className="text-orange-500" /></div>
              <h1 className="font-bold text-gray-900">Chi tiết gửi hàng</h1>
            </div>
            <span className={`rounded-full px-3 py-1 text-xs font-semibold ${st.cls}`}>{st.label}</span>
          </div>

          <div className="grid grid-cols-2 gap-4 rounded-2xl bg-gray-50 p-4 text-sm">
            <div className="col-span-2"><p className="text-xs text-gray-400">Tủ khóa</p><p className="font-bold text-gray-800">{locker?.name}</p><p className="text-xs text-gray-500">{locker?.location}</p></div>
            <div><p className="text-xs text-gray-400">Ô tủ</p><p className="font-bold text-gray-800">Ô {order.slotIndex + 1}</p></div>
            <div><p className="text-xs text-gray-400">SĐT nhận</p><p className="font-bold text-gray-800">{order.receiverPhone}</p></div>
            {order.notes && <div className="col-span-2"><p className="text-xs text-gray-400">Ghi chú</p><p className="font-bold text-gray-800">{order.notes}</p></div>}
          </div>
        </motion.div>

        {/* PIN Code Share */}
        {(order.status === 'Initiated' || order.status === 'Deposited') && isSender && (
          <motion.div initial={hidden} animate={visible} transition={trans(0.1)} className="mb-6 rounded-3xl border border-green-200 bg-green-50 p-6 text-center">
            <h2 className="mb-3 font-bold text-green-800">Mã PIN dành cho người nhận</h2>
            <div className="mx-auto mb-4 inline-block rounded-xl bg-white px-6 py-3 shadow-sm">
              <p className="text-3xl font-extrabold tracking-[0.3em] text-green-600">{order.pinCode}</p>
            </div>
            <div className="flex justify-center gap-3">
              <button onClick={() => { navigator.clipboard.writeText(order.pinCode); showToast('Đã sao chép mã PIN!', 'success'); }} className="flex items-center gap-1.5 rounded-lg bg-white px-3 py-2 text-xs font-semibold text-gray-700 shadow-sm transition hover:bg-gray-50 border border-gray-200"><Copy size={14} /> Copy PIN</button>
              <button onClick={() => showToast('Đã mở tính năng chia sẻ', 'info')} className="flex items-center gap-1.5 rounded-lg bg-green-600 px-3 py-2 text-xs font-semibold text-white shadow-sm transition hover:bg-green-700"><Share2 size={14} /> Chia sẻ</button>
            </div>
            <p className="mt-3 text-xs text-green-700">Lưu ý: Chỉ chia sẻ mã này cho người nhận hàng.</p>
          </motion.div>
        )}

        {/* Actions based on status */}
        <motion.div initial={hidden} animate={visible} transition={trans(0.2)}>
          {order.status === 'Initiated' && (
            <div className="space-y-3">
              <div className="rounded-2xl border border-orange-200 bg-orange-50 p-4 mb-4">
                <p className="text-sm text-orange-800 font-semibold mb-2 flex items-center gap-2"><MapPin size={16}/> Hướng dẫn gửi hàng:</p>
                <ol className="list-decimal list-inside text-xs text-orange-700 space-y-1">
                  <li>Đến tủ khóa đã chọn.</li>
                  <li>Bấm "Mô phỏng gửi hàng" để mở cửa tủ.</li>
                  <li>Bỏ kiện hàng vào và đóng chặt cửa.</li>
                </ol>
              </div>
              <button onClick={() => doAction('deposit')} disabled={actionLoading} className="w-full flex justify-center items-center gap-2 rounded-xl bg-orange-500 py-3.5 text-sm font-semibold text-white shadow-md transition hover:bg-orange-600 disabled:opacity-60">
                {actionLoading ? 'Đang xử lý...' : <><Package size={16} /> Mô phỏng gửi hàng</>}
              </button>
              <button onClick={() => doAction('cancel')} disabled={actionLoading} className="w-full rounded-xl bg-white border border-red-200 py-3.5 text-sm font-semibold text-red-500 transition hover:bg-red-50 disabled:opacity-60">Hủy đơn gửi hàng</button>
            </div>
          )}

          {order.status === 'Deposited' && (
            <div className="rounded-2xl border border-blue-200 bg-blue-50 p-6 text-center shadow-sm">
              <Package size={48} className="mx-auto mb-3 text-blue-500" />
              <h2 className="font-bold text-blue-800">Hàng đã nằm trong tủ</h2>
              <p className="mt-1 text-sm text-blue-600 mb-6">Đang chờ người nhận (SĐT: {order.receiverPhone}) đến lấy hàng.</p>
              
              <button onClick={() => doAction('receive')} disabled={actionLoading} className="w-full flex justify-center items-center gap-2 rounded-xl bg-blue-600 py-3.5 text-sm font-semibold text-white shadow-md transition hover:bg-blue-700 disabled:opacity-60">
                {actionLoading ? 'Đang xử lý...' : <><KeyRound size={16} /> Mô phỏng người nhận lấy hàng</>}
              </button>
            </div>
          )}

          {order.status === 'Received' && (
            <div className="rounded-3xl border border-green-200 bg-green-50 p-6 text-center">
              <CheckCircle size={48} className="mx-auto mb-3 text-green-500" />
              <h2 className="text-lg font-bold text-green-700">Đã nhận hàng thành công!</h2>
              <p className="mt-1 text-sm text-green-600">Giao dịch gửi-nhận đã hoàn tất.</p>
            </div>
          )}
        </motion.div>
      </main>
    </div>
  );
}
