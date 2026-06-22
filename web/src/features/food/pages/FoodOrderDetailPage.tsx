import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { ArrowLeft, CheckCircle, Package, Truck, Store, Key } from 'lucide-react';
import { Link, useParams } from 'react-router-dom';
import AppHeader from '../../../components/layout/AppHeader';
import { hidden, visible, trans } from '../../../lib/animations';
import { SEED_FOOD_ORDERS, getRestaurantById, getLockerById, SeedFoodOrder } from '../../../mocks/seed';
import { useToast } from '../../../context/ToastContext';
import { FoodOrderStatus } from '../../../types';

const STEPS = [
  { status: 'Pending', label: 'Chờ xác nhận', icon: Store },
  { status: 'Preparing', label: 'Đang chuẩn bị', icon: Package },
  { status: 'Delivering', label: 'Đang giao', icon: Truck },
  { status: 'DeliveredToLocker', label: 'Đã giao vào tủ', icon: Key },
];

export default function FoodOrderDetailPage() {
  const { id } = useParams();
  const { show: showToast } = useToast();
  const [order, setOrder] = useState<SeedFoodOrder | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    setTimeout(() => {
      setOrder(SEED_FOOD_ORDERS.find((o) => o.id === id) ?? null);
      setLoading(false);
    }, 300);
  }, [id]);

  if (loading) return (
    <div className="min-h-screen bg-[#F9F8F6]">
      <AppHeader />
      <div className="flex h-96 items-center justify-center">
        <div className="h-8 w-8 animate-spin rounded-full border-4 border-orange-500 border-t-transparent" />
      </div>
    </div>
  );

  if (!order) return null;

  const restaurant = getRestaurantById(order.restaurantId);
  const locker = getLockerById(order.lockerId);

  const getStepIndex = (status: FoodOrderStatus) => {
    if (status === 'PaymentRequired') return -1;
    if (status === 'Completed') return 4;
    return STEPS.findIndex(s => s.status === status);
  };

  const currentStep = getStepIndex(order.status);
  const isCompleted = order.status === 'Completed';

  // Demo helper to change status manually
  const demoChangeStatus = (newStatus: FoodOrderStatus) => {
    setOrder({ ...order, status: newStatus });
    showToast(`Đã chuyển trạng thái: ${newStatus}`, 'notification');
  };

  return (
    <div className="min-h-screen bg-[#F9F8F6] font-sans antialiased pb-20">
      <AppHeader />
      
      <main className="mx-auto max-w-2xl px-4 py-10 lg:px-8">
        <Link to="/food/orders" className="mb-6 inline-flex items-center gap-1.5 text-sm font-medium text-gray-500 hover:text-orange-500">
          <ArrowLeft size={15} /> Quay lại lịch sử
        </Link>

        {/* Status Header */}
        <motion.div initial={hidden} animate={visible} transition={trans(0)} className="mb-6 rounded-3xl bg-white p-6 shadow-sm border border-gray-100 text-center">
          <h1 className="text-xl font-extrabold text-gray-900 mb-2">Đơn hàng {order.id}</h1>
          <p className="text-sm text-gray-500 font-medium">Từ {restaurant?.name}</p>
        </motion.div>

        {/* Timeline */}
        <motion.div initial={hidden} animate={visible} transition={trans(0.1)} className="mb-6 rounded-3xl bg-white p-6 shadow-sm border border-gray-100">
          <h2 className="mb-6 font-bold text-gray-900">Trạng thái đơn hàng</h2>
          
          <div className="relative border-l-2 border-gray-100 ml-4 space-y-8">
            {STEPS.map((step, index) => {
              const Icon = step.icon;
              const isPast = currentStep > index || isCompleted;
              const isCurrent = currentStep === index && !isCompleted;
              
              let colorCls = 'text-gray-400 bg-gray-100';
              if (isPast) colorCls = 'text-white bg-green-500';
              else if (isCurrent) colorCls = 'text-white bg-orange-500';

              return (
                <div key={step.status} className="relative pl-8">
                  <div className={`absolute -left-4 top-0.5 flex h-8 w-8 items-center justify-center rounded-full shadow-sm border-2 border-white ${colorCls}`}>
                    <Icon size={14} />
                  </div>
                  <div>
                    <h3 className={`font-bold ${isCurrent ? 'text-orange-600' : isPast ? 'text-gray-900' : 'text-gray-400'}`}>
                      {step.label}
                    </h3>
                    {isCurrent && <p className="mt-1 text-xs text-orange-500">Đang thực hiện...</p>}
                    {isPast && <p className="mt-1 text-xs text-gray-500">Hoàn tất lúc {new Date().toLocaleTimeString('vi-VN')}</p>}
                  </div>
                </div>
              );
            })}

            {/* Final Receive Step */}
            <div className="relative pl-8">
              <div className={`absolute -left-4 top-0.5 flex h-8 w-8 items-center justify-center rounded-full shadow-sm border-2 border-white ${isCompleted ? 'bg-green-500 text-white' : 'bg-gray-100 text-gray-400'}`}>
                <CheckCircle size={14} />
              </div>
              <div>
                <h3 className={`font-bold ${isCompleted ? 'text-green-600' : 'text-gray-400'}`}>
                  Nhận đồ tại tủ
                </h3>
                {isCompleted && <p className="mt-1 text-xs text-gray-500">Bạn đã nhận đồ thành công.</p>}
              </div>
            </div>
          </div>
        </motion.div>

        {/* Action Call */}
        {order.status === 'DeliveredToLocker' && (
          <motion.div initial={hidden} animate={visible} transition={trans(0.2)} className="mb-6 rounded-3xl bg-orange-50 p-6 shadow-sm border border-orange-200 text-center">
            <h2 className="text-lg font-bold text-orange-700">Đồ ăn đã đến Tủ khóa!</h2>
            <p className="mt-2 text-sm text-orange-600">Đồ ăn của bạn đã được giao đến <span className="font-bold">{locker?.name}</span> (Ô số {order.slotIndex + 1}).</p>
            <button 
              onClick={() => demoChangeStatus('Completed')}
              className="mt-4 flex w-full items-center justify-center gap-2 rounded-xl bg-orange-500 py-3.5 text-sm font-bold text-white shadow-md shadow-orange-200 transition hover:bg-orange-600"
            >
              Mở tủ nhận đồ ngay
            </button>
          </motion.div>
        )}

        {/* Order Info */}
        <motion.div initial={hidden} animate={visible} transition={trans(0.3)} className="rounded-3xl border border-gray-100 bg-white p-6 shadow-sm">
          <h2 className="mb-4 font-bold text-gray-900">Chi tiết đơn hàng</h2>
          
          <div className="space-y-4">
            {order.items.map((item, idx) => (
              <div key={idx} className="flex justify-between items-start text-sm">
                <div className="flex gap-3">
                  <span className="font-semibold text-gray-900">{item.quantity}x</span>
                  <div>
                    <p className="font-medium text-gray-800">{item.name}</p>
                    {item.notes && <p className="text-xs text-gray-500 mt-0.5">{item.notes}</p>}
                  </div>
                </div>
                <span className="font-medium text-gray-900">{(item.unitPrice * item.quantity).toLocaleString('vi-VN')}đ</span>
              </div>
            ))}
          </div>

          <div className="mt-4 pt-4 border-t border-gray-100 flex justify-between items-center text-sm font-bold text-gray-900">
            <span>Tổng thanh toán</span>
            <span className="text-orange-500 text-lg">{order.totalAmount.toLocaleString('vi-VN')}đ</span>
          </div>
        </motion.div>

        {/* DEMO TOOLBAR */}
        <div className="mt-12 rounded-2xl border border-dashed border-gray-300 p-4 bg-gray-50 opacity-60 hover:opacity-100 transition-opacity">
          <p className="text-xs font-bold text-gray-500 mb-2 uppercase tracking-wider text-center">Công cụ Demo (Đổi trạng thái)</p>
          <div className="flex flex-wrap justify-center gap-2">
            <button onClick={() => demoChangeStatus('Pending')} className="px-3 py-1 bg-white border rounded text-xs">Pending</button>
            <button onClick={() => demoChangeStatus('Preparing')} className="px-3 py-1 bg-white border rounded text-xs">Preparing</button>
            <button onClick={() => demoChangeStatus('Delivering')} className="px-3 py-1 bg-white border rounded text-xs">Delivering</button>
            <button onClick={() => demoChangeStatus('DeliveredToLocker')} className="px-3 py-1 bg-white border rounded text-xs">Delivered To Locker</button>
          </div>
        </div>
      </main>
    </div>
  );
}
