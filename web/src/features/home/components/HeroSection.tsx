import { motion } from 'framer-motion';
import { ChevronRight, Lock, Play } from 'lucide-react';
import { hidden, visible, trans } from '../../../lib/animations';

export default function HeroSection() {
  return (
    <section className="relative overflow-hidden bg-[#F9F8F6] pb-24 pt-36">
      {/* Decorative blobs */}
      <div className="pointer-events-none absolute -top-32 right-0 h-[500px] w-[500px] rounded-full bg-orange-100 opacity-40 blur-3xl" />
      <div className="pointer-events-none absolute bottom-0 left-0 h-80 w-80 rounded-full bg-orange-50 opacity-60 blur-3xl" />

      <div className="relative mx-auto max-w-7xl px-6">
        <div className="grid gap-16 lg:grid-cols-2 lg:items-center">
          {/* Text */}
          <div>
            <motion.span
              initial={hidden}
              animate={visible}
              transition={trans(0)}
              className="inline-flex items-center gap-2 rounded-full border border-orange-200 bg-orange-50 px-4 py-1.5 text-xs font-semibold uppercase tracking-widest text-orange-600"
            >
              Tương lai của lưu trữ
            </motion.span>

            <motion.h1
              initial={hidden}
              animate={visible}
              transition={trans(0.1)}
              className="mt-6 text-5xl font-extrabold leading-tight tracking-tight text-gray-900 lg:text-6xl"
            >
              Hệ thống <span className="text-orange-500">tủ khóa</span> thông minh
            </motion.h1>

            <motion.p
              initial={hidden}
              animate={visible}
              transition={trans(0.2)}
              className="mt-5 max-w-lg text-lg leading-relaxed text-gray-600"
            >
              An toàn, liền mạch và thời thượng. LuxeLock cung cấp hệ sinh thái tủ khóa
              thông minh thế hệ mới — kết nối mọi không gian, bảo vệ mọi tài sản.
            </motion.p>

            {/* CTA Buttons */}
            <motion.div
              initial={hidden}
              animate={visible}
              transition={trans(0.3)}
              className="mt-8 flex flex-wrap gap-3"
            >
              <a
                href="#"
                className="inline-flex items-center gap-2 rounded-xl bg-orange-500 px-6 py-3 text-sm font-semibold text-white shadow-md transition hover:bg-orange-600"
              >
                Bắt đầu ngay <ChevronRight size={16} />
              </a>
              <a
                href="#"
                className="inline-flex items-center gap-2 rounded-xl border border-gray-300 bg-white px-6 py-3 text-sm font-semibold text-gray-700 transition hover:border-orange-400 hover:text-orange-500"
              >
                <span className="flex h-6 w-6 items-center justify-center rounded-full bg-orange-100 text-orange-500">
                  <Play size={10} fill="currentColor" />
                </span>
                Xem Demo
              </a>
            </motion.div>

            {/* Stats */}
            <motion.div
              initial={hidden}
              animate={visible}
              transition={trans(0.4)}
              className="mt-12 grid grid-cols-3 gap-6 border-t border-gray-200 pt-8"
            >
              {[
                { value: '50k+', label: 'Người dùng' },
                { value: '1.200+', label: 'Địa điểm' },
                { value: '99.9%', label: 'Thời gian hoạt động' },
              ].map((stat) => (
                <div key={stat.label}>
                  <p className="text-2xl font-extrabold text-orange-500">{stat.value}</p>
                  <p className="mt-1 text-xs text-gray-500">{stat.label}</p>
                </div>
              ))}
            </motion.div>
          </div>

          {/* Visual mockup */}
          <motion.div
            initial={{ opacity: 0, scale: 0.95 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={trans(0.3)}
            className="relative flex justify-center"
          >
            <div className="relative h-[420px] w-[340px] rounded-3xl bg-gradient-to-br from-orange-500 to-orange-600 p-1 shadow-2xl shadow-orange-200">
              <div className="flex h-full w-full flex-col gap-4 rounded-[22px] bg-white p-6">
                <div className="flex items-center justify-between">
                  <span className="text-xs font-semibold text-gray-400">LUXELOCK</span>
                  <span className="h-2 w-2 rounded-full bg-green-400" />
                </div>
                <div className="flex flex-1 gap-3">
                  {[0, 1, 2].map((i) => (
                    <div
                      key={i}
                      className={`flex flex-1 flex-col items-center justify-center gap-2 rounded-xl border-2 ${
                        i === 1 ? 'border-orange-400 bg-orange-50' : 'border-gray-200 bg-gray-50'
                      }`}
                    >
                      <div
                        className={`flex h-8 w-8 items-center justify-center rounded-full ${
                          i === 1 ? 'bg-orange-500' : 'bg-gray-300'
                        }`}
                      >
                        <Lock size={14} className="text-white" />
                      </div>
                      <span className={`text-[10px] font-bold ${i === 1 ? 'text-orange-600' : 'text-gray-400'}`}>
                        {['A-01', 'B-07', 'C-03'][i]}
                      </span>
                      <span
                        className={`rounded-full px-2 py-0.5 text-[9px] font-semibold ${
                          i === 1 ? 'bg-orange-100 text-orange-500' : 'bg-gray-100 text-gray-400'
                        }`}
                      >
                        {i === 1 ? 'Đang dùng' : 'Trống'}
                      </span>
                    </div>
                  ))}
                </div>
                <div className="rounded-xl bg-gray-50 p-3 text-center">
                  <p className="text-[10px] text-gray-400">Mã truy cập hôm nay</p>
                  <p className="mt-1 text-xl font-extrabold tracking-[0.3em] text-gray-800">• • • • •</p>
                </div>
                <div className="rounded-xl bg-orange-500 py-3 text-center text-sm font-semibold text-white">
                  Mở khóa ngay
                </div>
              </div>
            </div>
            <div className="absolute inset-0 -z-10 scale-90 rounded-3xl bg-orange-400 opacity-20 blur-3xl" />
          </motion.div>
        </div>
      </div>
    </section>
  );
}
