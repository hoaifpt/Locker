import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { ArrowLeft, MapPin, ChevronRight, Store, CreditCard, ShieldCheck } from 'lucide-react';
import { Link, useLocation, useNavigate, Navigate } from 'react-router-dom';
import AppHeader from '../../../components/layout/AppHeader';
import { hidden, visible, trans } from '../../../lib/animations';
import { getAvailableLockers, SeedLocker, SeedRestaurant, SeedMenuItem } from '../../../mocks/seed';
import { useToast } from '../../../context/ToastContext';

interface CartItem extends SeedMenuItem {
  quantity: number;
}

export default function CheckoutFoodPage() {
  const location = useLocation();
  const navigate = useNavigate();
  const { show: showToast } = useToast();
  
  const state = location.state as { restaurant: SeedRestaurant, cartItems: CartItem[], totalPrice: number } | null;

  const [lockers, setLockers] = useState<SeedLocker[]>([]);
  const [selectedLocker, setSelectedLocker] = useState('');
  const [selectedSlot, setSelectedSlot] = useState<number | null>(null);
  const [notes, setNotes] = useState('');
  const [submitting, setSubmitting] = useState(false);

  useEffect(() => {
    setLockers(getAvailableLockers());
  }, []);

  if (!state) {
    return <Navigate to="/food" replace />;
  }

  const { restaurant, cartItems, totalPrice } = state;
  const currentLocker = lockers.find(l => l.id === selectedLocker);
  const deliveryFee = 15000;
  const finalTotal = totalPrice + deliveryFee;

  const handleCheckout = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!selectedLocker || selectedSlot === null) {
      showToast('Vui lòng chọn Tủ khóa và Ô tủ nhận hàng', 'error');
      return;
    }

    setSubmitting(true);
    // Simulate API POST /api/food-orders
    await new Promise(r => setTimeout(r, 1500));
    setSubmitting(false);

    showToast('✓ Đặt đồ ăn thành công!', 'success');
    navigate('/food/orders'); // Navigate to history
  };

  return (
    <div className="min-h-screen bg-[#F9F8F6] font-sans antialiased pb-20">
      <AppHeader />
      <main className="mx-auto max-w-3xl px-4 py-10 lg:px-8">
        <button onClick={() => navigate(-1)} className="mb-6 inline-flex items-center gap-1.5 text-sm font-medium text-gray-500 hover:text-orange-500">
          <ArrowLeft size={15} /> Quay lại
        </button>

        <motion.div initial={hidden} animate={visible} transition={trans(0)} className="mb-6">
          <h1 className="text-2xl font-extrabold text-gray-900">Xác nhận đơn hàng</h1>
          <p className="mt-1 text-sm text-gray-500">Kiểm tra lại giỏ hàng và chọn nơi nhận đồ.</p>
        </motion.div>

        <form onSubmit={handleCheckout} className="space-y-6">
          {/* Cart Summary */}
          <motion.div initial={hidden} animate={visible} transition={trans(0.1)} className="rounded-3xl border border-gray-100 bg-white p-6 shadow-sm">
            <div className="flex items-center gap-3 border-b border-gray-100 pb-4 mb-4">
              <div className="h-10 w-10 shrink-0 overflow-hidden rounded-full bg-gray-100">
                <img src={restaurant.imageUrl} alt={restaurant.name} className="h-full w-full object-cover" />
              </div>
              <h2 className="font-bold text-gray-900">{restaurant.name}</h2>
            </div>
            
            <div className="space-y-4">
              {cartItems.map((item) => (
                <div key={item.id} className="flex justify-between items-start text-sm">
                  <div className="flex gap-3">
                    <span className="font-semibold text-gray-900">{item.quantity}x</span>
                    <div>
                      <p className="font-medium text-gray-800">{item.name}</p>
                      {item.notes && <p className="text-xs text-gray-500 mt-0.5">{item.notes}</p>}
                    </div>
                  </div>
                  <span className="font-medium text-gray-900">{(item.price * item.quantity).toLocaleString('vi-VN')}đ</span>
                </div>
              ))}
            </div>
            
            <div className="mt-4 pt-4 border-t border-gray-100 space-y-2 text-sm">
              <div className="flex justify-between text-gray-600">
                <span>Tạm tính</span>
                <span>{totalPrice.toLocaleString('vi-VN')}đ</span>
              </div>
              <div className="flex justify-between text-gray-600">
                <span>Phí giao hàng</span>
                <span>{deliveryFee.toLocaleString('vi-VN')}đ</span>
              </div>
            </div>
          </motion.div>

          {/* Delivery Location */}
          <motion.div initial={hidden} animate={visible} transition={trans(0.2)} className="rounded-3xl border border-gray-100 bg-white p-6 shadow-sm">
            <h2 className="mb-4 flex items-center gap-2 font-bold text-gray-900">
              <MapPin size={18} className="text-orange-500" /> Tủ khóa nhận đồ ăn
            </h2>
            
            <div className="space-y-4 rounded-2xl bg-gray-50 p-4 border border-gray-100">
              <div>
                <label className="mb-1.5 block text-sm font-medium text-gray-700">Chọn Tủ khóa gần bạn</label>
                <select 
                  value={selectedLocker} 
                  onChange={e => { setSelectedLocker(e.target.value); setSelectedSlot(null); }}
                  className="w-full rounded-xl border border-gray-200 bg-white py-3 px-4 text-sm outline-none transition focus:border-orange-400 focus:ring-2 focus:ring-orange-100"
                >
                  <option value="">-- Chọn tủ khóa --</option>
                  {lockers.map(l => (
                    <option key={l.id} value={l.id}>{l.name} — {l.slots.filter(s => s.status === 'Available').length} ô trống</option>
                  ))}
                </select>
              </div>
              
              {currentLocker && (
                <div>
                  <label className="mb-1.5 block text-sm font-medium text-gray-700">Chọn ô tủ nhận hàng</label>
                  <div className="grid grid-cols-4 md:grid-cols-6 gap-2">
                    {currentLocker.slots.map(slot => {
                      const isAvailable = slot.status === 'Available';
                      return (
                        <button 
                          key={slot.index} 
                          type="button" 
                          disabled={!isAvailable} 
                          onClick={() => setSelectedSlot(slot.index)}
                          className={`rounded-xl border py-2 text-xs font-semibold transition ${
                            selectedSlot === slot.index 
                              ? 'border-orange-500 bg-orange-100 text-orange-700 shadow-sm' 
                              : isAvailable 
                                ? 'border-green-200 bg-white text-green-700 hover:border-orange-300' 
                                : 'border-gray-200 bg-gray-100 text-gray-400 opacity-50 cursor-not-allowed'
                          }`}
                        >
                          Ô {slot.index + 1}
                        </button>
                      );
                    })}
                  </div>
                </div>
              )}
            </div>

            <div className="mt-4">
              <label className="mb-1.5 block text-sm font-medium text-gray-700">Ghi chú giao hàng (Tùy chọn)</label>
              <input 
                type="text" 
                value={notes} 
                onChange={e => setNotes(e.target.value)} 
                placeholder="Ví dụ: Lấy nhiều muỗng đũa..."
                className="w-full rounded-xl border border-gray-200 bg-gray-50 py-3 px-4 text-sm outline-none transition focus:border-orange-400 focus:bg-white focus:ring-2 focus:ring-orange-100" 
              />
            </div>
          </motion.div>

          {/* Payment Method */}
          <motion.div initial={hidden} animate={visible} transition={trans(0.3)} className="rounded-3xl border border-gray-100 bg-white p-6 shadow-sm">
            <h2 className="mb-4 flex items-center gap-2 font-bold text-gray-900">
              <CreditCard size={18} className="text-orange-500" /> Phương thức thanh toán
            </h2>
            <div className="flex items-center justify-between rounded-2xl border-2 border-orange-500 bg-orange-50 p-4">
              <div className="flex items-center gap-3">
                <div className="flex h-10 w-10 items-center justify-center rounded-full bg-orange-100 text-orange-600">
                  <ShieldCheck size={20} />
                </div>
                <div>
                  <p className="font-semibold text-orange-900">LuxeLock Pay</p>
                  <p className="text-xs text-orange-700">Số dư: 1,500,000đ</p>
                </div>
              </div>
              <div className="h-4 w-4 rounded-full border-4 border-orange-500 bg-white"></div>
            </div>
          </motion.div>

          <div className="rounded-3xl bg-white p-6 shadow-lg border border-gray-100 sticky bottom-4 z-10">
            <div className="flex items-center justify-between mb-4">
              <span className="font-medium text-gray-500">Tổng thanh toán</span>
              <span className="text-2xl font-extrabold text-orange-500">{finalTotal.toLocaleString('vi-VN')}đ</span>
            </div>
            <button 
              type="submit" 
              disabled={submitting || !selectedLocker || selectedSlot === null}
              className="flex w-full items-center justify-center gap-2 rounded-xl bg-orange-500 py-3.5 text-sm font-bold text-white shadow-[0_8px_20px_rgba(249,115,22,0.3)] transition hover:bg-orange-600 active:scale-95 disabled:opacity-60 disabled:shadow-none"
            >
              {submitting ? 'Đang xử lý...' : <>Đặt hàng ngay <ChevronRight size={18} /></>}
            </button>
          </div>
        </form>
      </main>
    </div>
  );
}
