import React, { createContext, useContext, useState, useRef, useCallback, useMemo } from 'react';
import { ToastContainer } from '../components/ui/Toast';
import type { ToastMessage, ToastType } from '../components/ui/Toast';

const DEFAULT_DURATIONS: Record<ToastType, number> = {
  success: 3500,
  info: 4500,
  warning: 6000,
  notification: 5000,
  error: 7000,
};

const MAX_TOASTS = 4;

interface ToastContextType {
  show: (message: string, type?: ToastType, duration?: number) => string;
  remove: (id: string) => void;
}

const ToastContext = createContext<ToastContextType | undefined>(undefined);

export function ToastProvider({ children }: { children: React.ReactNode }) {
  const [toasts, setToasts] = useState<(ToastMessage & { pulseAt?: number })[]>([]);
  const idRef = useRef(0);

  const remove = useCallback((toastId: string) => {
    setToasts((prev) => prev.filter((t) => t.id !== toastId));
  }, []);

  const show = useCallback(
    (message: string, type: ToastType = 'info', duration?: number): string => {
      const dedupeKey = `${type}::${message}`;
      let existingId: string | null = null;

      setToasts((prev) => {
        const existing = prev.find((t) => `${t.type}::${t.message}` === dedupeKey);
        if (existing) {
          existingId = existing.id;
          return prev.map((t) =>
            t.id === existing.id
              ? { ...t, duration: duration ?? DEFAULT_DURATIONS[type], pulseAt: Date.now() }
              : t,
          );
        }

        idRef.current += 1;
        const newId = `toast-${idRef.current}`;
        const newToast: ToastMessage & { pulseAt?: number } = {
          id: newId,
          message,
          type,
          duration: duration ?? DEFAULT_DURATIONS[type],
        };
        const next = [...prev, newToast];
        if (next.length > MAX_TOASTS) {
          return next.slice(next.length - MAX_TOASTS);
        }
        return next;
      });

      return existingId ?? `toast-${idRef.current}`;
    },
    [],
  );

  const contextValue = useMemo(() => ({ show, remove }), [show, remove]);

  return (
    <ToastContext.Provider value={contextValue}>
      {children}
      <ToastContainer toasts={toasts} onRemove={remove} />
    </ToastContext.Provider>
  );
}

export function useToast() {
  const context = useContext(ToastContext);
  if (!context) {
    throw new Error('useToast must be used within ToastProvider');
  }
  return context;
}
