import { useState } from 'react';
import { motion } from 'framer-motion';
import { Search, Package, MapPin, Truck, CheckCircle } from 'lucide-react';
import AppHeader from '../../../components/layout/AppHeader';
import { hidden, visible, trans } from '../../../lib/animations';
import { getDeliveryByTrackingCode, SeedDeliveryRequest, getLockerById } from '../../../mocks/seed';
import { useParams } from 'react-router-dom';

const STEPS = [
  { id: 'Pending', label: 'Chờ giao hàng' },
  { id: 'DeliveredToLocker', label: 'Đã đến tủ khóa' },
  { id: 'Completed', label: 'Người nhận đã lấy' },
];

export default function TrackDeliveryPage() {
  const { trackingCode: initialCode } = useParams();
  const [code, setCode] = useState(initialCode ?? '');
  const [result, setResult] = useState<SeedDeliveryRequest | null>(getDeliveryByTrackingCode(initialCode ?? '') ?? null);
  const [searched, setSearched] = useState(!!initialCode);

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault();
    if (!code) return;
    setResult(getDeliveryByTrackingCode(code) ?? null);
    setSearched(true);
  };

  return (
    <div className="min-h-screen bg-[#F9F8F6] font-sans antialiased">
      <AppHeader />
      <main className="mx-auto max-w-lg px-4 py-16 lg:px-8">
        <motion.div initial={hidden} animate={visible} transition={trans(0)} className="mb-10 text-center">
          <div className="mx-auto mb-4 flex h-16 w-16 items-center justify-center rounded-2xl bg-orange-100">
            <Search size={28} className="text-orange-500" />
          </div>
          <h1 className="text-3xl font-extrabold text-gray-900">Tra cứu đơn hàng</h1>
          <p className="mt-2 text-sm text-gray-500">Nhập mã tracking LXL-xxxx để xem trạng thái.</p>
        </motion.div>

        <motion.form initial={hidden} animate={visible} transition={trans(0.1)} onSubmit={handleSearch} className="mb-8 relative">
          <input type="text" value={code} onChange={e => setCode(e.target.value.toUpperCase())} placeholder="VD: LXL-2026-A1B2C3"
            className="w-full rounded-2xl border border-gray-200 bg-white py-4 pl-5 pr-14 text-sm font-semibold tracking-wide text-gray-900 shadow-sm outline-none transition focus:border-orange-400 focus:ring-4 focus:ring-orange-100" />
          <button type="submit" className="absolute inset-y-2 right-2 flex aspect-square items-center justify-center rounded-xl bg-orange-500 text-white transition hover:bg-orange-600">
            <Search size={18} />
          </button>
        </motion.form>

        {searched && (
          <motion.div initial={hidden} animate={visible} transition={trans(0.2)}>
            {!result ? (
              <div className="rounded-3xl border border-gray-100 bg-white py-10 text-center shadow-sm">
                <Package size={40} className="mx-auto mb-3 text-gray-300" />
                <h2 className="font-bold text-gray-900">Không tìm thấy đơn hàng</h2>
                <p className="mt-1 text-sm text-gray-400">Vui lòng kiểm tra lại mã tracking của bạn.</p>
              </div>
            ) : (
              <div className="rounded-3xl border border-gray-100 bg-white p-6 shadow-sm">
                <div className="mb-6 flex items-start justify-between border-b border-gray-100 pb-6">
                  <div>
                    <p className="text-xs font-semibold uppercase tracking-widest text-orange-500">Mã đơn hàng</p>
                    <h2 className="mt-1 text-xl font-extrabold text-gray-900">{result.trackingCode}</h2>
                  </div>
                  <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-gray-50"><Package size={24} className="text-gray-400" /></div>
                </div>

                <div className="relative pl-6">
                  <div className="absolute left-[11px] top-2 bottom-2 w-0.5 bg-gray-100"></div>
                  <div className="space-y-8">
                    {STEPS.map((step, i) => {
                      const isActive = result.status === step.id || (i === 1 && result.status === 'Completed');
                      const isPast = (i === 0 && (result.status === 'DeliveredToLocker' || result.status === 'Completed')) || (i === 1 && result.status === 'Completed');
                      
                      return (
                        <div key={step.id} className="relative">
                          <div className={`absolute -left-[30px] flex h-6 w-6 items-center justify-center rounded-full border-2 ${isActive || isPast ? 'border-orange-500 bg-orange-500 text-white' : 'border-gray-200 bg-white'}`}>
                            {isActive || isPast ? <CheckCircle size={14} /> : <div className="h-2 w-2 rounded-full bg-gray-200" />}
                          </div>
                          <div>
                            <p className={`font-bold ${isActive || isPast ? 'text-gray-900' : 'text-gray-400'}`}>{step.label}</p>
                            {i === 0 && <p className="text-xs text-gray-500">Người gửi: {result.senderName}</p>}
                            {i === 1 && <p className="text-xs text-gray-500">Tủ khóa: {getLockerById(result.lockerId)?.name}</p>}
                            {i === 1 && result.status === 'DeliveredToLocker' && <p className="mt-1 text-xs font-medium text-orange-500">Đang chờ bạn đến lấy hàng tại ô số {result.slotIndex + 1}.</p>}
                          </div>
                        </div>
                      );
                    })}
                  </div>
                </div>
              </div>
            )}
          </motion.div>
        )}
      </main>
    </div>
  );
}
