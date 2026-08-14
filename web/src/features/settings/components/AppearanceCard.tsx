import { Eye, Monitor } from 'lucide-react';
import { useSettings } from '../../../context/SettingsContext';
import { useTheme } from '../../../context/ThemeContext';
import SettingsToggle from '../../../components/ui/SettingsToggle';

export default function AppearanceCard() {
  const { theme, toggleTheme } = useTheme();
  const { settings, setFontSize } = useSettings();

  return (
    <div className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-700 dark:bg-slate-900">
      <div className="mb-4 flex items-center gap-2">
        <Monitor className="size-5 text-orange-500" aria-hidden="true" />
        <h2 className="text-base font-semibold text-slate-900 dark:text-slate-100">Giao diện</h2>
      </div>

      <div className="divide-y divide-slate-100 dark:divide-slate-800">
        <SettingsToggle
          label="Chế độ tối"
          description="Giảm mỏi mắt khi sử dụng trong điều kiện thiếu sáng"
          checked={theme === 'dark'}
          onChange={toggleTheme}
        />

        <div className="py-3">
          <div className="mb-3 flex items-center gap-2">
            <Eye className="size-4 text-slate-500 dark:text-slate-400" aria-hidden="true" />
            <span className="text-sm font-medium text-slate-700 dark:text-slate-200">Chế độ đọc dễ</span>
          </div>
          <div className="flex rounded-xl border border-slate-200 bg-slate-50 p-1 dark:border-slate-700 dark:bg-slate-800">
            <button
              type="button"
              onClick={() => setFontSize('normal')}
              className={`flex-1 rounded-lg px-4 py-2 text-sm font-medium transition-colors ${
                settings.fontSize === 'normal'
                  ? 'bg-white text-slate-900 shadow-sm dark:bg-slate-700 dark:text-slate-100'
                  : 'text-slate-500 hover:text-slate-700 dark:text-slate-400 dark:hover:text-slate-200'
              }`}
            >
              Mặc định
            </button>
            <button
              type="button"
              onClick={() => setFontSize('easy-read')}
              className={`flex-1 rounded-lg px-4 py-2 text-base font-medium transition-colors ${
                settings.fontSize === 'easy-read'
                  ? 'bg-white text-slate-900 shadow-sm dark:bg-slate-700 dark:text-slate-100'
                  : 'text-slate-500 hover:text-slate-700 dark:text-slate-400 dark:hover:text-slate-200'
              }`}
            >
              Đọc dễ
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
