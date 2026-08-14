import { TriangleAlert, Info, X, type LucideIcon } from 'lucide-react';

interface InlineAlertProps {
  variant: 'warning' | 'info';
  title: string;
  description?: string;
  action?: { label: string; onClick: () => void };
  onDismiss?: () => void;
  className?: string;
}

const VARIANT_STYLES: Record<InlineAlertProps['variant'], {
  container: string;
  iconColor: string;
  accent: string;
  Icon: LucideIcon;
  actionClass: string;
}> = {
  warning: {
    container:
      'border-amber-300 bg-amber-50/90 shadow-sm dark:border-amber-500/40 dark:bg-amber-500/15',
    iconColor: 'text-amber-500',
    accent: 'border-l-amber-500',
    Icon: TriangleAlert,
    actionClass:
      'text-amber-700 hover:bg-amber-100 dark:text-amber-400 dark:hover:bg-amber-500/20',
  },
  info: {
    container:
      'border-blue-300 bg-blue-50/90 shadow-sm dark:border-blue-500/40 dark:bg-blue-500/15',
    iconColor: 'text-blue-500',
    accent: 'border-l-blue-500',
    Icon: Info,
    actionClass:
      'text-blue-700 hover:bg-blue-100 dark:text-blue-400 dark:hover:bg-blue-500/20',
  },
};

export function InlineAlert({ variant, title, description, action, onDismiss, className }: InlineAlertProps) {
  const styles = VARIANT_STYLES[variant];
  const Icon = styles.Icon;

  return (
    <div
      role="alert"
      className={[
        'flex flex-col gap-2 rounded-xl border border-l-4 px-5 py-4',
        styles.container,
        styles.accent,
        className ?? '',
      ].join(' ')}
    >
      <div className="flex items-start gap-3">
        <Icon size={20} className={`mt-0.5 shrink-0 ${styles.iconColor}`} aria-hidden="true" />
        <div className="flex-1">
          <p className="text-sm font-semibold text-slate-900 dark:text-slate-100">{title}</p>
          {description && (
            <p className="mt-1 text-sm leading-relaxed text-slate-600 dark:text-slate-400">
              {description}
            </p>
          )}
        </div>
        {onDismiss && (
          <button
            type="button"
            onClick={onDismiss}
            aria-label="Đóng"
            className="-mr-1 inline-flex h-8 w-8 shrink-0 items-center justify-center rounded-md text-slate-400 transition hover:bg-slate-100 hover:text-slate-700 dark:text-slate-500 dark:hover:bg-slate-800 dark:hover:text-slate-200"
          >
            <X size={16} aria-hidden="true" />
          </button>
        )}
      </div>
      {action && (
        <button
          type="button"
          onClick={action.onClick}
          className={`inline-flex w-fit items-center gap-1.5 self-start rounded-lg px-3 py-1.5 text-sm font-semibold transition ${styles.actionClass}`}
        >
          {action.label}
          <span aria-hidden="true">→</span>
        </button>
      )}
    </div>
  );
}

export default InlineAlert;
