import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { Package, MapPin, Clock, ArrowLeft, ChevronRight, Phone, MessageSquare } from 'lucide-react';
import { Link, useNavigate, useSearchParams } from 'react-router-dom';
import AppHeader from '../../../components/layout/AppHeader';
import { hidden, visible, trans } from '../../../lib/animations';
import { getAvailableLockers, getLockerById, SEED_PACKAGES, SeedLocker, SeedPackage } from '../../../mocks/seed';
import { API_ENDPOINTS } from '../../../constants/api-endpoints';
import { useToast } from '../../../context/ToastContext';


export default function CreateOrderPage() {
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();
  const defaultLockerId = searchParams.get('lockerId') ?? '';
  const { show: showToast } = useToast();

  const [step, setStep] = useState(1);
  const [lockers, setLockers] = useState<SeedLocker[]>([]);
  const [packages, setPackages] = useState<SeedPackage[]>([]);

  // Form State
  const [selectedLocker, setSelectedLocker] = useState(defaultLockerId);
  const [selectedSlot, setSelectedSlot] = useState<number | null>(null);
  const [selectedPackage, setSelectedPackage] = useState('');
  const [durationHours, setDurationHours] = useState(4);
  const [mobile, setMobile] = useState('');
  const [notes, setNotes] = useState('');
  const [submitting, setSubmitting] = useState(false);

  useEffect(() => {
    setLockers(getAvailableLockers());
    setPackages(SEED_PACKAGES.filter(p => p.isActive));
  }, []);

  const currentLocker = lockers.find(l => l.id === selectedLocker) ?? getLockerById(selectedLocker);
  const currentPackage = packages.find(p => p.id === selectedPackage);

  const baseRate = currentPackage?.pricePerHour ?? 0;
  const subtotal = baseRate * durationHours;
  const taxes = subtotal * 0.1;
  const totalAmount = subtotal + taxes;

  const handleNext = () => {
    if (step === 1 && !selectedLocker) { showToast('Vui lòng chọn tủ khóa', 'error'); return; }
    if (step === 2 && selectedSlot === null) { showToast('Vui lòng chọn ô tủ', 'error'); return; }
    if (step === 3 && (!selectedPackage || !mobile)) { showToast('Vui lòng điền đủ thông tin', 'error'); return; }
    setStep(s => s + 1);
  };

  const handleSubmit = async () => {
    setSubmitting(true);

    const token = localStorage.getItem('token');

    try {
      // Kiểm tra dữ liệu tại client trước khi gửi
      if (!selectedLocker || selectedSlot === null || !selectedPackage) {
        throw new Error("Vui lòng kiểm tra lại các trường bắt buộc");
      }

      const payload = {
        lockerId: selectedLocker,
        slotIndex: Number(selectedSlot), // Đảm bảo là Number
        packageId: selectedPackage,
        mobileNumber: mobile,
        checkInTime: new Date().toISOString(),
        durationHours: Number(durationHours), // Đảm bảo là Number
        couponCode: null, // Hoặc "" thay vì null nếu Backend yêu cầu string
        notes: notes || "" // Gửi chuỗi rỗng thay vì null
      };

      console.log("Dữ liệu gửi lên API:", JSON.stringify(payload));

      const response = await fetch('https://api.hoaitran.online/api/orders/reserve', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${localStorage.getItem('token')}` // Đừng quên token!
        },
        body: JSON.stringify(payload),
      });

      // BÍ QUYẾT: Đọc lỗi chi tiết từ Backend
      if (!response.ok) {
        const errorDetails = await response.json();
        console.error("Lỗi từ server:", errorDetails); // Xem chi tiết trong F12 Console
        throw new Error(errorDetails.title || 'Đặt tủ thất bại');
      }

      const result = await response.json();

      showToast('✓ Đã tạo đơn hàng thành công!', 'success');
      navigate(`/payment/${result.orderId || `ord-${Date.now()}`}`);

    } catch (error) {
      console.error(error);
      showToast('Có lỗi xảy ra khi đặt tủ', 'error');
    } finally {
      setSubmitting(false);
    }
  };


  return (
    <div className="min-h-screen bg-[#F9F8F6] font-sans antialiased">
      <AppHeader />
      <main className="mx-auto max-w-2xl px-4 py-10 lg:px-8">
        <button onClick={() => step > 1 ? setStep(s => s - 1) : navigate(-1)} className="mb-6 inline-flex items-center gap-1.5 text-sm font-medium text-gray-500 hover:text-orange-500">
          <ArrowLeft size={15} /> Quay lại
        </button>

        <motion.div initial={hidden} animate={visible} transition={trans(0)} className="mb-6">
          <h1 className="text-2xl font-extrabold text-gray-900">Tạo đơn đặt tủ mới</h1>
          <p className="mt-1 text-sm text-gray-500">Làm theo 4 bước để thuê tủ khóa.</p>
        </motion.div>

        {/* Progress */}
        <div className="mb-8 flex items-center justify-between px-2">
          {['Chọn tủ', 'Chọn ô', 'Dịch vụ', 'Xác nhận'].map((label, i) => (
            <div key={i} className="flex flex-col items-center">
              <div className={`flex h-8 w-8 items-center justify-center rounded-full text-sm font-bold transition ${step > i + 1 ? 'bg-orange-500 text-white' : step === i + 1 ? 'bg-orange-500 text-white ring-4 ring-orange-100' : 'bg-gray-200 text-gray-400'}`}>
                {step > i + 1 ? '✓' : i + 1}
              </div>
              <p className={`mt-2 text-xs font-semibold ${step >= i + 1 ? 'text-gray-900' : 'text-gray-400'}`}>{label}</p>
            </div>
          ))}
        </div>

        <motion.div key={step} initial={{ opacity: 0, x: 20 }} animate={{ opacity: 1, x: 0 }} className="rounded-3xl border border-gray-100 bg-white p-6 shadow-sm">
          {/* STEP 1: Select Locker */}
          {step === 1 && (
            <div className="space-y-4">
              <h2 className="font-bold text-gray-900">Bước 1: Chọn địa điểm tủ khóa</h2>
              <div className="grid gap-3">
                {lockers.map(l => (
                  <button key={l.id} onClick={() => setSelectedLocker(l.id)}
                    className={`flex items-start gap-4 rounded-2xl border-2 p-4 text-left transition ${selectedLocker === l.id ? 'border-orange-500 bg-orange-50' : 'border-gray-100 hover:border-orange-200'}`}>
                    <div className={`flex h-10 w-10 shrink-0 items-center justify-center rounded-xl ${selectedLocker === l.id ? 'bg-orange-500 text-white' : 'bg-orange-100 text-orange-500'}`}><MapPin size={18} /></div>
                    <div>
                      <h3 className="font-bold text-gray-900">{l.name}</h3>
                      <p className="text-xs text-gray-500 mt-1">{l.location}</p>
                      <span className="mt-2 inline-block rounded-full bg-green-100 px-2 py-0.5 text-[10px] font-semibold text-green-700">{l.slots.filter(s => s.status === 'Available').length} ô trống</span>
                    </div>
                  </button>
                ))}
              </div>
              <button onClick={handleNext} disabled={!selectedLocker} className="mt-4 w-full rounded-xl bg-orange-500 py-3 text-sm font-semibold text-white transition hover:bg-orange-600 disabled:opacity-50">Tiếp tục</button>
            </div>
          )}

          {/* STEP 2: Select Slot */}
          {step === 2 && currentLocker && (
            <div className="space-y-4">
              <h2 className="font-bold text-gray-900">Bước 2: Chọn ô tủ tại {currentLocker.name}</h2>
              <div className="grid grid-cols-4 gap-2">
                {currentLocker.slots.map(slot => {
                  const isAvailable = slot.status === 'Available';
                  return (
                    <button key={slot.index} disabled={!isAvailable} onClick={() => setSelectedSlot(slot.index)}
                      className={`flex flex-col items-center rounded-xl border-2 py-3 text-xs font-semibold transition ${selectedSlot === slot.index ? 'border-orange-500 bg-orange-50 text-orange-600' : isAvailable ? 'border-gray-200 hover:border-orange-300' : 'border-gray-100 bg-gray-50 text-gray-300 cursor-not-allowed'}`}>
                      <span>Ô {slot.index + 1}</span>
                      <span className="text-[10px] font-normal opacity-70">Size {slot.size}</span>
                    </button>
                  );
                })}
              </div>
              <button onClick={handleNext} disabled={selectedSlot === null} className="mt-4 w-full rounded-xl bg-orange-500 py-3 text-sm font-semibold text-white transition hover:bg-orange-600 disabled:opacity-50">Tiếp tục</button>
            </div>
          )}

          {/* STEP 3: Details */}
          {step === 3 && (
            <div className="space-y-5">
              <h2 className="font-bold text-gray-900">Bước 3: Gói dịch vụ & Thông tin</h2>

              <div>
                <label className="mb-1.5 block text-sm font-medium text-gray-700">Chọn gói dịch vụ</label>
                <div className="grid gap-2">
                  {packages.map(p => (
                    <button key={p.id} onClick={() => setSelectedPackage(p.id)}
                      className={`flex items-center justify-between rounded-xl border-2 p-3 text-left transition ${selectedPackage === p.id ? 'border-orange-500 bg-orange-50' : 'border-gray-100 hover:border-orange-200'}`}>
                      <div>
                        <p className="font-bold text-gray-900">{p.name}</p>
                        <p className="text-xs text-gray-500">{p.description}</p>
                      </div>
                      <span className="font-bold text-orange-600">{p.pricePerHour.toLocaleString('vi-VN')}đ/h</span>
                    </button>
                  ))}
                </div>
              </div>

              <div>
                <label className="mb-1.5 block text-sm font-medium text-gray-700">Thời gian thuê (Giờ)</label>
                <div className="flex items-center gap-4">
                  <input type="range" min="1" max="72" value={durationHours} onChange={e => setDurationHours(Number(e.target.value))} className="flex-1 accent-orange-500" />
                  <span className="w-16 rounded-lg bg-orange-100 py-1 text-center font-bold text-orange-600">{durationHours}h</span>
                </div>
              </div>

              <div>
                <label className="mb-1.5 block text-sm font-medium text-gray-700">Số điện thoại liên hệ</label>
                <div className="relative">
                  <span className="absolute inset-y-0 left-4 flex items-center text-gray-400"><Phone size={16} /></span>
                  <input type="tel" value={mobile} onChange={e => setMobile(e.target.value)} placeholder="09xx xxx xxx"
                    className="w-full rounded-xl border border-gray-200 bg-gray-50 py-3 pl-11 pr-4 text-sm outline-none focus:border-orange-400 focus:bg-white focus:ring-2 focus:ring-orange-100" />
                </div>
              </div>

              <div>
                <label className="mb-1.5 block text-sm font-medium text-gray-700">Ghi chú thêm</label>
                <div className="relative">
                  <span className="absolute top-3 left-4 flex items-center text-gray-400"><MessageSquare size={16} /></span>
                  <textarea value={notes} onChange={e => setNotes(e.target.value)} placeholder="Mô tả đồ dùng..." rows={2}
                    className="w-full resize-none rounded-xl border border-gray-200 bg-gray-50 py-3 pl-11 pr-4 text-sm outline-none focus:border-orange-400 focus:bg-white focus:ring-2 focus:ring-orange-100" />
                </div>
              </div>

              <button onClick={handleNext} disabled={!selectedPackage || !mobile} className="mt-4 w-full rounded-xl bg-orange-500 py-3 text-sm font-semibold text-white transition hover:bg-orange-600 disabled:opacity-50">Tiếp tục</button>
            </div>
          )}

          {/* STEP 4: Review & Submit */}
          {step === 4 && (
            <div className="space-y-6">
              <h2 className="font-bold text-gray-900 flex items-center gap-2 text-center justify-center mb-6"><Package size={20} className="text-orange-500" /> Xác nhận đơn hàng</h2>

              <div className="rounded-2xl bg-gray-50 p-4 text-sm space-y-3 border border-gray-100">
                <div className="flex justify-between"><span className="text-gray-500">Tủ khóa</span><span className="font-bold text-gray-900 text-right">{currentLocker?.name}</span></div>
                <div className="flex justify-between"><span className="text-gray-500">Vị trí</span><span className="font-semibold text-gray-700 text-right">{currentLocker?.location}</span></div>
                <div className="flex justify-between"><span className="text-gray-500">Ô tủ</span><span className="font-bold text-gray-900">Ô {selectedSlot! + 1}</span></div>
                <div className="flex justify-between"><span className="text-gray-500">Gói dịch vụ</span><span className="font-bold text-gray-900">{currentPackage?.name}</span></div>
                <div className="flex justify-between"><span className="text-gray-500">Thời gian</span><span className="font-bold text-gray-900">{durationHours} giờ</span></div>
                <div className="flex justify-between"><span className="text-gray-500">SĐT</span><span className="font-bold text-gray-900">{mobile}</span></div>
              </div>

              <div className="rounded-2xl border border-orange-200 bg-orange-50 p-4 text-sm space-y-2">
                <div className="flex justify-between"><span className="text-gray-600">Đơn giá</span><span className="font-semibold text-gray-900">{baseRate.toLocaleString('vi-VN')}đ/h</span></div>
                <div className="flex justify-between"><span className="text-gray-600">Tạm tính</span><span className="font-semibold text-gray-900">{subtotal.toLocaleString('vi-VN')}đ</span></div>
                <div className="flex justify-between"><span className="text-gray-600">Thuế (10%)</span><span className="font-semibold text-gray-900">{taxes.toLocaleString('vi-VN')}đ</span></div>
                <div className="border-t border-orange-200 mt-2 pt-2 flex justify-between items-center">
                  <span className="font-bold text-gray-900">Tổng cộng</span>
                  <span className="text-2xl font-extrabold text-orange-600">{totalAmount.toLocaleString('vi-VN')}đ</span>
                </div>
              </div>

              <button onClick={handleSubmit} disabled={submitting} className="flex w-full items-center justify-center gap-2 rounded-xl bg-orange-500 py-3.5 text-sm font-semibold text-white shadow-md shadow-orange-200 transition hover:bg-orange-600 disabled:opacity-60">
                {submitting ? 'Đang tạo đơn...' : <>Xác nhận và Thanh toán <ChevronRight size={16} /></>}
              </button>
            </div>
          )}
        </motion.div>
      </main>
    </div>
  );
}
