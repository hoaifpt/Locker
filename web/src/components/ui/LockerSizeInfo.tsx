import { motion } from 'framer-motion';
import { Package, Luggage, Backpack, ShoppingBag } from 'lucide-react';
import { hidden, visible, trans } from '../../lib/animations';

interface LockerSizeInfo {
  size: 'S' | 'M' | 'L' | 'XL';
  dimensions: { height: number; width: number; depth: number };
  suitableItems: string[];
  icon: React.ReactNode;
}

const LOCKER_SIZES: LockerSizeInfo[] = [
  {
    size: 'S',
    dimensions: { height: 40, width: 30, depth: 30 },
    suitableItems: ['Túi xách', 'Laptop', 'Tài liệu', 'Đồ vật nhỏ'],
    icon: <ShoppingBag size={24} className="text-blue-500" />,
  },
  {
    size: 'M',
    dimensions: { height: 60, width: 40, depth: 40 },
    suitableItems: ['Ba lô', 'Vali nhỏ', 'Túi du lịch', 'Thiết bị điện tử'],
    icon: <Backpack size={24} className="text-green-500" />,
  },
  {
    size: 'L',
    dimensions: { height: 80, width: 50, depth: 50 },
    suitableItems: ['Vali cỡ trung', 'Thiết bị thể thao', 'Mũ bảo hiểm', 'Túi khô'],
    icon: <Luggage size={24} className="text-orange-500" />,
  },
  {
    size: 'XL',
    dimensions: { height: 100, width: 60, depth: 60 },
    suitableItems: ['Vali lớn', 'Hàng cồng kềnh', 'Xe đẩy', 'Thiết bị cỡ lớn'],
    icon: <Package size={24} className="text-purple-500" />,
  },
];

const COLOR_MAP: Record<'S' | 'M' | 'L' | 'XL', string> = {
  S: 'border-blue-200 bg-blue-50',
  M: 'border-green-200 bg-green-50',
  L: 'border-orange-200 bg-orange-50',
  XL: 'border-purple-200 bg-purple-50',
};

const BADGE_COLOR_MAP: Record<'S' | 'M' | 'L' | 'XL', string> = {
  S: 'bg-blue-100 text-blue-700',
  M: 'bg-green-100 text-green-700',
  L: 'bg-orange-100 text-orange-700',
  XL: 'bg-purple-100 text-purple-700',
};

export default function LockerSizeInfo() {
  return (
    <section className="my-12">
      {/* Section header */}
      <motion.div initial={hidden} animate={visible} transition={trans(0)} className="mb-8 text-center">
        <h2 className="text-2xl font-extrabold tracking-tight text-gray-900">
          Kích thước tủ khóa <span className="text-orange-500">của chúng tôi</span>
        </h2>
        <p className="mt-2 text-sm text-gray-500">Chọn kích thước phù hợp với nhu cầu của bạn</p>
      </motion.div>

      {/* Size grid */}
      <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-4">
        {LOCKER_SIZES.map((info, i) => (
          <motion.div
            key={info.size}
            initial={hidden}
            animate={visible}
            transition={trans(0.1 + i * 0.05)}
            className={`rounded-2xl border-2 p-6 ${COLOR_MAP[info.size]}`}
          >
            {/* Icon & Size */}
            <div className="flex items-center justify-between mb-4">
              <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-white/50">
                {info.icon}
              </div>
              <span className={`rounded-lg px-2.5 py-1 text-sm font-bold ${BADGE_COLOR_MAP[info.size]}`}>
                Size {info.size}
              </span>
            </div>

            {/* Dimensions */}
            <div className="mb-4">
              <p className="text-xs font-semibold text-gray-600 mb-2">KÍCH THƯỚC</p>
              <div className="space-y-1 text-sm">
                <p className="text-gray-700">
                  <span className="font-semibold">Cao:</span> {info.dimensions.height} cm
                </p>
                <p className="text-gray-700">
                  <span className="font-semibold">Rộng:</span> {info.dimensions.width} cm
                </p>
                <p className="text-gray-700">
                  <span className="font-semibold">Sâu:</span> {info.dimensions.depth} cm
                </p>
              </div>
            </div>

            {/* Suitable items */}
            <div>
              <p className="text-xs font-semibold text-gray-600 mb-2">PHÙ HỢP CHO</p>
              <ul className="space-y-1">
                {info.suitableItems.map((item) => (
                  <li key={item} className="flex items-start gap-2 text-xs text-gray-700">
                    <span className="mt-1 h-1.5 w-1.5 rounded-full bg-current shrink-0" />
                    {item}
                  </li>
                ))}
              </ul>
            </div>
          </motion.div>
        ))}
      </div>
    </section>
  );
}

/**
 * Hook to get locker size info
 */
export function useLockerSizeInfo(size: 'S' | 'M' | 'L' | 'XL') {
  return LOCKER_SIZES.find((info) => info.size === size);
}
