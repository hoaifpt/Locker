import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { ArrowLeft, ChevronRight, User } from 'lucide-react';
import { Link, useNavigate } from 'react-router-dom';
import AppHeader from '../../../components/layout/AppHeader';
import { hidden, visible, trans } from '../../../lib/animations';
import { getAvailableLockers, SeedLocker } from '../../../mocks/seed';
import { useToast } from '../../../context/ToastContext';

export default function CreateDeliveryPage() {
  const navigate = useNavigate();
  const { show: showToast } = useToast();
  const [lockers, setLockers] = useState<SeedLocker[]>([]);
  const [senderName, setSenderName] = useState('');
  const [receiverPhone, setReceiverPhone] = useState('');
  const [selectedLocker, setSelectedLocker] = useState('');
  const [selectedSlot, setSelectedSlot] = useState<number | null>(null);
  const [selectedSize, setSelectedSize] = useState('Medium');
  const [submitting, setSubmitting] = useState(false);

  useEffect(() => {
    setLockers(getAvailableLockers());
  }, []);

  const currentLocker = lockers.find(l => l.id === selectedLocker);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!senderName || !receiverPhone || !selectedLocker || selectedSlot === null) {
      showToast('Vui lòng điền đầy đủ thông tin', 'error');
      return;
    }

    setSubmitting(true);
    await new Promise(r => setTimeout(r, 1000));
    setSubmitting(false);

    showToast('✓ Đã tạo yêu cầu giao hàng thành công!', 'success');
    navigate('/shipper/tasks');
  };

  return (
    <div className="min-h-screen bg-[#F9F8F6] font-sans antialiased">
      <AppHeader />
      <main className="mx-auto max-w-2xl px-4 py-10 lg:px-8">
        <Link to="/shipper/tasks" className="mb-6 inline-flex items-center gap-1.5 text-sm font-medium text-gray-500 hover:text-orange-500">
          <ArrowLeft size={15} /> Quay lại
        </Link>

        <motion.div initial={hidden} animate={visible} transition={trans(0)} className="mb-6">
          <h1 className="text-2xl font-extrabold text-gray-900">Tạo yêu cầu giao hàng</h1>
          <p className="mt-1 text-sm text-gray-500">Dành cho Shipper để tạo đơn giao trực tiếp vào tủ khóa.</p>
        </motion.div>

        <motion.form initial={hidden} animate={visible} transition={trans(0.1)} onSubmit={handleSubmit} className="space-y-6 rounded-3xl border border-gray-100 bg-white p-6 shadow-sm">
          {/* Info */}
          <div className="space-y-4">
            <div>
              <label className="mb-1.5 block text-sm font-medium text-gray-700">Tên người gửi (Shop/App)</label>
              <div className="relative">
                <span className="absolute inset-y-0 left-4 flex items-center text-gray-400"><User size={16} /></span>
                <input type="text" value={senderName} onChange={e => setSenderName(e.target.value)} placeholder="VD: Shopee, Lazada..."
                  className="w-full rounded-xl border border-gray-200 bg-gray-50 py-3 pl-11 pr-4 text-sm outline-none transition focus:border-orange-400 focus:bg-white focus:ring-2 focus:ring-orange-100" />
              </div>
            </div>
            <div>
              <label className="mb-1.5 block text-sm font-medium text-gray-700">SĐT người nhận</label>
              <div className="relative">
                <span className="absolute inset-y-0 left-4 flex items-center text-gray-400"><User size={16} /></span>
                <input type="tel" value={receiverPhone} onChange={e => setReceiverPhone(e.target.value)} placeholder="09xx xxx xxx"
                  className="w-full rounded-xl border border-gray-200 bg-gray-50 py-3 pl-11 pr-4 text-sm outline-none transition focus:border-orange-400 focus:bg-white focus:ring-2 focus:ring-orange-100" />
              </div>
            </div>
            <div>
              <label className="mb-1.5 block text-sm font-medium text-gray-700">Kích thước kiện hàng</label>
              <select value={selectedSize} onChange={e => setSelectedSize(e.target.value)}
                className="w-full rounded-xl border border-gray-200 bg-gray-50 py-3 px-4 text-sm outline-none transition focus:border-orange-400 focus:bg-white focus:ring-2 focus:ring-orange-100">
                <option value="Small">Nhỏ (Small)</option>
                <option value="Medium">Vừa (Medium)</option>
                <option value="Large">Lớn (Large)</option>
              </select>
            </div>
          </div>

          {/* Locker & Slot */}
          <div className="space-y-4 rounded-2xl bg-gray-50 p-4">
            <div>
              <label className="mb-1.5 block text-sm font-medium text-gray-700">Tủ khóa nhận hàng</label>
              <select value={selectedLocker} onChange={e => { setSelectedLocker(e.target.value); setSelectedSlot(null); }}
                className="w-full rounded-xl border border-gray-200 bg-white py-3 px-4 text-sm outline-none transition focus:border-orange-400 focus:ring-2 focus:ring-orange-100">
                <option value="">-- Chọn tủ khóa --</option>
                {lockers.map(l => <option key={l.id} value={l.id}>{l.name} — {l.slots.filter(s => s.status === 'Available').length} ô trống</option>)}
              </select>
            </div>
            {currentLocker && (
              <div>
                <label className="mb-1.5 block text-sm font-medium text-gray-700">Chọn ô tủ trống</label>
                <div className="grid grid-cols-4 gap-2">
                  {currentLocker.slots.map(slot => {
                    const isAvailable = slot.status === 'Available';
                    return (
                      <button key={slot.index} type="button" disabled={!isAvailable} onClick={() => setSelectedSlot(slot.index)}
                        className={`rounded-xl border py-2 text-xs font-semibold transition ${selectedSlot === slot.index ? 'border-orange-500 bg-orange-100 text-orange-700' : isAvailable ? 'border-green-200 bg-white text-green-700 hover:border-orange-300' : 'border-gray-200 bg-gray-100 text-gray-400 opacity-50 cursor-not-allowed'}`}>
                        Ô {slot.index + 1}
                      </button>
                    );
                  })}
                </div>
              </div>
            )}
          </div>

          <button type="submit" disabled={submitting || !senderName || !receiverPhone || !selectedLocker || selectedSlot === null}
            className="flex w-full items-center justify-center gap-2 rounded-xl bg-orange-500 py-3.5 text-sm font-semibold text-white shadow-md shadow-orange-200 transition hover:bg-orange-600 disabled:opacity-60">
            {submitting ? 'Đang tạo...' : <>Tạo đơn giao hàng <ChevronRight size={16} /></>}
          </button>
        </motion.form>
      </main>
    </div>
  );
}
