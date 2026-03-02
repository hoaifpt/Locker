import { motion } from 'framer-motion';
import { hidden, visible, trans } from '../../../lib/animations';

export default function PortalSection() {
  return (
    <section className="bg-white py-24">
      <div className="mx-auto max-w-7xl px-6">
        <motion.div
          initial={hidden}
          whileInView={visible}
          viewport={{ once: true }}
          transition={trans(0)}
          className="mx-auto max-w-2xl text-center"
        >
          <span className="inline-block rounded-full bg-orange-50 px-4 py-1 text-xs font-semibold uppercase tracking-widest text-orange-500">
            Quản lý
          </span>
          <h2 className="mt-4 text-4xl font-extrabold text-gray-900">Cổng quản lý</h2>
          <p className="mt-4 text-gray-600">
            Kiểm soát hoàn toàn trong tầm tay. Theo dõi trạng thái, phân quyền và phân tích
            dữ liệu từ bảng điều khiển tập trung của LuxeLock.
          </p>
        </motion.div>

        {/* Mock browser window */}
        <motion.div
          initial={hidden}
          whileInView={visible}
          viewport={{ once: true }}
          transition={trans(0.15)}
          className="mx-auto mt-14 max-w-4xl overflow-hidden rounded-2xl shadow-2xl ring-1 ring-gray-200"
        >
          {/* Browser chrome */}
          <div className="flex items-center gap-2 bg-gray-100 px-4 py-3">
            <span className="h-3 w-3 rounded-full bg-red-400" />
            <span className="h-3 w-3 rounded-full bg-yellow-400" />
            <span className="h-3 w-3 rounded-full bg-green-400" />
            <div className="ml-4 flex-1 rounded-md bg-white px-3 py-1 text-xs text-gray-400">
              https://portal.luxelock.io/dashboard
            </div>
          </div>

          {/* Dashboard body */}
          <div className="flex bg-[#F9F8F6]">
            {/* Sidebar */}
            <div className="hidden w-44 shrink-0 flex-col gap-1 border-r border-gray-200 bg-white p-4 md:flex">
              {['Tổng quan', 'Tủ khóa', 'Người dùng', 'Báo cáo', 'Cài đặt'].map((item, i) => (
                <div
                  key={item}
                  className={`rounded-lg px-3 py-2 text-xs font-medium ${
                    i === 0 ? 'bg-orange-500 text-white' : 'text-gray-500 hover:bg-gray-50'
                  }`}
                >
                  {item}
                </div>
              ))}
            </div>

            {/* Main content */}
            <div className="flex-1 p-5">
              {/* Stat cards */}
              <div className="grid grid-cols-2 gap-3 md:grid-cols-4">
                {[
                  { label: 'Tổng tủ', value: '248' },
                  { label: 'Đang sử dụng', value: '183' },
                  { label: 'Trống', value: '65' },
                  { label: 'Cảnh báo', value: '3' },
                ].map((c) => (
                  <div key={c.label} className="rounded-xl bg-white p-3 shadow-sm">
                    <p className="text-[10px] text-gray-400">{c.label}</p>
                    <p className="mt-1 text-xl font-extrabold text-gray-800">{c.value}</p>
                  </div>
                ))}
              </div>

              {/* Bar chart */}
              <div className="mt-4 rounded-xl bg-white p-4 shadow-sm">
                <p className="mb-3 text-xs font-semibold text-gray-600">
                  Lượt sử dụng — 7 ngày gần nhất
                </p>
                <div className="flex h-24 items-end gap-2">
                  {[55, 70, 45, 90, 75, 60, 85].map((h, i) => (
                    <div key={i} className="flex flex-1 flex-col items-center gap-1">
                      <div className="w-full rounded-t-md bg-orange-400" style={{ height: `${h}%` }} />
                      <span className="text-[8px] text-gray-400">
                        {['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'][i]}
                      </span>
                    </div>
                  ))}
                </div>
              </div>

              {/* Activity rows */}
              <div className="mt-4 rounded-xl bg-white p-4 shadow-sm">
                <p className="mb-3 text-xs font-semibold text-gray-600">Hoạt động gần đây</p>
                <div className="space-y-2">
                  {[
                    { id: 'B-07', action: 'Mở khóa', user: 'Nguyễn Văn A', time: '2 phút' },
                    { id: 'A-12', action: 'Khóa lại', user: 'Trần Thị B', time: '8 phút' },
                    { id: 'C-03', action: 'Mở khóa', user: 'Lê Minh C', time: '15 phút' },
                  ].map((row) => (
                    <div
                      key={row.id}
                      className="flex items-center justify-between rounded-lg bg-gray-50 px-3 py-2 text-[10px]"
                    >
                      <span className="font-bold text-orange-500">{row.id}</span>
                      <span className="text-gray-500">{row.action}</span>
                      <span className="text-gray-600">{row.user}</span>
                      <span className="text-gray-400">{row.time} trước</span>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          </div>
        </motion.div>
      </div>
    </section>
  );
}
