import { Bell } from 'lucide-react';
import { useSettings } from '../../../context/SettingsContext';
import SettingsToggle from '../../../components/ui/SettingsToggle';

export default function NotificationCard() {
  const { settings, updateNotifications } = useSettings();
  const { notifications } = settings;

  return (
    <div className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-700 dark:bg-slate-900">
      <div className="mb-4 flex items-center gap-2">
        <Bell className="size-5 text-orange-500" aria-hidden="true" />
        <h2 className="text-base font-semibold text-slate-900 dark:text-slate-100">Thông báo</h2>
      </div>

      <div className="space-y-1">
        <SettingsToggle
          label="Âm thanh"
          description="Phát âm thanh khi có thông báo mới"
          checked={notifications.sound}
          onChange={(checked) => updateNotifications({ sound: checked })}
        />

        <SettingsToggle
          label="Rung"
          description="Rung khi có thông báo mới"
          checked={notifications.vibration}
          onChange={(checked) => updateNotifications({ vibration: checked })}
        />
      </div>

      <div className="mt-4 border-t border-slate-100 pt-4 dark:border-slate-800">
        <h3 className="mb-2 text-sm font-medium text-slate-500 dark:text-slate-400">Nhận thông báo về</h3>
        <div className="space-y-1">
          <SettingsToggle
            label="Cập nhật đơn hàng"
            description="Trạng thái đơn hàng, thanh toán"
            checked={notifications.orderUpdates}
            onChange={(checked) => updateNotifications({ orderUpdates: checked })}
          />

          <SettingsToggle
            label="Cập nhật giao hàng"
            description="Thông tin vận chuyển, giao thành công"
            checked={notifications.deliveryUpdates}
            onChange={(checked) => updateNotifications({ deliveryUpdates: checked })}
          />

          <SettingsToggle
            label="Khuyến mãi"
            description="Mã giảm giá, ưu đãi đặc biệt"
            checked={notifications.promotions}
            onChange={(checked) => updateNotifications({ promotions: checked })}
          />
        </div>
      </div>
    </div>
  );
}
