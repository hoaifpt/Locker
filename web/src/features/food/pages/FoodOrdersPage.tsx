import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { Utensils, ChevronRight, Store } from 'lucide-react';
import { Link } from 'react-router-dom';
import AppHeader from '../../../components/layout/AppHeader';
import { hidden, visible, trans } from '../../../lib/animations';
import { getFoodOrdersByUser, SeedFoodOrder, getRestaurantById, getLockerById } from '../../../mocks/seed';

const STATUS_STYLE: Record<string, { label: string; cls: string }> = {
  PaymentRequired: { label: 'Chờ thanh toán', cls: 'bg-yellow-100 text-yellow-700' },
  Pending: { label: 'Chờ xác nhận', cls: 'bg-blue-100 text-blue-700' },
  Preparing: { label: 'Đang chuẩn bị', cls: 'bg-orange-100 text-orange-700' },
  Delivering: { label: 'Đang giao', cls: 'bg-purple-100 text-purple-700' },
  DeliveredToLocker: { label: 'Đã giao vào tủ', cls: 'bg-green-100 text-green-700' },
  Completed: { label: 'Hoàn thành', cls: 'bg-gray-100 text-gray-700' },
  Cancelled: { label: 'Đã hủy', cls: 'bg-red-100 text-red-500' },
};

export default function FoodOrdersPage() {
  const userId = localStorage.getItem('userId') ?? 'u-001';
  const [orders, setOrders] = useState<SeedFoodOrder[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    setTimeout(() => {
      setOrders(getFoodOrdersByUser(userId));
      setLoading(false);
    }, 300);
  }, [userId]);

  return (
    <div className="min-h-screen bg-[#F9F8F6] font-sans antialiased">
      <AppHeader />
      
      <main className="mx-auto max-w-4xl px-4 py-10 lg:px-8">
        <motion.div initial={hidden} animate={visible} transition={trans(0)} className="mb-6">
          <span className="inline-flex items-center gap-2 rounded-full border border-orange-200 bg-orange-50 px-4 py-1.5 text-xs font-semibold uppercase tracking-widest text-orange-600">
            <Utensils size={13} /> Lịch sử đặt món
          </span>
          <h1 className="mt-3 text-3xl font-extrabold tracking-tight text-gray-900">
            Đơn <span className="text-orange-500">đồ ăn</span> của bạn
          </h1>
        </motion.div>

        {loading ? (
          <div className="space-y-4">
            {[1, 2, 3].map((i) => (
              <div key={i} className="h-32 animate-pulse rounded-3xl bg-gray-200" />
            ))}
          </div>
        ) : orders.length === 0 ? (
          <div className="rounded-3xl border bg-white py-16 text-center">
            <Utensils size={40} className="mx-auto mb-4 text-gray-300" />
            <p className="text-sm text-gray-500">Bạn chưa có đơn đặt đồ ăn nào.</p>
            <Link to="/food" className="mt-4 inline-block rounded-xl bg-orange-500 px-6 py-2.5 text-sm font-semibold text-white shadow-md transition hover:bg-orange-600">
              Đặt món ngay
            </Link>
          </div>
        ) : (
          <div className="space-y-4">
            {orders.map((order, i) => {
              const r = getRestaurantById(order.restaurantId);
              const l = getLockerById(order.lockerId);
              const st = STATUS_STYLE[order.status] ?? { label: order.status, cls: 'bg-gray-100 text-gray-700' };

              return (
                <motion.div key={order.id} initial={hidden} animate={visible} transition={trans(0.1 + i * 0.05)}>
                  <Link 
                    to={`/food/orders/${order.id}`}
                    className="group block rounded-3xl border border-gray-100 bg-white p-5 shadow-sm transition hover:border-orange-200 hover:shadow-md"
                  >
                    <div className="flex items-center justify-between mb-3 border-b border-gray-50 pb-3">
                      <div className="flex items-center gap-2">
                        <Store size={16} className="text-gray-400" />
                        <span className="font-bold text-gray-900">{r?.name}</span>
                      </div>
                      <span className={`rounded-full px-2.5 py-0.5 text-xs font-semibold ${st.cls}`}>
                        {st.label}
                      </span>
                    </div>

                    <div className="flex items-center justify-between">
                      <div className="text-sm text-gray-600">
                        <p className="font-medium text-gray-900 mb-1">
                          {order.items.length} món • {order.totalAmount.toLocaleString('vi-VN')}đ
                        </p>
                        <p className="text-xs text-gray-500">
                          Giao đến: <span className="font-medium">{l?.name} (Ô {order.slotIndex + 1})</span>
                        </p>
                        <p className="text-xs text-gray-400 mt-1">
                          {new Date(order.createdAt).toLocaleString('vi-VN')}
                        </p>
                      </div>
                      <ChevronRight size={18} className="text-gray-300 transition group-hover:text-orange-500" />
                    </div>
                  </Link>
                </motion.div>
              );
            })}
          </div>
        )}
      </main>
    </div>
  );
}
