import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { Truck, ChevronRight, Plus } from 'lucide-react';
import { Link } from 'react-router-dom';
import AppHeader from '../../../components/layout/AppHeader';
import { hidden, visible, trans } from '../../../lib/animations';
import { getDeliveryRequestsByUser, SeedDeliveryRequest, getLockerById } from '../../../mocks/seed';

const STATUS_STYLE: Record<string, { label: string; cls: string }> = {
  Pending: { label: 'Chờ giao', cls: 'bg-yellow-100 text-yellow-700' },
  DeliveredToLocker: { label: 'Đã giao vào tủ', cls: 'bg-green-100 text-green-700' },
  Completed: { label: 'Hoàn thành', cls: 'bg-blue-100 text-blue-700' },
  Cancelled: { label: 'Đã hủy', cls: 'bg-red-100 text-red-500' },
};

export default function DeliveryTasksPage() {
  const userId = localStorage.getItem('userId') ?? 's-001';
  const [tasks, setTasks] = useState<SeedDeliveryRequest[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    setTimeout(() => { setTasks(getDeliveryRequestsByUser(userId)); setLoading(false); }, 300);
  }, [userId]);

  return (
    <div className="min-h-screen bg-[#F9F8F6] font-sans antialiased">
      <AppHeader />
      <main className="mx-auto max-w-4xl px-4 py-10 lg:px-8">
        <motion.div initial={hidden} animate={visible} transition={trans(0)} className="mb-6 flex items-start justify-between">
          <div>
            <span className="inline-flex items-center gap-2 rounded-full border border-blue-200 bg-blue-50 px-4 py-1.5 text-xs font-semibold uppercase tracking-widest text-blue-600"><Truck size={13} /> Giao hàng</span>
            <h1 className="mt-3 text-3xl font-extrabold tracking-tight text-gray-900">Nhiệm vụ <span className="text-orange-500">giao hàng</span></h1>
          </div>
          <Link to="/shipper/delivery/new" className="flex items-center gap-1.5 rounded-xl bg-orange-500 px-4 py-2.5 text-sm font-semibold text-white shadow-md shadow-orange-200 transition hover:bg-orange-600"><Plus size={16} /> Tạo đơn mới</Link>
        </motion.div>

        {loading ? (
          <div className="space-y-4">{[...Array(3)].map((_, i) => <div key={i} className="h-24 animate-pulse rounded-3xl bg-gray-200" />)}</div>
        ) : tasks.length === 0 ? (
          <div className="rounded-3xl border bg-white py-16 text-center"><Truck size={32} className="mx-auto mb-3 text-gray-300" /><p className="text-sm text-gray-400">Không có nhiệm vụ giao hàng nào.</p></div>
        ) : (
          <div className="space-y-3">
            {tasks.map((task, i) => {
              const locker = getLockerById(task.lockerId);
              const st = STATUS_STYLE[task.status];
              return (
                <motion.div key={task.id} initial={hidden} animate={visible} transition={trans(0.1 + i * 0.05)}>
                  <Link to={`/shipper/tasks/${task.id}`} className="group flex items-center gap-4 rounded-2xl border border-gray-100 bg-white p-5 shadow-sm transition hover:border-orange-200 hover:shadow-md">
                    <div className="flex h-11 w-11 shrink-0 items-center justify-center rounded-xl bg-orange-100"><Truck size={18} className="text-orange-500" /></div>
                    <div className="flex-1">
                      <div className="flex items-center gap-2"><span className={`rounded-full px-2.5 py-0.5 text-xs font-semibold ${st?.cls}`}>{st?.label}</span><span className="text-xs text-gray-400">{task.packageSize}</span></div>
                      <p className="mt-1 font-bold text-gray-900">{locker?.name}</p>
                      <p className="text-xs text-gray-500">Mã: {task.trackingCode} · SĐT nhận: {task.receiverPhone}</p>
                    </div>
                    <ChevronRight size={16} className="text-gray-300 group-hover:text-orange-500" />
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
