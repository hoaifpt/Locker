# Notification System Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Redesign the E-Box toast/notification module to match the premium fintech design system (dark navy + orange accent + semantic colors), add dedupe/queue/a11y, and replace the WalletPage pending-payment toast spam with an inline alert. Zero call site changes.

**Architecture:** In-place rewrite of existing `Toast.tsx` + `ToastContext.tsx` (API preserved: `show(message, type, duration?)`), add a new `InlineAlert.tsx` for contextual banners, integrate the InlineAlert into WalletPage topup modal step 'paying'.

**Tech Stack:** React 18, TypeScript, Tailwind CSS (vanilla, no extended tokens), framer-motion (already installed), lucide-react (already installed).

## Global Constraints

- API signature MUST remain: `show(message: string, type?: ToastType = 'info', duration?: number): string` — no call site may break.
- ToastType union MUST remain: `'success' | 'error' | 'info' | 'warning' | 'notification'`.
- Tailwind config is vanilla — no extended tokens. Use standard Tailwind utilities only.
- No new dependencies.
- No changes to business logic or API endpoints.
- Manual test cases are acceptance criteria — they must all pass before declaring done.

---

## Task 1: Rewrite `Toast.tsx` visual layer

**Files:**
- Modify: `web/src/components/ui/Toast.tsx` (entire file rewrite)

**Interfaces:**
- Consumes: `ToastMessage { id: string; message: string; type: ToastType; duration?: number }` from context.
- Produces: `SingleToast` and `ToastContainer` components with new visual + animation.
- Exports unchanged: `ToastMessage` type, `ToastType` type, `ToastContainer` component.

**Context:** Existing file uses light-theme only (`bg-{color}-50`). New version follows app theme (light/dark) and uses semantic left-border accent only — never tints the whole card.

- [ ] **Step 1: Rewrite `Toast.tsx` with new design**

Replace the entire content of `web/src/components/ui/Toast.tsx` with:

```tsx
import { useState, useEffect, useCallback } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { X, CheckCircle2, CircleX, TriangleAlert, Info, Bell } from 'lucide-react';

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

const ICON_MAP: Record<ToastType, React.ComponentType<{ size?: number; className?: string }>> = {
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
```

- [ ] **Step 2: Verify file compiles**

Run: `cd web && npx tsc --noEmit`
Expected: 0 errors. (Other pre-existing errors unrelated to Toast.tsx are OK; only verify `components/ui/Toast.tsx` reports no new errors.)

- [ ] **Step 3: Commit**

```bash
cd d:\GitHub\Locker
git add web/src/components/ui/Toast.tsx
git commit -m "feat(ui): redesign Toast visual with theme + semantic accent"
```

---

## Task 2: Rewrite `ToastContext.tsx` with queue, dedupe, defaults

**Files:**
- Modify: `web/src/context/ToastContext.tsx` (entire file rewrite)

**Interfaces:**
- Consumes: nothing (state container).
- Produces: `ToastProvider`, `useToast()` hook with signature unchanged.
- Public API: `show(message: string, type?: ToastType = 'info', duration?: number): string` and `remove(id: string): void`.

- [ ] **Step 1: Rewrite `ToastContext.tsx`**

Replace entire content of `web/src/context/ToastContext.tsx` with:

```tsx
import React, { createContext, useContext, useState, useRef, useCallback } from 'react';
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
              ? { ...t, duration: duration ?? t.duration, pulseAt: Date.now() }
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
        // Queue cap: drop oldest if over MAX_TOASTS
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

  return (
    <ToastContext.Provider value={{ show, remove }}>
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
```

- [ ] **Step 2: Verify compile**

Run: `cd web && npx tsc --noEmit`
Expected: 0 new errors.

- [ ] **Step 3: Build**

Run: `cd web && npm run build`
Expected: exit 0, only the pre-existing chunk-size warning.

- [ ] **Step 4: Commit**

```bash
cd d:\GitHub\Locker
git add web/src/context/ToastContext.tsx
git commit -m "feat(ui): add toast queue cap + dedupe + per-type default durations"
```

---

## Task 3: Create `InlineAlert.tsx`

**Files:**
- Create: `web/src/components/ui/InlineAlert.tsx`

**Interfaces:**
- Consumes: `variant: 'warning' | 'info'`, `title: string`, `description?: string`, `action?: { label: string; onClick: () => void }`, `onDismiss?: () => void`.
- Produces: standalone banner component using lucide icons.

- [ ] **Step 1: Create the file**

Create `web/src/components/ui/InlineAlert.tsx` with:

```tsx
import { TriangleAlert, Info, X } from 'lucide-react';

interface InlineAlertProps {
  variant: 'warning' | 'info';
  title: string;
  description?: string;
  action?: { label: string; onClick: () => void };
  onDismiss?: () => void;
}

const VARIANT_STYLES: Record<InlineAlertProps['variant'], {
  container: string;
  iconColor: string;
  accent: string;
  Icon: React.ComponentType<{ size?: number; className?: string }>;
  actionClass: string;
}> = {
  warning: {
    container:
      'border-amber-200 bg-amber-50 dark:border-amber-500/30 dark:bg-amber-500/10',
    iconColor: 'text-amber-500',
    accent: 'border-l-amber-500',
    Icon: TriangleAlert,
    actionClass:
      'text-amber-700 hover:bg-amber-100 dark:text-amber-400 dark:hover:bg-amber-500/20',
  },
  info: {
    container: 'border-blue-200 bg-blue-50 dark:border-blue-500/30 dark:bg-blue-500/10',
    iconColor: 'text-blue-500',
    accent: 'border-l-blue-500',
    Icon: Info,
    actionClass:
      'text-blue-700 hover:bg-blue-100 dark:text-blue-400 dark:hover:bg-blue-500/20',
  },
};

export function InlineAlert({ variant, title, description, action, onDismiss }: InlineAlertProps) {
  const styles = VARIANT_STYLES[variant];
  const { Icon } = styles;

  return (
    <div
      role="alert"
      className={[
        'flex flex-col gap-2 rounded-xl border border-l-4 px-5 py-4',
        styles.container,
        styles.accent,
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
```

- [ ] **Step 2: Verify compile**

Run: `cd web && npx tsc --noEmit`
Expected: 0 new errors.

- [ ] **Step 3: Commit**

```bash
cd d:\GitHub\Locker
git add web/src/components/ui/InlineAlert.tsx
git commit -m "feat(ui): add InlineAlert component for contextual banners"
```

---

## Task 4: Replace WalletPage toast warning with InlineAlert

**Files:**
- Modify: `web/src/features/wallet/pages/WalletPage.tsx` (lines ~240-260 + topup 'paying' step UI)

**Interfaces:**
- Consumes: `InlineAlert` from `components/ui/InlineAlert`.
- Produces: topup modal 'paying' step renders an InlineAlert at the top instead of relying on a toast.

- [ ] **Step 1: Add InlineAlert import**

In `web/src/features/wallet/pages/WalletPage.tsx`, find the import block (top of file) and add `InlineAlert` to the `components/ui` import group. The file currently imports from `../components/ui` patterns; add a new line after the existing UI imports:

```tsx
import InlineAlert from '../../../components/ui/InlineAlert';
```

(If the file imports UI components individually, place this in the appropriate spot. Verify by reading the import block first.)

- [ ] **Step 2: Remove the toast warning from `handleOpenTopup`**

In the same file, locate `handleOpenTopup` (currently around line 240). Replace its body to remove the toast call but keep the early return:

Current (approximately):
```tsx
const handleOpenTopup = () => {
  // ...comments...
  const hasPendingPayment = ...;
  if (hasPendingPayment) {
    showToast('Bạn cần hoàn thành giao dịch đang chờ trước khi tạo giao dịch mới.', 'warning');
    setStep('paying');
    return;
  }
  setStep('select-amount');
  setPayment(null);
  setPaymentStatus(null);
};
```

New:
```tsx
const handleOpenTopup = () => {
  // Nếu đang có payment pending còn hạn → mở lại QR cũ (InlineAlert sẽ hiển thị trên modal).
  // Không gọi toast: tránh spam mỗi lần user click "Nạp tiền vào ví" trong khi chờ.
  const hasPendingPayment =
    payment &&
    payment.expiresAt &&
    new Date(payment.expiresAt).getTime() > Date.now() &&
    paymentStatus?.status !== 1 &&
    paymentStatus?.status !== 2;

  if (hasPendingPayment) {
    setStep('paying');
    return;
  }

  setStep('select-amount');
  setPayment(null);
  setPaymentStatus(null);
};
```

- [ ] **Step 3: Inject InlineAlert into the 'paying' step UI**

Locate the JSX of the topup modal's 'paying' step (rendered when `step === 'paying'`). At the top of that step's content (just inside the main wrapper element), insert:

```tsx
<InlineAlert
  variant="warning"
  title="Bạn đang có giao dịch chưa hoàn tất"
  description="Hoàn thành giao dịch hiện tại trước khi tạo giao dịch mới. Quét QR bên dưới để tiếp tục thanh toán."
  onDismiss={() => {
    handleCloseTopup();
  }}
/>
```

The exact insertion point depends on the JSX structure — place it as the first child of the 'paying' step's container, above the QR code section. Read the surrounding JSX first to find the right container.

- [ ] **Step 4: Verify build**

Run: `cd web && npm run build`
Expected: exit 0.

- [ ] **Step 5: Commit**

```bash
cd d:\GitHub\Locker
git add web/src/features/wallet/pages/WalletPage.tsx
git commit -m "feat(wallet): replace pending-payment toast with InlineAlert in topup modal"
```

---

## Task 5: Manual test pass

**Files:** none (verification only)

- [ ] **Step 1: Start dev server**

Run: `cd web && npm run dev`
Expected: server starts on default port (5173 or 3000). Open the URL in browser.

- [ ] **Step 2: Run test cases 1-5, 7-10, 14 (toast behavior)**

In browser devtools console, run:

```js
const { show } = window.__toast_test__ ?? {};
// If no global, inject via React DevTools or use app's useToast in a test page.
// Alternative: trigger toasts through real UI flows:
// - Click "Sao chép" → success (case 14)
// - Trigger an error → error (case 2)
// - Open/close modals rapidly to see warning (case 3)
```

Cases:
- 1. Success: trigger any success path → green left-border, white/slate-900 bg
- 2. Error: trigger any error path → red left-border
- 3. Warning: open WalletPage with pending payment → amber left-border on InlineAlert (NOT toast)
- 4. Info: any info path → blue left-border
- 5. Notification: bell icon → orange left-border
- 7. Long text: pass a 200+ char string → wraps, doesn't overflow
- 8. 5 in a row: only 4 visible
- 9. Spam same: 3 same `(message, type)` → 1 toast, opacity pulses 3 times
- 10. Mobile: resize browser to 375px → toast full-width minus 32px

- [ ] **Step 3: Run test cases 11-13 (WalletPage flow)**

- 11. Pending → success: open topup → tạo payment → realtime signal Completed → success toast hiện 1 lần
- 12. Pending → expired: đợi countdown hết → expired UI, không toast spam
- 13. Pending → failed: simulate Failed signal (hoặc manual mock) → 1 error toast

- [ ] **Step 4: Verify dark mode**

Toggle dark mode (via app's existing toggle). Verify toast uses `bg-slate-900` and `text-slate-100`.

- [ ] **Step 5: Final commit if any tweaks needed**

If manual tests revealed visual tweaks, fix them and commit:
```bash
cd d:\GitHub\Locker
git add -A
git commit -m "fix(ui): tweaks from manual test pass"
```

If all pass, no commit needed.

---

## Self-Review

**Spec coverage:**
- § 5 Visual → Task 1 ✓
- § 6.1 Default durations → Task 2 ✓
- § 6.2 Dedupe → Task 2 ✓
- § 6.3 Queue cap → Task 2 ✓
- § 6.4 Animation → Task 1 ✓
- § 6.5 A11y → Task 1 (aria-live, role, Esc) ✓
- § 7 InlineAlert → Task 3 ✓
- § 7.3 WalletPage integration → Task 4 ✓
- § 9 Manual test cases → Task 5 ✓

**Placeholder scan:** No TBDs. All code blocks complete. No "similar to Task N" references.

**Type consistency:** `ToastType` and `ToastMessage` defined in Task 1's Toast.tsx; imported and re-used by Task 2's ToastContext.tsx — consistent. `InlineAlertProps` defined once in Task 3 — only consumer is Task 4 which uses the exported `InlineAlert` component, not the props type directly.
