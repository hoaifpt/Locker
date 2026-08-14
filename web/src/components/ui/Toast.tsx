import { useState, useEffect, useCallback } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import {
  X,
  CheckCircle2,
  CircleX,
  TriangleAlert,
  Info,
  Bell,
  type LucideIcon,
} from 'lucide-react';

export type ToastType = 'success' | 'error' | 'info' | 'warning' | 'notification';

export interface ToastMessage {
  id: string;
  message: string;
  type: ToastType;
  duration?: number;
}

interface SingleToastProps {
  toast: ToastMessage & { pulseAt?: number };
  onClose: () => void;
}

const ICON_MAP: Record<ToastType, LucideIcon> = {
  success: CheckCircle2,
  error: CircleX,
  warning: TriangleAlert,
  info: Info,
  notification: Bell,
};

const ACCENT_MAP: Record<ToastType, string> = {
  success: 'text-emerald-500 border-l-emerald-500',
  error: 'text-red-500 border-l-red-500',
  warning: 'text-amber-500 border-l-amber-500',
  info: 'text-blue-500 border-l-blue-500',
  notification: 'text-orange-500 border-l-orange-500',
};

export function SingleToast({ toast, onClose }: SingleToastProps) {
  const Icon = ICON_MAP[toast.type];
  const accent = ACCENT_MAP[toast.type];
  const [pulsing, setPulsing] = useState(false);

  useEffect(() => {
    if (!toast.pulseAt) return;
    setPulsing(true);
    const t = setTimeout(() => setPulsing(false), 220);
    return () => clearTimeout(t);
  }, [toast.pulseAt]);

  useEffect(() => {
    if (!toast.duration) return;
    const timer = setTimeout(() => onClose(), toast.duration);
    return () => clearTimeout(timer);
  }, [toast.id, toast.duration, onClose]);

  const handleKeyDown = useCallback(
    (e: React.KeyboardEvent) => {
      if (e.key === 'Escape') onClose();
    },
    [onClose],
  );

  return (
    <div
      role="status"
      aria-live={toast.type === 'error' ? 'assertive' : 'polite'}
      tabIndex={-1}
      onKeyDown={handleKeyDown}
      data-pulse={pulsing ? 'true' : 'false'}
      className={[
        'flex w-full min-w-[280px] max-w-[420px] items-start gap-3 overflow-hidden rounded-xl border border-l-4 px-4 py-3 shadow-lg backdrop-blur-sm transition-opacity duration-200',
        // Light theme
        'border-slate-200 bg-white text-slate-900 shadow-slate-200/50',
        // Dark theme
        'dark:border-slate-800 dark:bg-slate-900 dark:text-slate-100 dark:shadow-black/40',
        // Pulse
        pulsing ? 'opacity-70' : 'opacity-100',
        accent,
      ].join(' ')}
    >
      <Icon size={20} className={`mt-0.5 shrink-0 ${accent.split(' ')[0]}`} aria-hidden="true" />
      <span className="flex-1 text-sm leading-relaxed">{toast.message}</span>
      <button
        type="button"
        onClick={onClose}
        aria-label="Đóng"
        className="-mr-1 inline-flex h-8 w-8 shrink-0 items-center justify-center rounded-md text-slate-400 transition hover:bg-slate-100 hover:text-slate-700 dark:text-slate-500 dark:hover:bg-slate-800 dark:hover:text-slate-200"
      >
        <X size={16} aria-hidden="true" />
      </button>
    </div>
  );
}

interface ToastContainerProps {
  toasts: (ToastMessage & { pulseAt?: number })[];
  onRemove: (id: string) => void;
}

export function ToastContainer({ toasts, onRemove }: ToastContainerProps) {
  return (
    <div
      role="region"
      aria-label="Notifications"
      className="pointer-events-none fixed left-4 right-4 top-4 z-[100] flex flex-col gap-2.5 sm:left-auto sm:right-6 sm:top-24"
    >
      <AnimatePresence initial={false}>
        {toasts.map((toast) => (
          <motion.div
            key={toast.id}
            layout
            initial={{ opacity: 0, x: 16, scale: 0.98 }}
            animate={{ opacity: 1, x: 0, scale: 1 }}
            exit={{ opacity: 0, x: 8, transition: { duration: 0.15 } }}
            transition={{ duration: 0.2, ease: 'easeOut' }}
            className="pointer-events-auto"
          >
            <SingleToast toast={toast} onClose={() => onRemove(toast.id)} />
          </motion.div>
        ))}
      </AnimatePresence>
    </div>
  );
}
