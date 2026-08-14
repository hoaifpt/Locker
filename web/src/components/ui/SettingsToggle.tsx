import { forwardRef } from 'react';

interface SettingsToggleProps extends Omit<React.InputHTMLAttributes<HTMLInputElement>, 'type' | 'onChange'> {
  label: string;
  description?: string;
  onChange?: (checked: boolean) => void;
}

const SettingsToggle = forwardRef<HTMLInputElement, SettingsToggleProps>(
  ({ label, description, onChange, checked, disabled, className = '', ...rest }, ref) => {
    return (
      <label
        className={`group flex cursor-pointer items-center justify-between gap-4 py-3 ${
          disabled ? 'cursor-not-allowed opacity-50' : ''
        } ${className}`}
      >
        <div className="flex flex-col">
          <span className="text-sm font-medium text-slate-700 dark:text-slate-200">{label}</span>
          {description && (
            <span className="mt-0.5 text-xs text-slate-500 dark:text-slate-400">{description}</span>
          )}
        </div>
        <div className="relative">
          <input
            ref={ref}
            type="checkbox"
            role="switch"
            checked={checked}
            disabled={disabled}
            onChange={(e) => onChange?.(e.target.checked)}
            className="peer sr-only"
            {...rest}
          />
          <div
            className={`h-6 w-11 rounded-full transition-colors ${
              checked
                ? 'bg-orange-500 peer-focus-visible:ring-orange-500 peer-focus-visible:ring-offset-2 dark:bg-orange-500'
                : 'bg-slate-200 peer-focus-visible:ring-slate-500 peer-focus-visible:ring-offset-2 dark:bg-slate-700'
            } peer-focus-visible:ring-2 peer-focus-visible:ring-offset-2`}
          />
          <div
            className={`absolute left-0.5 top-0.5 h-5 w-5 rounded-full bg-white shadow-sm transition-transform ${
              checked ? 'translate-x-5' : 'translate-x-0'
            }`}
          />
        </div>
      </label>
    );
  },
);

SettingsToggle.displayName = 'SettingsToggle';

export default SettingsToggle;
