import { motion } from 'framer-motion';
import { CheckCircle, ChevronRight, Edit2, X } from 'lucide-react';

export interface BookingConfirmationData {
  bookingId: string;
  selectedSlot: number;
  selectedPackageName: string;
  selectedPackagePrice: number;
  selectedSize: 'S' | 'M' | 'L' | 'XL';
  mobileNumber: string;
  email?: string;
  productNote?: string;
  lockerName: string;
  lockerLocation: string;
}

interface BookingConfirmationModalProps {
  data: BookingConfirmationData;
  onConfirm: () => void;
  onEdit: () => void;
  isSubmitting?: boolean;
}

export default function BookingConfirmationModal({
  data,
  onConfirm,
  onEdit,
  isSubmitting = false,
}: BookingConfirmationModalProps) {
  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 p-4"
    >
      <motion.div
        initial={{ scale: 0.95, opacity: 0 }}
        animate={{ scale: 1, opacity: 1 }}
        exit={{ scale: 0.95, opacity: 0 }}
        className="max-h-[90vh] w-full max-w-2xl overflow-y-auto rounded-3xl bg-white shadow-2xl"
      >
        {/* Header */}
        <div className="sticky top-0 border-b border-gray-100 bg-white px-6 py-4 sm:px-8">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="flex h-10 w-10 items-center justify-center rounded-full bg-green-100">
                <CheckCircle size={22} className="text-green-600" />
              </div>
              <h2 className="text-xl font-bold text-gray-900">Xác nhận đặt chỗ</h2>
            </div>
            <button
              onClick={onEdit}
              className="text-gray-400 hover:text-gray-600"
            >
              <X size={20} />
            </button>
          </div>
        </div>

        {/* Content */}
        <div className="px-6 py-6 sm:px-8">
          {/* Booking ID */}
          {data.bookingId && (
            <div className="mb-6 rounded-2xl bg-green-50 border border-green-200 p-4">
              <p className="text-xs font-semibold text-green-700 uppercase">Mã đặt chỗ</p>
              <p className="mt-1 font-mono text-lg font-bold text-green-900">{data.bookingId}</p>
            </div>
          )}

          {/* Locker Info */}
          <div className="mb-6">
            <h3 className="mb-3 font-bold text-gray-900">Thông tin tủ khóa</h3>
            <div className="rounded-2xl border border-gray-200 bg-gray-50 p-4 space-y-2">
              <div>
                <p className="text-xs text-gray-500">Tủ khóa</p>
                <p className="font-semibold text-gray-900">{data.lockerName}</p>
              </div>
              <div>
                <p className="text-xs text-gray-500">Địa điểm</p>
                <p className="text-sm text-gray-700">{data.lockerLocation}</p>
              </div>
              <div>
                <p className="text-xs text-gray-500">Ô tủ</p>
                <p className="font-semibold text-gray-900">Ô {data.selectedSlot + 1}</p>
              </div>
            </div>
          </div>

          {/* Package Info */}
          <div className="mb-6">
            <h3 className="mb-3 font-bold text-gray-900">Gói dịch vụ</h3>
            <div className="rounded-2xl border border-gray-200 bg-gray-50 p-4 space-y-2">
              <div>
                <p className="text-xs text-gray-500">Gói được chọn</p>
                <p className="font-semibold text-gray-900">{data.selectedPackageName}</p>
              </div>
              <div>
                <p className="text-xs text-gray-500">Kích thước</p>
                <div className="mt-1 inline-block rounded-lg bg-orange-100 px-3 py-1 text-sm font-bold text-orange-700">
                  Size {data.selectedSize}
                </div>
              </div>
              <div>
                <p className="text-xs text-gray-500">Giá</p>
                <p className="text-2xl font-extrabold text-orange-600">
                  {data.selectedPackagePrice.toLocaleString('vi-VN')}đ<span className="text-sm text-gray-500">/giờ</span>
                </p>
              </div>
            </div>
          </div>

          {/* Customer Info */}
          <div className="mb-6">
            <h3 className="mb-3 font-bold text-gray-900">Thông tin khách hàng</h3>
            <div className="rounded-2xl border border-gray-200 bg-gray-50 p-4 space-y-2">
              <div>
                <p className="text-xs text-gray-500">Số điện thoại</p>
                <p className="font-semibold text-gray-900">{data.mobileNumber}</p>
              </div>
              {data.email && (
                <div>
                  <p className="text-xs text-gray-500">Email</p>
                  <p className="text-sm text-gray-700">{data.email}</p>
                </div>
              )}
              {data.productNote && (
                <div>
                  <p className="text-xs text-gray-500">Ghi chú</p>
                  <p className="text-sm text-gray-700">{data.productNote}</p>
                </div>
              )}
            </div>
          </div>

          {/* Terms */}
          <div className="mb-6 rounded-2xl border border-orange-200 bg-orange-50 p-4">
            <p className="text-xs leading-relaxed text-orange-700">
              ✓ Bằng cách xác nhận, bạn đồng ý với{' '}
              <span className="font-semibold">Điều khoản dịch vụ</span> của chúng tôi. Thanh toán sẽ được tính
              dựa trên thời gian sử dụng thực tế.
            </p>
          </div>

          {/* Actions */}
          <div className="flex gap-3">
            <button
              onClick={onEdit}
              disabled={isSubmitting}
              className="flex flex-1 items-center justify-center gap-2 rounded-xl border border-gray-200 bg-white px-4 py-3 font-semibold text-gray-700 transition hover:bg-gray-50 disabled:opacity-60"
            >
              <Edit2 size={16} />
              Chỉnh sửa
            </button>
            <button
              onClick={onConfirm}
              disabled={isSubmitting}
              className="flex flex-1 items-center justify-center gap-2 rounded-xl bg-orange-500 px-4 py-3 font-semibold text-white shadow-lg shadow-orange-200 transition hover:bg-orange-600 disabled:opacity-60"
            >
              {isSubmitting ? 'Đang xử lý...' : <>Xác nhận <ChevronRight size={16} /></>}
            </button>
          </div>
        </div>
      </motion.div>
    </motion.div>
  );
}
