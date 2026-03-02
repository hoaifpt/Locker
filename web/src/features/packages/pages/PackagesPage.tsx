import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { Package, Clock, ChevronRight, Check } from 'lucide-react';
import { Link } from 'react-router-dom';
import AppHeader from '../../../components/layout/AppHeader';
import { hidden, visible, trans } from '../../../lib/animations';
import { SEED_PACKAGES, SeedPackage as PackageDto } from '../../../mocks/seed';

const SIZE_COLOR: Record<string, string> = {
  S: 'bg-blue-100 text-blue-600',
  M: 'bg-green-100 text-green-600',
  L: 'bg-orange-100 text-orange-600',
  XL: 'bg-purple-100 text-purple-600',
};

const PERKS = [
  'Khóa cửa điện tử thông minh',
  'Truy cập bằng mã PIN',
  'Bảo vệ 24/7',
  'Thông báo tức thì',
];

export default function PackagesPage() {
  const [packages, setPackages] = useState<PackageDto[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Seed data — swap for GET /api/packages when backend is ready
    setTimeout(() => { setPackages(SEED_PACKAGES.filter((p) => p.isActive)); setLoading(false); }, 300);
  }, []);

  return (
    <div className="min-h-screen bg-[#F9F8F6] font-sans antialiased">
      <AppHeader />

      <main className="mx-auto max-w-7xl px-4 py-10 lg:px-8">
        {/* Page header */}
        <motion.div initial={hidden} animate={visible} transition={trans(0)} className="mb-10 text-center">
          <span className="inline-flex items-center gap-2 rounded-full border border-orange-200 bg-orange-50 px-4 py-1.5 text-xs font-semibold uppercase tracking-widest text-orange-600">
            Bảng giá
          </span>
          <h1 className="mt-3 text-3xl font-extrabold tracking-tight text-gray-900">
            Chọn gói phù hợp với <span className="text-orange-500">bạn</span>
          </h1>
          <p className="mt-2 text-sm text-gray-500">Thanh toán theo giờ sử dụng thực tế. Không phí ẩn.</p>
        </motion.div>

        {/* Perks */}
        <motion.div
          initial={hidden}
          animate={visible}
          transition={trans(0.1)}
          className="mb-10 flex flex-wrap justify-center gap-4"
        >
          {PERKS.map((perk) => (
            <span key={perk} className="flex items-center gap-2 rounded-full border border-gray-200 bg-white px-4 py-2 text-xs font-medium text-gray-600 shadow-sm">
              <Check size={12} className="text-orange-500" /> {perk}
            </span>
          ))}
        </motion.div>

        {/* Package cards */}
        {loading ? (
          <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-4">
            {[...Array(4)].map((_, i) => (
              <div key={i} className="h-72 animate-pulse rounded-3xl bg-gray-200" />
            ))}
          </div>
        ) : (
          <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-4">
            {packages.map((pkg, i) => (
              <motion.div
                key={pkg.id}
                initial={hidden}
                animate={visible}
                transition={trans(0.1 + i * 0.07)}
                className={`relative flex flex-col rounded-3xl border p-6 shadow-sm transition hover:shadow-md ${
                  pkg.size === 'M'
                    ? 'border-orange-300 bg-gradient-to-b from-orange-500 to-orange-600 text-white shadow-orange-200'
                    : 'border-gray-100 bg-white shadow-orange-50'
                }`}
              >
                {pkg.size === 'M' && (
                  <span className="absolute -top-3 left-1/2 -translate-x-1/2 rounded-full bg-white px-4 py-1 text-xs font-bold text-orange-500 shadow">
                    Phổ biến nhất
                  </span>
                )}

                <div className={`flex h-12 w-12 items-center justify-center rounded-2xl ${pkg.size === 'M' ? 'bg-white/20' : 'bg-orange-100'}`}>
                  <Package size={22} className={pkg.size === 'M' ? 'text-white' : 'text-orange-500'} />
                </div>

                <div className="mt-4">
                  <span className={`rounded-full px-2.5 py-0.5 text-xs font-bold ${pkg.size === 'M' ? 'bg-white/20 text-white' : SIZE_COLOR[pkg.size]}`}>
                    Size {pkg.size}
                  </span>
                  <h3 className={`mt-2 text-xl font-extrabold ${pkg.size === 'M' ? 'text-white' : 'text-gray-900'}`}>
                    {pkg.name}
                  </h3>
                  <p className={`mt-1.5 text-sm ${pkg.size === 'M' ? 'text-white/80' : 'text-gray-500'}`}>
                    {pkg.description}
                  </p>
                </div>

                <div className="mt-6 flex-1">
                  <div className="flex items-end gap-1">
                    <span className={`text-3xl font-extrabold ${pkg.size === 'M' ? 'text-white' : 'text-gray-900'}`}>
                      {pkg.pricePerHour.toLocaleString('vi-VN')}đ
                    </span>
                    <span className={`mb-1 text-sm ${pkg.size === 'M' ? 'text-white/70' : 'text-gray-400'}`}>/giờ</span>
                  </div>
                  <div className={`mt-1 flex items-center gap-1 text-xs ${pkg.size === 'M' ? 'text-white/70' : 'text-gray-400'}`}>
                    <Clock size={11} /> Tính theo giờ thực tế
                  </div>
                </div>

                <Link
                  to="/lockers"
                  className={`mt-6 flex items-center justify-center gap-1.5 rounded-xl py-3 text-sm font-semibold transition ${
                    pkg.size === 'M'
                      ? 'bg-white text-orange-500 hover:bg-orange-50'
                      : 'bg-orange-500 text-white hover:bg-orange-600'
                  }`}
                >
                  Đặt ngay <ChevronRight size={14} />
                </Link>
              </motion.div>
            ))}
          </div>
        )}

        {/* Note */}
        <motion.p
          initial={hidden}
          animate={visible}
          transition={trans(0.5)}
          className="mt-10 text-center text-xs text-gray-400"
        >
          Giá tính theo giờ sử dụng thực tế. Thanh toán khi kết thúc phiên.
        </motion.p>
      </main>
    </div>
  );
}
