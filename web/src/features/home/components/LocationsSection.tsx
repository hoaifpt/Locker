import { motion } from 'framer-motion';
import { ChevronRight, Globe } from 'lucide-react';
import { hidden, visible, trans } from '../../../lib/animations';
import { LOCATIONS } from '../constants/locations';

export default function LocationsSection() {
  return (
    <section className="bg-[#F9F8F6] py-24">
      <div className="mx-auto max-w-7xl px-6">
        <motion.div
          initial={hidden}
          whileInView={visible}
          viewport={{ once: true }}
          transition={trans(0)}
          className="flex flex-col gap-4 md:flex-row md:items-end md:justify-between"
        >
          <div>
            <span className="inline-block rounded-full bg-orange-50 px-4 py-1 text-xs font-semibold uppercase tracking-widest text-orange-500">
              Địa điểm
            </span>
            <h2 className="mt-3 text-4xl font-extrabold text-gray-900">Được tin dùng toàn cầu</h2>
          </div>
          <a
            href="#"
            className="inline-flex items-center gap-1 text-sm font-semibold text-orange-500 hover:text-orange-600"
          >
            <Globe size={16} />
            Tìm tủ khóa gần bạn
            <ChevronRight size={15} />
          </a>
        </motion.div>

        <div className="mt-12 grid gap-6 md:grid-cols-3">
          {LOCATIONS.map((loc, i) => (
            <motion.div
              key={loc.city}
              initial={hidden}
              whileInView={visible}
              viewport={{ once: true }}
              transition={trans(i * 0.1)}
              className="group relative overflow-hidden rounded-2xl shadow-md"
            >
              <img
                src={loc.img}
                alt={loc.city}
                className="h-64 w-full object-cover transition-transform duration-500 group-hover:scale-105"
              />
              <div className="absolute inset-0 bg-gradient-to-t from-black/70 via-black/20 to-transparent" />
              <div className="absolute bottom-0 left-0 p-5 text-white">
                <p className="text-xl font-extrabold">{loc.city}</p>
                <p className="mt-1 text-sm text-orange-300">{loc.count}</p>
              </div>
              <div className="absolute right-4 top-4 translate-y-2 opacity-0 transition-all duration-300 group-hover:translate-y-0 group-hover:opacity-100">
                <span className="rounded-full bg-orange-500 px-3 py-1 text-xs font-semibold text-white">
                  Khám phá
                </span>
              </div>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
}
