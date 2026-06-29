import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { Truck, ArrowLeft, ScanLine, DoorOpen, CheckCircle, Copy } from 'lucide-react';
import { Link, useParams } from 'react-router-dom';
import AppHeader from '../../../components/layout/AppHeader';
import { hidden, visible, trans } from '../../../lib/animations';
import { SEED_DELIVERY_REQUESTS, getLockerById, SeedDeliveryRequest } from '../../../mocks/seed';
import { useToast } from '../../../context/ToastContext';

export default function DeliveryTaskDetailPage() {
  const { id } = useParams();
  const { show: showToast } = useToast();
  const [task, setTask] = useState<SeedDeliveryRequest | null>(null);
  const [loading, setLoading] = useState(true);
  const [step, setStep] = useState(0); // 0=info, 1=scanned, 2=opened, 3=confirmed
  const [actionLoading, setActionLoading] = useState(false);

  useEffect(() => {
    setTimeout(() => { setTask(SEED_DELIVERY_REQUESTS.find(d => d.id === id) ?? null); setLoading(false); }, 300);
  }, [id]);

  const doStep = async (nextStep: number) => {
    setActionLoading(true);
    await new Promise(r => setTimeout(r, 800));
    setStep(nextStep);
    if (nextStep === 1) showToast('✓ Mã kiện hàng đã được quét thành công', 'success');
    if (nextStep === 2) showToast('✓ Tủ khóa đã được mở', 'success');
    if (nextStep === 3) {
      setTask(t => t ? { ...t, status: 'DeliveredToLocker' } : t);
      showToast('✓ Xác nhận giao hàng thành công!', 'success');
    }
    setActionLoading(false);
  };

  if (loading) return <div className="min-h-screen bg-[#F9F8F6]"><AppHeader /><div className="flex h-96 items-center justify-center"><div className="h-8 w-8 animate-spin rounded-full border-4 border-orange-500 border-t-transparent" /></div></div>;
  if (!task) return null;

  const locker = getLockerById(task.lockerId);
  const isDelivered = task.status === 'DeliveredToLocker' || task.status === 'Completed';

  return (
    <div className="min-h-screen bg-[#F9F8F6] font-sans antialiased">
      <AppHeader />
      <main className="mx-auto max-w-lg px-4 py-10 lg:px-8">
        <Link to="/shipper/tasks" className="mb-6 inline-flex items-center gap-1.5 text-sm font-medium text-gray-500 hover:text-orange-500"><ArrowLeft size={15} /> Quay lại</Link>

        {/* Task info */}
        <motion.div initial={hidden} animate={visible} transition={trans(0)} className="mb-6 rounded-3xl border border-gray-100 bg-white p-6 shadow-sm">
          <div className="flex items-center gap-3 mb-4">
            <div className="flex h-11 w-11 items-center justify-center rounded-2xl bg-orange-100"><Truck size={20} className="text-orange-500" /></div>
            <div>
              <h1 className="font-bold text-gray-900">Đơn giao hàng</h1>
              <p className="text-xs text-gray-500">{task.trackingCode}</p>
            </div>
            <span className={`ml-auto rounded-full px-3 py-1 text-xs font-semibold ${isDelivered ? 'bg-green-100 text-green-700' : 'bg-yellow-100 text-yellow-700'}`}>{isDelivered ? 'Đã giao' : 'Chờ giao'}</span>
          </div>
          <div className="grid grid-cols-2 gap-3 rounded-2xl bg-gray-50 p-4 text-sm">
            <div><p className="text-xs text-gray-400">Người gửi</p><p className="font-bold text-gray-800">{task.senderName}</p></div>
            <div><p className="text-xs text-gray-400">SĐT nhận</p><p className="font-bold text-gray-800">{task.receiverPhone}</p></div>
            <div><p className="text-xs text-gray-400">Tủ khóa</p><p className="font-bold text-gray-800">{locker?.name}</p></div>
            <div><p className="text-xs text-gray-400">Ô tủ</p><p className="font-bold text-gray-800">Ô {task.slotIndex + 1}</p></div>
            <div><p className="text-xs text-gray-400">Kích thước</p><p className="font-bold text-gray-800">{task.packageSize}</p></div>
            <div><p className="text-xs text-gray-400">Ngày tạo</p><p className="font-bold text-gray-800">{new Date(task.createdAt).toLocaleDateString('vi-VN')}</p></div>
          </div>
        </motion.div>

        {/* Steps */}
        {!isDelivered && (
          <motion.div initial={hidden} animate={visible} transition={trans(0.1)} className="space-y-4">
            {/* Progress */}
            <div className="flex items-center gap-2 px-2">
              {['Quét mã', 'Mở tủ', 'Xác nhận'].map((label, i) => (
                <div key={i} className="flex flex-1 flex-col items-center">
                  <div className={`flex h-8 w-8 items-center justify-center rounded-full text-sm font-bold ${step > i ? 'bg-green-500 text-white' : step === i ? 'bg-orange-500 text-white' : 'bg-gray-200 text-gray-400'}`}>{step > i ? '✓' : i + 1}</div>
                  <p className={`mt-1 text-xs ${step >= i ? 'text-gray-700 font-medium' : 'text-gray-400'}`}>{label}</p>
                </div>
              ))}
            </div>

            {/* Step 0: Scan */}
            {step === 0 && (
              <div className="rounded-3xl border border-gray-100 bg-white p-6 shadow-sm text-center">
                <ScanLine size={40} className="mx-auto mb-3 text-orange-400" />
                <h2 className="font-bold text-gray-900">Quét mã kiện hàng</h2>
                <p className="mt-1 text-xs text-gray-400">Quét mã barcode trên kiện hàng để xác nhận.</p>
                <button onClick={() => doStep(1)} disabled={actionLoading}
                  className="mt-4 w-full rounded-xl bg-orange-500 py-3 text-sm font-semibold text-white shadow-md shadow-orange-200 transition hover:bg-orange-600 disabled:opacity-60">
                  {actionLoading ? 'Đang quét...' : 'Mô phỏng quét mã'}
                </button>
              </div>
            )}

            {/* Step 1: Open locker */}
            {step === 1 && (
              <div className="rounded-3xl border border-gray-100 bg-white p-6 shadow-sm text-center">
                <DoorOpen size={40} className="mx-auto mb-3 text-blue-500" />
                <h2 className="font-bold text-gray-900">Mở tủ khóa</h2>
                <p className="mt-1 text-xs text-gray-400">Mở ô tủ số {task.slotIndex + 1} tại {locker?.name}.</p>
                <button onClick={() => doStep(2)} disabled={actionLoading}
                  className="mt-4 w-full rounded-xl bg-blue-500 py-3 text-sm font-semibold text-white shadow-md shadow-blue-200 transition hover:bg-blue-600 disabled:opacity-60">
                  {actionLoading ? 'Đang mở...' : 'Mô phỏng mở tủ'}
                </button>
              </div>
            )}

            {/* Step 2: Confirm */}
            {step === 2 && (
              <div className="rounded-3xl border border-gray-100 bg-white p-6 shadow-sm text-center">
                <CheckCircle size={40} className="mx-auto mb-3 text-green-500" />
                <h2 className="font-bold text-gray-900">Xác nhận đã bỏ hàng vào tủ</h2>
                <p className="mt-1 text-xs text-gray-400">Đặt kiện hàng vào ô tủ và đóng cửa.</p>
                <button onClick={() => doStep(3)} disabled={actionLoading}
                  className="mt-4 w-full rounded-xl bg-green-500 py-3 text-sm font-semibold text-white shadow-md shadow-green-200 transition hover:bg-green-600 disabled:opacity-60">
                  {actionLoading ? 'Đang xác nhận...' : 'Xác nhận giao hàng'}
                </button>
              </div>
            )}

            {/* Step 3: Done */}
            {step === 3 && (
              <div className="rounded-3xl border border-green-200 bg-green-50 p-6 text-center">
                <CheckCircle size={48} className="mx-auto mb-3 text-green-500" />
                <h2 className="text-lg font-bold text-green-700">Giao hàng thành công!</h2>
                <p className="mt-1 text-sm text-green-600">Kiện hàng đã được giao vào ô {task.slotIndex + 1}.</p>
                <div className="mt-4 flex items-center justify-center gap-2 rounded-xl bg-white p-3">
                  <p className="text-sm text-gray-500">Mã tracking:</p>
                  <p className="font-bold text-gray-900">{task.trackingCode}</p>
                  <button onClick={() => { navigator.clipboard.writeText(task.trackingCode); showToast('Đã sao chép mã tracking!', 'success'); }}><Copy size={14} className="text-gray-400 hover:text-orange-500" /></button>
                </div>
              </div>
            )}
          </motion.div>
        )}

        {isDelivered && step === 0 && (
          <motion.div initial={hidden} animate={visible} transition={trans(0.1)} className="rounded-3xl border border-green-200 bg-green-50 p-6 text-center">
            <CheckCircle size={48} className="mx-auto mb-3 text-green-500" />
            <h2 className="text-lg font-bold text-green-700">Đã giao thành công</h2>
            <p className="mt-2 text-sm text-green-600">Mã tracking: <strong>{task.trackingCode}</strong></p>
          </motion.div>
        )}
      </main>
    </div>
  );
}
