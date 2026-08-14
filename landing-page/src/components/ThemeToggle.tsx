import { Sun, Moon } from 'lucide-react';
import { useTheme } from '../lib/useTheme';

interface ThemeToggleProps {
  className?: string;
}

export default function ThemeToggle({ className = '' }: ThemeToggleProps) {
  const { theme, toggleTheme } = useTheme();
  const isDark = theme === 'dark';

  return (
    <button
      type="button"
      onClick={toggleTheme}
      aria-label={isDark ? 'Chuyển sang chế độ sáng' : 'Chuyển sang chế độ tối'}
      aria-pressed={isDark}
      title={isDark ? 'Chế độ tối' : 'Chế độ sáng'}
      className={`theme-toggle ${className}`}
    >
      <span className="theme-toggle-track">
        <span
          className={`theme-toggle-thumb ${isDark ? 'is-dark' : 'is-light'}`}
          aria-hidden="true"
        >
          <Sun
            className="theme-toggle-icon theme-toggle-icon-sun"
            size={14}
            strokeWidth={2.4}
          />
          <Moon
            className="theme-toggle-icon theme-toggle-icon-moon"
            size={14}
            strokeWidth={2.4}
          />
        </span>
      </span>
    </button>
  );
}