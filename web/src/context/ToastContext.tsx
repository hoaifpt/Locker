import React, { createContext, useContext, useState } from 'react';
import { ToastContainer, ToastMessage } from '../components/ui/Toast';

interface ToastContextType {
  toasts: ToastMessage[];
  show: (message: string, type?: 'success' | 'error' | 'info' | 'warning' | 'notification', duration?: number) => void;
  remove: (id: string) => void;
}

const ToastContext = createContext<ToastContextType | undefined>(undefined);

export function ToastProvider({ children }: { children: React.ReactNode }) {
  const [toasts, setToasts] = useState<ToastMessage[]>([]);
  const [id, setId] = useState(0);

  const show = (message: string, type: 'success' | 'error' | 'info' | 'warning' | 'notification' = 'info', duration?: number) => {
    const toastId = `toast-${id}`;
    setId(prev => prev + 1);
    const toast: ToastMessage = { id: toastId, message, type, duration };
    setToasts((prev) => [...prev, toast]);
    return toastId;
  };

  const remove = (toastId: string) => {
    setToasts((prev) => prev.filter((t) => t.id !== toastId));
  };

  return (
    <ToastContext.Provider value={{ toasts, show, remove }}>
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
