# Notification System Redesign — E-Box Payment Gateway

**Date**: 2026-08-15
**Status**: Approved (4/4 sections)
**Scope**: Frontend toast/notification module only

## 1. Context

The E-Box app currently uses a custom `ToastContext` + `Toast.tsx` implementation with:

- 5 types: `success | error | info | warning | notification`
- API: `show(message: string, type?, duration?)`
- Light-theme-only styling (`bg-{color}-50`, `text-{color}-800`)
- Single-line message, no title/description/action
- No dedupe (spamming same toast creates duplicates)
- No queue cap
- Default duration 4000ms across all types
- Position: `top-right`, mobile not responsive

There are ~150 call sites across 22 files. The user explicitly requested a redesign that **does not touch call sites** — preserve API.

The WalletPage already has a known UX issue (fixed in earlier turn): clicking "Nạp tiền vào ví" while a payment is pending creates a new payment. Toast warning alone is not enough UX for this case — an inline alert is needed.

## 2. Goals

- Match the E-Box design system: dark navy + orange accent + premium fintech aesthetic
- Follow app theme (light/dark)
- Fix notification spam (dedupe)
- Bound queue size
- Resolve WalletPage pending-payment UX with an inline alert (no spam toast)
- Zero call site changes

## 3. Non-Goals

- No `notify.success({title, description, action})` API (user chose `title_only`)
- No progress bar on toast
- No Sonner / library migration
- No toast position migration (no center, no bottom)
- No mass call-site rewrite (22 files / 150 calls untouched)

## 4. Architecture

3 files involved:

```
web/src/components/ui/Toast.tsx          ← redesigned (visual, animation, icons)
web/src/context/ToastContext.tsx         ← redesigned (queue, dedupe, default durations)
web/src/components/ui/InlineAlert.tsx    ← NEW (used inside WalletPage topup modal)
```

API unchanged:

```ts
const { show, remove } = useToast();
show(message: string, type?: ToastType = 'info', duration?: number): string;
remove(id: string): void;
```

Where `ToastType = 'success' | 'error' | 'info' | 'warning' | 'notification'`.

## 5. Visual Design

### 5.1 Container

```
Desktop: fixed right-6 top-24 z-50 flex flex-col gap-2.5
Mobile:  fixed left-4 right-4 top-4 z-50 flex flex-col gap-2
```

Wrapper: `pointer-events-none`. Each toast wrapped in `pointer-events-auto`.

### 5.2 Toast Card

```
┌──────────────────────────────────────────┐
│ ▌  [icon]  message text           [ × ] │
└──────────────────────────────────────────┘
    ↑
    4px left border (semantic color)
```

- Width: `min-w-[320px] max-w-[420px]`, mobile full-width minus 32px
- Padding: `px-4 py-3`
- Border radius: `rounded-xl` (12px)
- Outer border: `1px solid slate-200 / slate-800`
- Shadow: `shadow-lg shadow-slate-200/50` (light) / `shadow-xl shadow-black/40` (dark)
- Left border accent: 4px wide, semantic color

### 5.3 Light Mode

- bg: `bg-white`
- border: `border border-slate-200`
- text: `text-slate-900`
- accent: full semantic color

### 5.4 Dark Mode

- bg: `bg-slate-900`
- border: `border border-slate-800`
- text: `text-slate-100`
- accent: full semantic color

### 5.5 Semantic Color Tokens (icons + left border only)

| Type | Color | Tailwind |
|------|-------|----------|
| success | emerald-500 | `text-emerald-500` / `border-l-emerald-500` |
| error | red-500 | `text-red-500` / `border-l-red-500` |
| warning | amber-500 | `text-amber-500` / `border-l-amber-500` |
| info | blue-500 | `text-blue-500` / `border-l-blue-500` |
| notification | orange-500 | `text-orange-500` / `border-l-orange-500` |

Background and text NEVER use semantic color (preserves dark fintech aesthetic).

### 5.6 Icons (Lucide, already installed)

- success: `CheckCircle2` (20px)
- error: `CircleX` (20px)
- warning: `TriangleAlert` (20px)
- info: `Info` (20px)
- notification: `Bell` (20px)
- close: `X` (16px, 32x32 hit area, hover bg `bg-slate-100 dark:bg-slate-800` rounded-md)

## 6. Behavior

### 6.1 Default Durations (per type)

| Type | Default ms |
|------|-----------|
| success | 3500 |
| info | 4500 |
| warning | 6000 |
| notification | 5000 |
| error | 7000 |

Explicit `duration` argument overrides default.

### 6.2 Dedupe

Key = `` `${type}::${message}` ``.

When `show(key)` is called and key exists in active toasts:
- Do NOT create new toast
- Reset timer of existing toast (re-extend by its default duration)
- Trigger pulse animation on existing toast: opacity `1 → 0.7 → 1` over 200ms via Tailwind `transition-opacity` + `data-pulse` attribute (NOT framer-motion keyframes — they conflict with enter/exit)

This prevents spam from rapid duplicate clicks.

### 6.3 Queue Cap

Max 4 active toasts. When exceeded, oldest (FIFO) is removed.

### 6.4 Animation (framer-motion)

Enter:
```
opacity: 0 → 1
x: 16 → 0
scale: 0.98 → 1
duration: 200ms ease-out
```

Exit:
```
opacity: 1 → 0
x: 8 → 0
duration: 150ms ease-in
```

No bounce. No shake. No glow pulse.

### 6.5 Accessibility

- Container: `role="region" aria-label="Notifications"`
- Each toast: `role="status" aria-live="polite"`
- Error toast: `aria-live="assertive"` (override)
- Esc key while toast is hovered/focused → dismiss
- Close button: `aria-label="Đóng"`

## 7. InlineAlert Component (NEW)

Used inside WalletPage topup modal as an alternative to spamming a toast when user clicks "Nạp tiền vào ví" while a payment is pending.

### 7.1 API

```tsx
<InlineAlert
  variant="warning" | "info"
  title={string}
  description?: string
  action?: { label: string; onClick: () => void }
  onDismiss?: () => void
/>
```

### 7.2 Visual

```
┌─────────────────────────────────────────────────────┐
│ ▌ ⚠  Giao dịch đang chờ                            │
│    Bạn cần hoàn thành giao dịch hiện tại trước.    │
│                                          [Đóng ×]  │
│                                                     │
│    [Tiếp tục thanh toán →]                          │
└─────────────────────────────────────────────────────┘
```

- Full width of container, max-w-[640px]
- Padding: `px-5 py-4`
- Border radius: `rounded-xl`
- Light: `bg-amber-50 border border-amber-200`
- Dark: `bg-amber-500/10 border border-amber-500/30`
- Left accent: 4px `border-l-amber-500`
- Title: `text-sm font-semibold`
- Description: `text-sm text-slate-600 dark:text-slate-400`
- Action button: ghost button with `text-amber-700 dark:text-amber-400`

### 7.3 WalletPage Integration

Replace current toast warning in `handleOpenTopup` (line ~240-260):

```tsx
// Before (current):
if (hasPendingPayment) {
  showToast('Bạn cần hoàn thành giao dịch đang chờ trước khi tạo giao dịch mới.', 'warning');
  setStep('paying');
  return;
}

// After:
if (hasPendingPayment) {
  setStep('paying');
  return;
}
```

Add `<InlineAlert variant="warning" ... />` at the top of the 'paying' step UI in the topup modal — visible immediately when user lands on the QR screen, dismissible, with "Tiếp tục thanh toán" CTA that no-ops (the QR is already visible right below the alert, so user just scans).

## 8. Implementation Order

1. Rewrite `web/src/components/ui/Toast.tsx` with new visual + animation + icons
2. Rewrite `web/src/context/ToastContext.tsx` with queue cap + dedupe + default durations
3. Create `web/src/components/ui/InlineAlert.tsx`
4. Update `web/src/features/wallet/pages/WalletPage.tsx` — replace toast warning with InlineAlert in paying step
5. Run `npm run build` (verify 0 errors)
6. Manual test (next section)

## 9. Manual Test Cases

The user requested 14 cases. Cases 1-5, 7-10, 14 are pure toast behavior tests. Cases 11-13 are WalletPage flow. Case 6 (CTA toast) is OUT OF SCOPE per design decision.

| # | Case | How to verify |
|---|------|---------------|
| 1 | Success notification | `showToast('Đã sao chép', 'success')` |
| 2 | Error notification | `showToast('Thất bại', 'error')` |
| 3 | Warning notification | `showToast('Cảnh báo', 'warning')` |
| 4 | Info notification | `showToast('Thông tin', 'info')` |
| 5 | Pending (notification type) | `showToast('Có đơn mới', 'notification')` |
| 6 | Notification có CTA | **OUT OF SCOPE** (title_only) |
| 7 | Notification dài | `showToast('Một câu rất dài ' + 'rất '.repeat(20) + 'dài', 'info')` — should wrap, not overflow |
| 8 | Nhiều notification cùng lúc | fire 5 in a row → only 4 visible |
| 9 | Spam cùng notification | fire 3 same `(message, type)` → 1 toast, pulse 3 times |
| 10 | Mobile responsive | resize browser to 375px → toast full-width minus 32px |
| 11 | Payment pending → success | WalletPage: tạo payment → realtime signal Completed → success toast hiện 1 lần (không spam) |
| 12 | Payment pending → expired | WalletPage: countdown hết → expired UI, không toast spam |
| 13 | Payment failed | WalletPage: realtime signal Failed → 1 error toast |
| 14 | Copy success | click "Sao chép" → success toast hiện |

## 10. Risks

- **Risk**: Dark mode classes (`dark:bg-slate-900`) may not apply if app root doesn't have `dark` class. Mitigation: check `index.html` / layout root already toggles `dark` (verified in earlier exploration).
- **Risk**: Pulse animation on dedupe may interfere with framer-motion enter/exit. Mitigation: use a separate CSS transition (Tailwind `transition-opacity`) keyed off `data-pulse` attribute, not framer-motion keyframes.
- **Risk**: Queue cap may drop toasts user expected to see. Mitigation: cap is generous (4) and FIFO matches user mental model.

## 11. Acceptance Criteria

- All 22 call sites compile without modification.
- All 14 manual test cases pass (case 6 explicitly out of scope).
- `npm run build` exits 0 with no warnings (excluding pre-existing chunk-size warning).
- WalletPage topup modal shows InlineAlert (not toast) when resuming pending payment.
