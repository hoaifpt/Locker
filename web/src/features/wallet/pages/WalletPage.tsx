import { useState, useEffect, useRef, useCallback, useMemo } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import {
  Wallet, Plus, ArrowUpRight, ArrowDownLeft, ShieldCheck, Clock, CreditCard, Sparkles,
  QrCode, Copy, CheckCircle, XCircle, Building2, Hash, ChevronLeft, Loader2, PartyPopper, Check, RotateCcw, AlertCircle, Lock,
} from 'lucide-react';
import type { HubConnection } from '@microsoft/signalr';
import AppHeader from '../../../components/layout/AppHeader';
import { hidden, visible, trans } from '../../../lib/animations';
import { apiFetch } from '../../../lib/api';
import { useToast } from '../../../context/ToastContext';
import { formatVnd, formatVndInput, normalizeVndInput } from '../utils/currency';
import { createPaymentRealtimeConnection } from '../api/paymentRealtime';
import InlineAlert from '../../../components/ui/InlineAlert';

interface WalletOverview {
  balance: number;
  recentTransactionsCount: number;
}

interface WalletTransaction {
  id: string;
  amount: number;
  type: number | string;
  status: number | string;
  description?: string;
  createdAt: string;
}

interface SepayInitResponse {
  paymentId: string;
  paymentUrl: string;
  amount: number;
  sepayCode: string;
  expiresAt: string;
}

interface PaymentStatus {
  id: string;
  amount: number;
  status: number | string;
  paidAt?: string | null;
}

const TRANSACTION_TYPE_LABELS = ['Nạp tiền', 'Chuyển khoản', 'Thanh toán', 'Hoàn tiền'];
const TRANSACTION_STATUS_LABELS = ['Đang xử lý', 'Hoàn thành', 'Thất bại', 'Đã huỷ'];
const TRANSACTION_STATUS_FILTERS = [
  { value: 'all', label: 'Tất cả' },
  { value: 'pending', label: 'Đang xử lý' },
  { value: 'completed', label: 'Hoàn thành' },
  { value: 'failed', label: 'Thất bại' },
  { value: 'cancelled', label: 'Đã huỷ' },
] as const;
const TOP_UP_AMOUNTS = [50_000, 100_000, 200_000, 500_000, 1_000_000, 2_000_000];
const POLL_INTERVAL_MS = 3000;
const PAYMENT_STORAGE_KEY = 'locker:pending-topup';

type TopupStep = 'idle' | 'select-amount' | 'paying' | 'success';

type StatusBadgeStatus = 'pending' | 'completed' | 'failed' | 'expired';

const StatusBadge = ({ status }: { status: StatusBadgeStatus }) => {
  if (status === 'completed') {
    return (
      <span className="inline-flex items-center gap-1.5 rounded-full bg-emerald-500/10 px-2.5 py-1 text-[10px] font-bold uppercase tracking-wider text-emerald-600 dark:text-emerald-400">
        <span className="h-1.5 w-1.5 rounded-full bg-emerald-500" />
        Hoàn thành
      </span>
    );
  }
  if (status === 'failed') {
    return (
      <span className="inline-flex items-center gap-1.5 rounded-full bg-red-500/10 px-2.5 py-1 text-[10px] font-bold uppercase tracking-wider text-red-600 dark:text-red-400">
        <span className="h-1.5 w-1.5 rounded-full bg-red-500" />
        Thất bại
      </span>
    );
  }
  if (status === 'expired') {
    return (
      <span className="inline-flex items-center gap-1.5 rounded-full bg-slate-200 px-2.5 py-1 text-[10px] font-bold uppercase tracking-wider text-slate-600 dark:bg-slate-800 dark:text-slate-300">
        <span className="h-1.5 w-1.5 rounded-full bg-slate-500" />
        Hết hạn
      </span>
    );
  }
  return (
    <span className="inline-flex items-center gap-1.5 rounded-full bg-amber-500/10 px-2.5 py-1 text-[10px] font-bold uppercase tracking-wider text-amber-600 dark:text-amber-400">
      <span className="relative flex h-1.5 w-1.5">
        <span className="absolute inline-flex h-full w-full animate-ping rounded-full bg-amber-500 opacity-75" />
        <span className="relative inline-flex h-1.5 w-1.5 rounded-full bg-amber-500" />
      </span>
      Đang chờ
    </span>
  );
};

export default function WalletPage() {
  const { show: showToast } = useToast();
  const [balance, setBalance] = useState(0);
  const [transactions, setTransactions] = useState<WalletTransaction[]>([]);
  const [loading, setLoading] = useState(true);

  type StatusFilter = (typeof TRANSACTION_STATUS_FILTERS)[number]['value'];
  const [statusFilter, setStatusFilter] = useState<StatusFilter>('all');

  const filteredTransactions = useMemo(() => {
    if (statusFilter === 'all') return transactions;
    return transactions.filter((t) => {
      const s = String(t.status).toLowerCase();
      const type = String(t.type).toLowerCase();
      if (statusFilter === 'cancelled') return s === '3' || s === 'cancelled';
      if (statusFilter === 'pending') return s === '0' || s === 'pending';
      if (statusFilter === 'completed') return s === '1' || s === 'completed';
      if (statusFilter === 'failed') return s === '2' || s === 'failed';
      // Reference-only transactions (Cancelled/Refunded/...) should still appear under "all"
      // even if Type is empty. The statusFilter='all' short-circuit above handles that.
      return type === statusFilter;
    });
  }, [transactions, statusFilter]);

  const [step, setStep] = useState<TopupStep>('idle');
  const [topupAmount, setTopupAmount] = useState('100000');
  const [processing, setProcessing] = useState(false);

  const [payment, setPayment] = useState<SepayInitResponse | null>(null);
  const [paymentStatus, setPaymentStatus] = useState<PaymentStatus | null>(null);
  const [secondsLeft, setSecondsLeft] = useState(0);
  const [copied, setCopied] = useState(false);
  const [showCancelConfirm, setShowCancelConfirm] = useState(false);
  const [cancelling, setCancelling] = useState(false);
  // Increment mỗi lần user CHỦ ĐỘNG mở lại modal QR trong khi còn pending payment.
  // -0 = chưa user-action nào → banner không hiện (tránh hiển thị lúc auto-restore on mount)
  // >0 = user vừa click → banner hiện + shake để phản hồi
  const [resumePendingNonce, setResumePendingNonce] = useState(0);

  const pollingRef = useRef<ReturnType<typeof setInterval> | null>(null);
  const realtimeRef = useRef<HubConnection | null>(null);
  const currentPaymentIdRef = useRef<string | null>(null);

  const loadWallet = useCallback(async () => {
    try {
      const [overviewResponse, transactionsResponse] = await Promise.all([
        apiFetch('/wallet/overview'),
        apiFetch('/wallet/transactions'),
      ]);

      if (!overviewResponse.ok || !transactionsResponse.ok) {
        throw new Error('Không thể tải thông tin ví.');
      }

      const [overview, walletTransactions] = await Promise.all([
        overviewResponse.json() as Promise<WalletOverview>,
        transactionsResponse.json() as Promise<WalletTransaction[]>,
      ]);

      setBalance(overview.balance);
      setTransactions(walletTransactions.sort(
        (a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime(),
      ));
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Không thể tải thông tin ví.';
      showToast(message, 'error');
    } finally {
      setLoading(false);
    }
  }, [showToast]);

  useEffect(() => {
    void loadWallet();
    const refreshWhenVisible = () => {
      if (document.visibilityState === 'visible') void loadWallet();
    };
    document.addEventListener('visibilitychange', refreshWhenVisible);
    return () => document.removeEventListener('visibilitychange', refreshWhenVisible);
  }, [loadWallet]);

  const stopPolling = () => {
    if (pollingRef.current) {
      clearInterval(pollingRef.current);
      pollingRef.current = null;
    }
  };

  const persistPendingPayment = (p: SepayInitResponse | null) => {
    try {
      if (p) {
        sessionStorage.setItem(PAYMENT_STORAGE_KEY, JSON.stringify(p));
      } else {
        sessionStorage.removeItem(PAYMENT_STORAGE_KEY);
      }
    } catch {
      /* sessionStorage unavailable */
    }
  };

  const openRealtime = useCallback(async (paymentId: string) => {
    currentPaymentIdRef.current = paymentId;
    if (realtimeRef.current) return;
    const conn = createPaymentRealtimeConnection({
      onPaymentStatusChanged: (payload) => {
        if (!currentPaymentIdRef.current || payload.paymentId !== currentPaymentIdRef.current) return;
        const numericStatus =
          payload.status === 'Completed' ? 1 :
          payload.status === 'Failed' ? 2 :
          payload.status === 'Cancelled' ? 3 :
          String(payload.status).toLowerCase() === 'completed' ? 1 :
          String(payload.status).toLowerCase() === 'failed' ? 2 :
          String(payload.status).toLowerCase() === 'cancelled' ? 3 : 0;
        setPaymentStatus({
          id: payload.paymentId,
          amount: payload.amount,
          status: numericStatus,
          paidAt: payload.paidAt ?? null,
        });
        if (numericStatus === 1) {
          stopPolling();
          void loadWallet();
          setStep('success');
        } else if (numericStatus === 2) {
          stopPolling();
          showToast('Thanh toán thất bại.', 'error');
        } else if (numericStatus === 3) {
          stopPolling();
          showToast('Đã huỷ thanh toán.', 'warning');
        }
      },
    });
    realtimeRef.current = conn;
    conn.onreconnecting(() => console.info('[payment-realtime] reconnecting'));
    conn.onreconnected(() => console.info('[payment-realtime] reconnected'));
    conn.onclose((err) => console.warn('[payment-realtime] closed', err));
    try {
      await conn.start();
      console.info('[payment-realtime] connected, paymentId=', paymentId);
    } catch (err) {
      console.warn('[payment-realtime] start failed', err);
    }
  }, [showToast, loadWallet]);

  const closeRealtime = useCallback(async () => {
    const conn = realtimeRef.current;
    realtimeRef.current = null;
    if (conn) {
      try { await conn.stop(); } catch { /* noop */ }
    }
  }, []);

  // Hydrate pending payment from sessionStorage on mount
  useEffect(() => {
    try {
      const raw = sessionStorage.getItem(PAYMENT_STORAGE_KEY);
      if (!raw) return;
      const p = JSON.parse(raw) as SepayInitResponse;
      if (!p?.paymentId || !p?.expiresAt) return;
      const expiredByTime = new Date(p.expiresAt).getTime() <= Date.now();
      if (expiredByTime) {
        sessionStorage.removeItem(PAYMENT_STORAGE_KEY);
        return;
      }
      setPayment(p);
      setStep('paying');
      void openRealtime(p.paymentId);
    } catch {
      sessionStorage.removeItem(PAYMENT_STORAGE_KEY);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const handleOpenTopup = () => {
    // Nếu đang có payment pending còn hạn → user chủ động click "Nạp tiền vào ví" lần 2:
    //   1. bump nonce để trigger InlineAlert + shake animation cho user biết hệ thống vừa respond
    //   2. mở lại QR cũ thay vì tạo payment mới (tránh lãng phí SepayCode + đè IPN cũ)
    const hasPendingPayment =
      payment &&
      payment.expiresAt &&
      new Date(payment.expiresAt).getTime() > Date.now() &&
      paymentStatus?.status !== 1 && // 1 = Completed
      paymentStatus?.status !== 2;   // 2 = Failed

    if (hasPendingPayment) {
      setResumePendingNonce((n) => n + 1);
      setStep('paying');
      return;
    }

    setStep('select-amount');
    setPayment(null);
    setPaymentStatus(null);
    setResumePendingNonce(0);
  };

  const handleCloseTopup = () => {
    stopPolling();
    setStep('idle');
    setPayment(null);
    setPaymentStatus(null);
    setProcessing(false);
    persistPendingPayment(null);
    setResumePendingNonce(0);
    void closeRealtime();
  };

  const handleCancelTopup = async () => {
    if (!payment?.paymentId || cancelling) return;
    setCancelling(true);
    try {
      const response = await apiFetch('/wallet/top-up/sepay/cancel', {
        method: 'POST',
        data: { paymentId: payment.paymentId },
      });
      if (response.ok) {
        showToast('Đã huỷ thanh toán.', 'warning');
      } else {
        console.warn('[sepay-cancel] backend rejected, will rely on timeout');
        showToast('Không thể huỷ ngay. Giao dịch sẽ tự hết hạn.', 'warning');
      }
    } catch (err) {
      console.warn('[sepay-cancel] network error', err);
      showToast('Không thể huỷ ngay. Giao dịch sẽ tự hết hạn.', 'warning');
    } finally {
      setCancelling(false);
      setShowCancelConfirm(false);
      // Cleanup local ngay — realtime (nếu thành công) sẽ tự đóng modal phần còn lại
      handleCloseTopup();
    }
  };

  const handleSubmitAmount = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!topupAmount || Number(topupAmount) <= 1000) {
      showToast('Số tiền nạp phải lớn hơn 1.000 ₫', 'error');
      return;
    }
    setProcessing(true);
    try {
      const response = await apiFetch('/wallet/top-up/sepay/init', {
        method: 'POST',
        data: { amount: Number(topupAmount) },
      });

      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(errorData.message || 'Khởi tạo thanh toán thất bại.');
      }

      const result = (await response.json()) as SepayInitResponse;
      if (!result.paymentId || !result.paymentUrl) {
        throw new Error('Không nhận được dữ liệu thanh toán từ server.');
      }

      persistPendingPayment(result);
      setPayment(result);
      setPaymentStatus(null);
      setStep('paying');
      void openRealtime(result.paymentId);
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : 'Đã có lỗi xảy ra.';
      showToast(errorMessage, 'error');
    } finally {
      setProcessing(false);
    }
  };

  // Countdown
  useEffect(() => {
    if (step !== 'paying' || !payment?.expiresAt) return;
    const targetMs = new Date(payment.expiresAt).getTime();
    const tick = () => setSecondsLeft(Math.max(0, Math.floor((targetMs - Date.now()) / 1000)));
    tick();
    const id = setInterval(tick, 1000);
    return () => clearInterval(id);
  }, [step, payment?.expiresAt]);

  // Polling payment status
  useEffect(() => {
    if (step !== 'paying' || !payment?.paymentId) return;

    const checkStatus = async () => {
      try {
        const res = await apiFetch(`/payments/${payment.paymentId}`);
        if (!res.ok) return;
        const data = (await res.json()) as PaymentStatus;
        setPaymentStatus(data);

        const statusValue = typeof data.status === 'number' ? data.status : String(data.status).toLowerCase();
        if (statusValue === 1 || statusValue === 'completed') {
          stopPolling();
          await loadWallet();
          setStep('success');
        } else if (statusValue === 2 || statusValue === 'failed') {
          stopPolling();
          showToast('Thanh toán thất bại.', 'error');
        }
      } catch {
        /* silent retry */
      }
    };

    void checkStatus();
    pollingRef.current = setInterval(checkStatus, POLL_INTERVAL_MS);

    return () => stopPolling();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [step, payment?.paymentId]);

  const handleCopy = async () => {
    if (!payment?.sepayCode) return;
    try {
      await navigator.clipboard.writeText(payment.sepayCode);
      setCopied(true);
      showToast('Đã sao chép mã chuyển khoản', 'success');
      setTimeout(() => setCopied(false), 2000);
    } catch {
      showToast('Không thể sao chép. Vui lòng copy thủ công.', 'error');
    }
  };

  const handleCreateNew = () => {
    stopPolling();
    setPaymentStatus(null);
    setStep('select-amount');
  };

  const formatCountdown = (s: number) =>
    `${Math.floor(s / 60).toString().padStart(2, '0')}:${(s % 60).toString().padStart(2, '0')}`;

  const formatSuccessTimestamp = (iso?: string | null) => {
    const d = iso ? new Date(iso) : new Date();
    if (Number.isNaN(d.getTime())) return new Date().toLocaleString('vi-VN');
    const hh = d.getHours().toString().padStart(2, '0');
    const mm = d.getMinutes().toString().padStart(2, '0');
    const ss = d.getSeconds().toString().padStart(2, '0');
    const dd = d.getDate().toString().padStart(2, '0');
    const MM = (d.getMonth() + 1).toString().padStart(2, '0');
    const yyyy = d.getFullYear();
    return `${hh}:${mm}:${ss} · ${dd}/${MM}/${yyyy}`;
  };

  const getIcon = (type: string, amount: number) => {
    if (type === 'TopUp' || type === '0' || amount > 0) return <ArrowDownLeft size={16} className="text-green-500" />;
    return <ArrowUpRight size={16} className="text-red-500" />;
  };

  const getTransactionTypeLabel = (type: number | string) => {
    if (typeof type === 'number') return TRANSACTION_TYPE_LABELS[type] ?? String(type);
    return type;
  };

  const getTransactionStatusLabel = (status: number | string) => {
    if (typeof status === 'number') return TRANSACTION_STATUS_LABELS[status] ?? String(status);
    if (typeof status === 'string') {
      const key = status.toLowerCase();
      if (key === 'pending') return 'Đang xử lý';
      if (key === 'completed') return 'Hoàn thành';
      if (key === 'failed') return 'Thất bại';
      if (key === 'cancelled') return 'Đã huỷ';
    }
    return status;
  };

  const getStatusBgClass = (status: string) => {
    const s = status.toLowerCase();
    if (s === '3' || s === 'cancelled') return 'bg-slate-100 dark:bg-slate-800/60';
    if (s === '2' || s === 'failed') return 'bg-red-50 dark:bg-red-950/40';
    if (s === '1' || s === 'completed') return 'bg-emerald-50 dark:bg-emerald-950/40';
    return 'bg-amber-50 dark:bg-amber-950/40';
  };

  const getStatusAmountClass = (status: string, amount: number) => {
    const s = status.toLowerCase();
    if (s === '3' || s === 'cancelled') return 'text-slate-400 line-through dark:text-slate-500';
    if (s === '2' || s === 'failed') return 'text-slate-400 line-through dark:text-slate-500';
    if (s === '1' || s === 'completed') return amount > 0 ? 'text-emerald-600 dark:text-emerald-400' : 'text-slate-900 dark:text-white';
    return 'text-amber-600 dark:text-amber-400';
  };

  const getStatusLabelClass = (status: string) => {
    const s = status.toLowerCase();
    if (s === '3' || s === 'cancelled') return 'text-slate-500 dark:text-slate-400';
    if (s === '2' || s === 'failed') return 'text-red-500 dark:text-red-400';
    if (s === '1' || s === 'completed') return 'text-emerald-600 dark:text-emerald-400';
    return 'text-amber-600 dark:text-amber-400';
  };

  const expired = secondsLeft <= 0 && step === 'paying';
  const statusValue = typeof paymentStatus?.status === 'number' ? paymentStatus.status : -1;
  const isCompleted = statusValue === 1;
  const isFailed = statusValue === 2;
  const isCancelled = statusValue === 3;

  return (
    <div className="min-h-screen bg-[#f7f7f8] font-sans antialiased dark:bg-slate-950">
      <AppHeader />
      <main className="mx-auto max-w-5xl px-4 py-8 sm:px-6 lg:py-12">
        <motion.div initial={hidden} animate={visible} transition={trans(0)} className="mb-7">
          <span className="inline-flex items-center gap-2 rounded-full border border-orange-200 bg-orange-50 px-3 py-1 text-xs font-bold uppercase tracking-[0.16em] text-orange-600 dark:border-orange-500/30 dark:bg-orange-950/40 dark:text-orange-400">
            <Sparkles size={13} /> Ví điện tử
          </span>
          <h1 className="mt-3 text-3xl font-extrabold tracking-tight text-slate-950 dark:text-white sm:text-4xl">Ví E-Box Pay</h1>
          <p className="mt-2 text-sm text-slate-500 dark:text-slate-400">Quản lý số dư và theo dõi mọi giao dịch của bạn tại một nơi.</p>
        </motion.div>

        {/* Balance Card */}
        <motion.div initial={hidden} animate={visible} transition={trans(0.05)} className="relative mb-6 overflow-hidden rounded-3xl border border-slate-200 bg-slate-950 p-7 shadow-sm dark:border-slate-800 sm:p-9">
          {/* Subtle orange radial glow on the right */}
          <div className="pointer-events-none absolute -right-24 -top-24 h-72 w-72 rounded-full bg-orange-500/10 blur-3xl" />
          <div className="pointer-events-none absolute -bottom-20 left-1/3 h-40 w-40 rounded-full bg-orange-400/5 blur-3xl" />
          {/* Decorative wallet icon */}
          <div className="pointer-events-none absolute right-7 top-1/2 -translate-y-1/2 opacity-[0.07]">
            <Wallet size={96} className="text-white" />
          </div>

          <div className="relative z-10 max-w-2xl">
            <span className="inline-flex items-center gap-1.5 rounded-full border border-white/10 bg-white/5 px-2.5 py-1 text-[11px] font-semibold text-slate-300 backdrop-blur-sm">
              <ShieldCheck size={12} className="text-orange-400" />
              Được bảo vệ bởi E-Box
            </span>

            <p className="mt-7 text-[11px] font-bold uppercase tracking-[0.18em] text-slate-400">
              Số dư khả dụng
            </p>
            <h2 className="mt-2 flex items-baseline gap-1 text-[2.5rem] font-extrabold leading-none tracking-tight text-white sm:text-[2.75rem]">
              <span className="tabular-nums">
                {loading ? '...' : formatVnd(balance).replace('₫', '').trim()}
              </span>
              <span className="text-2xl font-extrabold text-orange-500">₫</span>
            </h2>
            <p className="mt-3 text-[13px] text-slate-400">
              Số dư được cập nhật ngay sau khi SePay xác nhận thanh toán.
            </p>

            <button
              type="button"
              onClick={handleOpenTopup}
              className="mt-7 inline-flex items-center justify-center gap-2 rounded-xl bg-orange-500 px-5 py-3 text-sm font-bold text-white shadow-sm shadow-orange-500/25 transition hover:-translate-y-0.5 hover:bg-orange-600 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-orange-300/50 active:translate-y-0"
            >
              <Plus size={16} strokeWidth={2.5} />
              Nạp tiền vào ví
            </button>
          </div>
        </motion.div>

        {/* Top-up Stepper panel */}
        <AnimatePresence mode="wait">
          {step !== 'idle' && (
            <motion.div
              key={step}
              initial={{ opacity: 0, y: 16 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -16 }}
              transition={{ duration: 0.35, ease: [0.22, 1, 0.36, 1] }}
              className="mb-7 overflow-hidden rounded-[28px] border border-slate-200 bg-white shadow-xl shadow-slate-200/40 dark:border-slate-800 dark:bg-slate-900 dark:shadow-black/20"
            >
              {/* Stepper header */}
              <div className="flex items-center justify-between gap-4 border-b border-slate-100 bg-slate-50/60 px-5 py-4 dark:border-slate-800 dark:bg-slate-950/40 sm:px-7">
                <div className="flex items-center gap-3">
                  <div className="flex items-center gap-2.5 text-base font-extrabold text-slate-950 dark:text-white">
                    <span className={`flex h-9 w-9 items-center justify-center rounded-xl ${
                      step === 'success'
                        ? 'bg-emerald-500/10 text-emerald-500 dark:bg-emerald-500/15'
                        : 'bg-orange-50 text-orange-500 dark:bg-orange-950/50'
                    }`}>
                      {step === 'select-amount' ? <CreditCard size={18} /> : step === 'success' ? <CheckCircle size={18} /> : <QrCode size={18} />}
                    </span>
                    <div className="flex flex-col">
                      <span>{step === 'select-amount' ? 'Chọn số tiền nạp' : step === 'success' ? 'Nạp tiền thành công' : 'Quét QR để thanh toán'}</span>
                      <span className="mt-0.5 text-[11px] font-medium text-slate-500 dark:text-slate-400">
                        {step === 'select-amount' ? 'Chọn mệnh giá hoặc nhập số tiền' : step === 'success' ? 'Giao dịch đã được xác nhận' : 'Hoàn tất giao dịch bằng ứng dụng ngân hàng'}
                      </span>
                    </div>
                  </div>
                </div>
                <div className="flex items-center gap-2 text-[11px] font-bold uppercase tracking-wider text-slate-400">
                  <span className={`flex items-center gap-1.5 ${step === 'select-amount' ? 'text-orange-500' : step === 'success' ? 'text-emerald-600 dark:text-emerald-400' : 'text-orange-500'}`}>
                    {step === 'success' ? (
                      <Check size={12} strokeWidth={3} />
                    ) : (
                      <span className={`h-1.5 w-1.5 rounded-full ${step === 'select-amount' || step === 'paying' ? 'bg-orange-500' : 'bg-slate-300 dark:bg-slate-700'}`} />
                    )}
                    Thanh toán
                  </span>
                  <span className={`h-px w-6 ${step === 'success' ? 'bg-emerald-500/40' : 'bg-slate-200 dark:bg-slate-700'}`} />
                  <span className={`flex items-center gap-1.5 ${step === 'success' ? 'text-emerald-600 dark:text-emerald-400' : ''}`}>
                    {step === 'success' ? (
                      <Check size={12} strokeWidth={3} />
                    ) : (
                      <span className={`h-1.5 w-1.5 rounded-full ${step === 'paying' ? 'bg-orange-500' : 'bg-slate-300 dark:bg-slate-700'}`} />
                    )}
                    Hoàn tất
                  </span>
                </div>
              </div>

              <div className="p-5 sm:p-7">
                <AnimatePresence mode="wait">
                  {step === 'select-amount' && (
                    <motion.form
                      key="select"
                      onSubmit={handleSubmitAmount}
                      initial={{ opacity: 0, x: -10 }}
                      animate={{ opacity: 1, x: 0 }}
                      exit={{ opacity: 0, x: -10 }}
                      transition={{ duration: 0.25 }}
                      noValidate
                    >
                      {/* Selected amount hero */}
                      <div className="mb-6">
                        <p className="text-[11px] font-bold uppercase tracking-[0.18em] text-slate-500 dark:text-slate-400">
                          Số tiền sẽ nạp
                        </p>
                        <div className="mt-2 flex items-baseline gap-1 text-slate-950 dark:text-white">
                          <span className="text-[2.25rem] font-extrabold leading-none tracking-tight tabular-nums">
                            {topupAmount ? formatVnd(Number(topupAmount)).replace('₫', '').trim() : '0'}
                          </span>
                          <span className="text-2xl font-extrabold leading-none text-orange-500">₫</span>
                        </div>
                      </div>

                      {/* Preset amounts */}
                      <p className="mb-2.5 text-[11px] font-bold uppercase tracking-[0.18em] text-slate-500 dark:text-slate-400">
                        Mức tiền phổ biến
                      </p>
                      <div className="mb-6 grid grid-cols-2 gap-2.5 sm:grid-cols-3">
                        {TOP_UP_AMOUNTS.map(amt => {
                          const selected = topupAmount === amt.toString();
                          return (
                            <button
                              key={amt}
                              type="button"
                              aria-pressed={selected}
                              onClick={() => setTopupAmount(amt.toString())}
                              className={`relative flex items-center justify-center gap-1.5 rounded-xl border px-3 py-3 text-[14px] font-bold transition ${
                                selected
                                  ? 'border-orange-500 bg-orange-500/10 text-orange-600 dark:text-orange-400'
                                  : 'border-slate-200 bg-white text-slate-700 hover:border-orange-300 hover:bg-orange-50/40 dark:border-slate-700 dark:bg-slate-950 dark:text-slate-200 dark:hover:border-orange-500/40 dark:hover:bg-orange-950/20'
                              }`}
                            >
                              {selected && (
                                <span className="flex h-4 w-4 items-center justify-center rounded-full bg-orange-500 text-white">
                                  <Check size={11} strokeWidth={3.5} />
                                </span>
                              )}
                              {formatVnd(amt)}
                            </button>
                          );
                        })}
                      </div>

                      {/* Custom amount */}
                      <p className="mb-2.5 text-[11px] font-bold uppercase tracking-[0.18em] text-slate-500 dark:text-slate-400">
                        Hoặc nhập số tiền
                      </p>
                      <div className="relative">
                        <input
                          id="topup-amount"
                          type="text"
                          inputMode="numeric"
                          autoComplete="off"
                          value={formatVndInput(topupAmount)}
                          onChange={e => setTopupAmount(normalizeVndInput(e.target.value))}
                          placeholder="Nhập số tiền"
                          className="h-14 w-full rounded-xl border border-slate-200 bg-slate-50 px-4 pr-12 text-[17px] font-bold tabular-nums text-slate-950 outline-none transition placeholder:font-normal placeholder:text-slate-400 focus:border-orange-500 focus:bg-white focus:ring-4 focus:ring-orange-100 dark:border-slate-700 dark:bg-slate-950 dark:text-white dark:focus:border-orange-500 dark:focus:ring-orange-950"
                        />
                        <span className="pointer-events-none absolute right-4 top-1/2 -translate-y-1/2 text-base font-bold text-slate-400">₫</span>
                      </div>

                      {/* Inline validation */}
                      {topupAmount && Number(topupAmount) < 10_000 && (
                        <p className="mt-2 flex items-center gap-1.5 text-xs font-medium text-red-500">
                          <AlertCircle size={13} />
                          Số tiền tối thiểu là 10.000 ₫
                        </p>
                      )}

                      {/* CTA */}
                      <button
                        type="submit"
                        disabled={processing || !topupAmount || Number(topupAmount) < 10_000}
                        className="mt-5 flex w-full items-center justify-center gap-2 rounded-xl bg-orange-500 px-5 py-3.5 text-sm font-bold text-white shadow-sm shadow-orange-500/25 transition hover:bg-orange-600 active:scale-[0.98] disabled:cursor-not-allowed disabled:bg-slate-200 disabled:text-slate-400 disabled:shadow-none dark:disabled:bg-slate-800 dark:disabled:text-slate-600"
                      >
                        {processing ? (
                          <>
                            <Loader2 size={16} className="animate-spin" />
                            Đang tạo mã thanh toán...
                          </>
                        ) : topupAmount && Number(topupAmount) >= 10_000 ? (
                          <>
                            <CreditCard size={16} />
                            Thanh toán {formatVnd(Number(topupAmount))}
                          </>
                        ) : (
                          <>
                            <CreditCard size={16} />
                            Tiếp tục thanh toán
                          </>
                        )}
                      </button>

                      {/* Hint */}
                      <div className="mt-4 flex items-start gap-2 rounded-lg bg-slate-50 p-3 dark:bg-slate-950/50">
                        <span className="mt-0.5 flex h-5 w-5 shrink-0 items-center justify-center rounded-md bg-orange-500/10 text-orange-500">
                          <Lock size={11} />
                        </span>
                        <p className="text-xs leading-relaxed text-slate-500 dark:text-slate-400">
                          QR VietQR sẽ được tạo ở bước tiếp theo. Bạn có thể quét bằng hầu hết ứng dụng ngân hàng Việt Nam.
                        </p>
                      </div>
                    </motion.form>
                  )}

                  {step === 'paying' && payment && (
                    <motion.div
                      key="paying"
                      initial={{ opacity: 0, x: 10 }}
                      animate={{ opacity: 1, x: 0 }}
                      exit={{ opacity: 0, x: 10 }}
                      transition={{ duration: 0.25 }}
                      className="grid grid-cols-1 gap-6 lg:grid-cols-12 lg:gap-8"
                    >
                      {resumePendingNonce > 0 && (
                        <InlineAlert
                          variant="warning"
                          title="Bạn đang có giao dịch chưa hoàn tất"
                          description="Hoàn thành giao dịch hiện tại trước khi tạo giao dịch mới. Quét QR bên dưới để tiếp tục thanh toán."
                          className="mb-2 lg:col-span-12"
                          shakeKey={resumePendingNonce}
                        />
                      )}
                      {/* LEFT — instructions + amount + bank info */}
                      <div className="order-2 space-y-5 lg:order-1 lg:col-span-7">
                        {/* Amount — hero of left column */}
                        <div>
                          <p className="text-[11px] font-bold uppercase tracking-[0.18em] text-slate-500 dark:text-slate-400">
                            Số tiền cần thanh toán
                          </p>
                          <p className="mt-2 flex items-baseline gap-1 text-[2.25rem] font-extrabold leading-none tracking-tight text-slate-950 tabular-nums dark:text-white">
                            <span className="text-3xl font-extrabold text-orange-500">₫</span>
                            <span>{formatVnd(payment.amount).replace('₫', '').trim()}</span>
                          </p>
                        </div>

                        {/* Instructions */}
                        <div className="rounded-2xl border border-slate-200 bg-slate-50/60 p-5 dark:border-slate-800 dark:bg-slate-950/40">
                          <p className="mb-3 text-xs font-bold uppercase tracking-wider text-slate-500 dark:text-slate-400">
                            Hướng dẫn thanh toán
                          </p>
                          <ol className="space-y-2.5 text-sm leading-relaxed text-slate-700 dark:text-slate-200">
                            <li className="flex gap-3">
                              <span className="flex h-5 w-5 shrink-0 items-center justify-center rounded-full bg-slate-900 text-[10px] font-bold text-white dark:bg-slate-700">1</span>
                              <span>Mở ứng dụng ngân hàng hoặc ví điện tử hỗ trợ <span className="font-semibold text-slate-900 dark:text-white">VietQR</span>.</span>
                            </li>
                            <li className="flex gap-3">
                              <span className="flex h-5 w-5 shrink-0 items-center justify-center rounded-full bg-slate-900 text-[10px] font-bold text-white dark:bg-slate-700">2</span>
                              <span>Quét mã QR hoặc nhập chính xác <span className="font-semibold text-slate-900 dark:text-white">nội dung</span> chuyển khoản.</span>
                            </li>
                            <li className="flex gap-3">
                              <span className="flex h-5 w-5 shrink-0 items-center justify-center rounded-full bg-slate-900 text-[10px] font-bold text-white dark:bg-slate-700">3</span>
                              <span>Hoàn tất thanh toán, hệ thống sẽ tự động xác nhận giao dịch.</span>
                            </li>
                          </ol>
                        </div>

                        {/* Transfer content */}
                        <div>
                          <div className="mb-2 flex items-center justify-between">
                            <p className="text-[11px] font-bold uppercase tracking-[0.18em] text-slate-500 dark:text-slate-400">
                              Nội dung chuyển khoản
                            </p>
                          </div>
                          <div className="flex items-center gap-2 rounded-xl border border-orange-500/30 bg-orange-500/5 p-2 pl-4 dark:bg-orange-500/10">
                            <span className="min-w-0 flex-1 truncate font-mono text-sm font-bold tracking-wide text-slate-900 dark:text-white">
                              {payment.sepayCode}
                            </span>
                            <button
                              type="button"
                              onClick={handleCopy}
                              className="inline-flex shrink-0 items-center gap-1.5 rounded-lg bg-white px-3 py-2 text-xs font-bold text-slate-700 shadow-sm ring-1 ring-slate-200 transition hover:bg-slate-50 active:scale-[0.97] dark:bg-slate-800 dark:text-slate-100 dark:ring-slate-700 dark:hover:bg-slate-700"
                            >
                              {copied ? (
                                <>
                                  <Check size={13} className="text-emerald-500" />
                                  Đã sao chép
                                </>
                              ) : (
                                <>
                                  <Copy size={13} />
                                  Sao chép
                                </>
                              )}
                            </button>
                          </div>
                          <p className="mt-2 text-xs leading-relaxed text-slate-500 dark:text-slate-400">
                            Vui lòng giữ nguyên nội dung chuyển khoản để giao dịch được xác nhận tự động.
                          </p>
                        </div>

                        {/* Receiver info */}
                        <div className="overflow-hidden rounded-2xl border border-slate-200 bg-white dark:border-slate-800 dark:bg-slate-900">
                          <div className="border-b border-slate-100 px-4 py-3 dark:border-slate-800">
                            <p className="text-[11px] font-bold uppercase tracking-[0.18em] text-slate-500 dark:text-slate-400">
                              Thông tin người nhận
                            </p>
                          </div>
                          <dl className="divide-y divide-slate-100 text-sm dark:divide-slate-800">
                            <div className="flex items-center justify-between gap-3 px-4 py-3">
                              <dt className="text-slate-500 dark:text-slate-400">Ngân hàng</dt>
                              <dd className="flex items-center gap-1.5 font-bold text-slate-900 dark:text-white">
                                <Building2 size={14} className="text-orange-500" />
                                TPBank
                              </dd>
                            </div>
                            <div className="flex items-center justify-between gap-3 px-4 py-3">
                              <dt className="text-slate-500 dark:text-slate-400">Số tài khoản</dt>
                              <dd className="flex items-center gap-1.5">
                                <span className="font-mono font-bold tabular-nums text-slate-900 dark:text-white">84519828888</span>
                                <button
                                  type="button"
                                  onClick={() => { void navigator.clipboard?.writeText('84519828888'); }}
                                  className="rounded p-1 text-slate-400 transition hover:bg-slate-100 hover:text-slate-700 dark:hover:bg-slate-800"
                                  aria-label="Sao chép số tài khoản"
                                >
                                  <Copy size={13} />
                                </button>
                              </dd>
                            </div>
                            <div className="flex items-center justify-between gap-3 px-4 py-3">
                              <dt className="text-slate-500 dark:text-slate-400">Chủ tài khoản</dt>
                              <dd className="font-bold uppercase text-slate-900 dark:text-white">PHAM DUC HUNG</dd>
                            </div>
                            <div className="flex items-center justify-between gap-3 px-4 py-3">
                              <dt className="text-slate-500 dark:text-slate-400">Số tiền</dt>
                              <dd className="font-extrabold text-orange-500 tabular-nums">{formatVnd(payment.amount)}</dd>
                            </div>
                          </dl>
                        </div>
                      </div>

                      {/* RIGHT — Premium dark QR card */}
                      <div className="order-1 lg:order-2 lg:col-span-5">
                        <div className="sticky top-4 overflow-hidden rounded-2xl border border-slate-200 bg-slate-50 dark:border-slate-800 dark:bg-slate-950">
                          {/* Header */}
                          <div className="flex items-center justify-between border-b border-slate-200 px-5 py-4 dark:border-slate-800">
                            <div className="flex items-center gap-2.5">
                              <span className="flex h-8 w-8 items-center justify-center rounded-lg bg-orange-500/10 text-orange-500">
                                <QrCode size={16} />
                              </span>
                              <div>
                                <p className="text-sm font-bold text-slate-900 dark:text-white">Quét mã VietQR</p>
                                <p className="text-[11px] font-medium text-slate-500 dark:text-slate-400">Dùng app ngân hàng của bạn</p>
                              </div>
                            </div>
                            <StatusBadge status={isCompleted ? 'completed' : isFailed ? 'failed' : expired ? 'expired' : 'pending'} />
                          </div>

                          {/* QR Code */}
                          <div className="px-5 pt-5">
                            <div className="relative mx-auto max-w-[260px]">
                              <div className="rounded-xl bg-white p-4 shadow-lg shadow-slate-900/5 ring-1 ring-slate-200 dark:ring-slate-800">
                                <img
                                  src={payment.paymentUrl}
                                  alt="QR nạp tiền"
                                  className="block h-56 w-56 max-w-full object-contain"
                                  onError={(e) => { (e.target as HTMLImageElement).style.display = 'none'; }}
                                />
                              </div>
                              {/* Subtle corner accents */}
                              <span className="absolute -left-1 -top-1 h-3 w-3 border-l-2 border-t-2 border-orange-500" />
                              <span className="absolute -right-1 -top-1 h-3 w-3 border-r-2 border-t-2 border-orange-500" />
                              <span className="absolute -bottom-1 -left-1 h-3 w-3 border-b-2 border-l-2 border-orange-500" />
                              <span className="absolute -bottom-1 -right-1 h-3 w-3 border-b-2 border-r-2 border-orange-500" />
                            </div>
                          </div>

                          {/* Countdown */}
                          <div className="px-5 pt-5">
                            {expired || isCompleted || isFailed ? (
                              <div className="flex items-center justify-between rounded-xl bg-slate-100 px-4 py-3 dark:bg-slate-900">
                                <span className="text-xs font-bold uppercase tracking-wider text-slate-500 dark:text-slate-400">
                                  {isCompleted ? 'Mã đã hoàn tất' : 'Mã QR đã hết hạn'}
                                </span>
                                {expired && (
                                  <button
                                    type="button"
                                    onClick={handleCreateNew}
                                    className="inline-flex items-center gap-1 rounded-md bg-orange-500 px-2.5 py-1 text-xs font-bold text-white transition hover:bg-orange-600 active:scale-[0.97]"
                                  >
                                    <RotateCcw size={12} /> Tạo mã mới
                                  </button>
                                )}
                              </div>
                            ) : (
                              <div className="flex items-center justify-between rounded-xl bg-slate-100 px-4 py-3 dark:bg-slate-900">
                                <span className="text-xs font-bold uppercase tracking-wider text-slate-500 dark:text-slate-400">
                                  Mã QR hết hạn sau
                                </span>
                                <span className={`font-mono text-xl font-extrabold tabular-nums ${secondsLeft < 120 ? 'text-red-500' : 'text-slate-900 dark:text-white'}`}>
                                  {formatCountdown(secondsLeft)}
                                </span>
                              </div>
                            )}
                          </div>

                          {/* Status block */}
                          <div className="p-5">
                            {isCompleted ? (
                              <div className="rounded-xl border border-emerald-500/30 bg-emerald-500/5 p-4">
                                <div className="flex items-center gap-2.5">
                                  <span className="flex h-7 w-7 items-center justify-center rounded-full bg-emerald-500 text-white">
                                    <Check size={14} strokeWidth={3} />
                                  </span>
                                  <p className="text-sm font-bold text-emerald-600 dark:text-emerald-400">
                                    Thanh toán thành công
                                  </p>
                                </div>
                                <p className="mt-1.5 text-xs leading-relaxed text-emerald-700/80 dark:text-emerald-400/80">
                                  Giao dịch đã được xác nhận tự động.
                                </p>
                              </div>
                            ) : isFailed ? (
                              <div className="rounded-xl border border-red-500/30 bg-red-500/5 p-4">
                                <div className="flex items-center gap-2.5">
                                  <span className="flex h-7 w-7 items-center justify-center rounded-full bg-red-500 text-white">
                                    <XCircle size={14} strokeWidth={2.5} />
                                  </span>
                                  <p className="text-sm font-bold text-red-600 dark:text-red-400">
                                    Không thể xác nhận thanh toán
                                  </p>
                                </div>
                                <p className="mt-1.5 text-xs leading-relaxed text-red-700/80 dark:text-red-400/80">
                                  Giao dịch chưa được hoàn tất. Vui lòng kiểm tra lại hoặc thử lại.
                                </p>
                                <button
                                  type="button"
                                  onClick={handleCreateNew}
                                  className="mt-3 inline-flex items-center gap-1.5 rounded-lg bg-red-500 px-3 py-1.5 text-xs font-bold text-white transition hover:bg-red-600 active:scale-[0.97]"
                                >
                                  <RotateCcw size={12} /> Thử lại
                                </button>
                              </div>
                            ) : (
                              <div className="rounded-xl border border-slate-200 bg-white p-4 dark:border-slate-800 dark:bg-slate-900">
                                <div className="flex items-center gap-2.5">
                                  <span className="relative flex h-7 w-7 items-center justify-center">
                                    <span className="absolute inset-0 animate-ping rounded-full bg-amber-500/30" />
                                    <span className="relative flex h-7 w-7 items-center justify-center rounded-full bg-amber-500/15 text-amber-600 dark:text-amber-400">
                                      <Loader2 size={14} className="animate-spin" />
                                    </span>
                                  </span>
                                  <p className="text-sm font-bold text-slate-900 dark:text-white">
                                    Đang chờ thanh toán
                                  </p>
                                </div>
                                <p className="mt-1.5 text-xs leading-relaxed text-slate-500 dark:text-slate-400">
                                  Hệ thống sẽ tự động xác nhận sau khi nhận được giao dịch.
                                </p>
                              </div>
                            )}
                          </div>

                          {/* Action button — Cancel */}
                          <div className="border-t border-slate-200 p-5 pt-4 dark:border-slate-800">
                            <button
                              type="button"
                              onClick={() => setShowCancelConfirm(true)}
                              disabled={cancelling || isCancelled || isCompleted || isFailed || expired}
                              className="w-full rounded-xl border border-red-200 bg-white px-4 py-2.5 text-sm font-semibold text-red-600 transition hover:border-red-300 hover:bg-red-50 active:scale-[0.98] disabled:cursor-not-allowed disabled:opacity-50 dark:border-red-900/50 dark:bg-slate-900 dark:text-red-400 dark:hover:bg-red-950/30"
                            >
                              Huỷ thanh toán
                            </button>
                            <p className="mt-2.5 text-center text-[11px] leading-relaxed text-slate-400 dark:text-slate-500">
                              Sau khi huỷ, nếu bạn đã chuyển khoản vui lòng liên hệ hỗ trợ để được hoàn tiền.
                            </p>
                          </div>
                        </div>
                      </div>
                    </motion.div>
                  )}

                  {step === 'success' && payment && (
                    <motion.div
                      key="success"
                      initial={{ opacity: 0, y: 8 }}
                      animate={{ opacity: 1, y: 0 }}
                      exit={{ opacity: 0, y: -4 }}
                      transition={{ duration: 0.3, ease: 'easeOut' }}
                      className="mx-auto max-w-xl"
                    >
                      {/* Success hero — light center */}
                      <div className="flex flex-col items-center pt-6 pb-7 text-center">
                        <motion.div
                          initial={{ scale: 0.85, opacity: 0 }}
                          animate={{ scale: 1, opacity: 1 }}
                          transition={{ duration: 0.32, ease: 'easeOut' }}
                          className="relative flex h-16 w-16 items-center justify-center"
                        >
                          {/* subtle glow */}
                          <span className="absolute inset-0 rounded-full bg-emerald-500/15 blur-2xl" />
                          {/* ring */}
                          <span className="absolute inset-0 rounded-full ring-1 ring-emerald-500/20" />
                          <span className="absolute inset-2 rounded-full bg-emerald-500/10" />
                          {/* check icon */}
                          <motion.span
                            initial={{ scale: 0.5, opacity: 0 }}
                            animate={{ scale: 1, opacity: 1 }}
                            transition={{ delay: 0.1, type: 'spring', stiffness: 260, damping: 20 }}
                            className="relative flex h-12 w-12 items-center justify-center rounded-full bg-emerald-500 text-white shadow-lg shadow-emerald-500/30"
                          >
                            <Check size={26} strokeWidth={3} />
                          </motion.span>
                        </motion.div>

                        <motion.h3
                          initial={{ opacity: 0, y: 4 }}
                          animate={{ opacity: 1, y: 0 }}
                          transition={{ delay: 0.15 }}
                          className="mt-5 text-[22px] font-bold tracking-tight text-slate-950 dark:text-white"
                        >
                          Nạp tiền thành công
                        </motion.h3>
                        <motion.p
                          initial={{ opacity: 0 }}
                          animate={{ opacity: 1 }}
                          transition={{ delay: 0.22 }}
                          className="mt-1.5 text-sm text-slate-500 dark:text-slate-400"
                        >
                          Giao dịch đã được xác nhận và cộng vào ví của bạn.
                        </motion.p>

                        {/* Amount */}
                        <motion.div
                          initial={{ opacity: 0, y: 4 }}
                          animate={{ opacity: 1, y: 0 }}
                          transition={{ delay: 0.28 }}
                          className="mt-7"
                        >
                          <p className="text-[11px] font-bold uppercase tracking-[0.18em] text-slate-500 dark:text-slate-400">
                            Số tiền đã nạp
                          </p>
                          <div className="mt-2 flex items-baseline justify-center gap-1 text-slate-950 dark:text-white">
                            <span className="text-3xl font-extrabold leading-none text-emerald-500">+</span>
                            <span className="text-[2.5rem] font-extrabold leading-none tracking-tight tabular-nums">
                              {formatVnd(payment.amount).replace('₫', '').trim()}
                            </span>
                            <span className="text-2xl font-extrabold leading-none text-orange-500">₫</span>
                          </div>
                          <p className="mt-2 text-[13px] text-slate-500 dark:text-slate-400">
                            Hoàn tất lúc <span className="font-medium text-slate-700 dark:text-slate-300">{formatSuccessTimestamp(paymentStatus?.paidAt)}</span>
                          </p>
                        </motion.div>
                      </div>

                      {/* Detail card */}
                      <motion.div
                        initial={{ opacity: 0, y: 6 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ delay: 0.34 }}
                        className="overflow-hidden rounded-2xl border border-slate-200 bg-white dark:border-slate-800 dark:bg-slate-900"
                      >
                        <div className="border-b border-slate-100 px-5 py-3 dark:border-slate-800">
                          <p className="text-[11px] font-bold uppercase tracking-[0.18em] text-slate-500 dark:text-slate-400">
                            Chi tiết giao dịch
                          </p>
                        </div>
                        <dl className="divide-y divide-slate-100 text-sm dark:divide-slate-800">
                          <div className="flex items-center justify-between gap-3 px-5 py-3.5">
                            <dt className="text-slate-500 dark:text-slate-400">Mã giao dịch</dt>
                            <dd className="flex min-w-0 items-center gap-1.5">
                              <span className="truncate rounded-md bg-slate-100 px-2 py-1 font-mono text-xs font-semibold text-slate-700 dark:bg-slate-800 dark:text-slate-200">
                                {payment.sepayCode}
                              </span>
                              <button
                                type="button"
                                onClick={handleCopy}
                                className="inline-flex shrink-0 items-center gap-1 rounded-md bg-white px-2 py-1 text-[11px] font-bold text-slate-600 shadow-sm ring-1 ring-slate-200 transition hover:bg-slate-50 active:scale-[0.97] dark:bg-slate-900 dark:text-slate-300 dark:ring-slate-700 dark:hover:bg-slate-800"
                                aria-label="Sao chép mã giao dịch"
                              >
                                {copied ? (
                                  <>
                                    <Check size={11} className="text-emerald-500" />
                                    Đã sao chép
                                  </>
                                ) : (
                                  <>
                                    <Copy size={11} />
                                    Sao chép
                                  </>
                                )}
                              </button>
                            </dd>
                          </div>
                          <div className="flex items-center justify-between gap-3 px-5 py-3.5">
                            <dt className="text-slate-500 dark:text-slate-400">Phương thức</dt>
                            <dd className="flex items-center gap-1.5 font-semibold text-slate-900 dark:text-white">
                              <QrCode size={13} className="text-orange-500" />
                              VietQR · TPBank
                            </dd>
                          </div>
                          <div className="flex items-center justify-between gap-3 px-5 py-3.5">
                            <dt className="text-slate-500 dark:text-slate-400">Người nhận</dt>
                            <dd className="font-semibold uppercase tracking-wide text-slate-900 dark:text-white">PHAM DUC HUNG</dd>
                          </div>
                          <div className="flex items-center justify-between gap-3 px-5 py-3.5">
                            <dt className="text-slate-500 dark:text-slate-400">Trạng thái</dt>
                            <dd>
                              <span className="inline-flex items-center gap-1.5 rounded-full bg-emerald-500/10 px-2.5 py-1 text-[11px] font-bold uppercase tracking-wider text-emerald-600 ring-1 ring-emerald-500/20 dark:text-emerald-400">
                                <span className="h-1.5 w-1.5 rounded-full bg-emerald-500" />
                                Hoàn thành
                              </span>
                            </dd>
                          </div>
                        </dl>
                      </motion.div>

                      {/* Action buttons */}
                      <div className="mt-6 flex flex-col gap-2.5 sm:flex-row">
                        <button
                          type="button"
                          onClick={handleCreateNew}
                          className="group flex flex-[1.1] items-center justify-center gap-2 rounded-xl bg-orange-500 px-5 py-3 text-sm font-bold text-white shadow-sm shadow-orange-500/25 transition hover:bg-orange-600 active:scale-[0.98]"
                        >
                          <Plus size={16} strokeWidth={2.5} />
                          Nạp thêm
                        </button>
                        <button
                          type="button"
                          onClick={handleCloseTopup}
                          className="flex-1 rounded-xl border border-slate-200 bg-white px-5 py-3 text-sm font-semibold text-slate-700 transition hover:border-slate-300 hover:bg-slate-50 active:scale-[0.98] dark:border-slate-700 dark:bg-slate-900 dark:text-slate-200 dark:hover:bg-slate-800"
                        >
                          Đóng
                        </button>
                      </div>
                    </motion.div>
                  )}
                </AnimatePresence>
              </div>
            </motion.div>
          )}
        </AnimatePresence>

        {/* Transactions */}
        <motion.div initial={hidden} animate={visible} transition={trans(0.1)} className="rounded-[28px] border border-slate-200 bg-white p-5 shadow-sm sm:p-7 dark:border-slate-800 dark:bg-slate-900">
          <div className="mb-5 flex items-center justify-between gap-3">
            <div>
              <h3 className="text-lg font-extrabold text-slate-950 dark:text-white">Lịch sử giao dịch</h3>
              <p className="mt-1 text-xs text-slate-400">Các giao dịch gần đây của ví</p>
            </div>
            {!loading && <span className="rounded-full bg-slate-100 px-3 py-1 text-xs font-bold text-slate-500 dark:bg-slate-800 dark:text-slate-300">{filteredTransactions.length} giao dịch</span>}
          </div>

          {/* Status filter tabs */}
          <div className="mb-4 flex flex-wrap items-center gap-1.5">
            {TRANSACTION_STATUS_FILTERS.map((f) => {
              const isActive = statusFilter === f.value;
              return (
                <button
                  key={f.value}
                  type="button"
                  onClick={() => setStatusFilter(f.value)}
                  className={`rounded-full px-3 py-1.5 text-xs font-semibold transition ${
                    isActive
                      ? 'bg-orange-500 text-white shadow-sm'
                      : 'bg-slate-100 text-slate-600 hover:bg-slate-200 dark:bg-slate-800 dark:text-slate-300 dark:hover:bg-slate-700'
                  }`}
                >
                  {f.label}
                </button>
              );
            })}
          </div>

          {loading ? (
            <div className="space-y-3">{[...Array(4)].map((_, i) => <div key={i} className="h-16 animate-pulse rounded-2xl bg-slate-100 dark:bg-slate-800" />)}</div>
          ) : filteredTransactions.length === 0 ? (
            <div className="rounded-2xl border border-dashed border-slate-300 py-12 text-center dark:border-slate-700">
              <Clock size={26} className="mx-auto mb-2 text-slate-300 dark:text-slate-600" />
              <p className="text-sm text-slate-400">
                {statusFilter === 'all'
                  ? 'Chưa có giao dịch nào.'
                  : `Không có giao dịch "${TRANSACTION_STATUS_FILTERS.find((f) => f.value === statusFilter)?.label}".`}
              </p>
            </div>
          ) : (
            <div className="divide-y divide-slate-100 dark:divide-slate-800">
              {filteredTransactions.map(tx => (
                <div key={tx.id} className="flex items-center justify-between gap-3 py-4 first:pt-0 last:pb-0">
                  <div className="flex min-w-0 items-center gap-3">
                    <div className={`flex h-11 w-11 shrink-0 items-center justify-center rounded-2xl ${getStatusBgClass(String(tx.status))}`}>
                      {getIcon(String(tx.type), tx.amount)}
                    </div>
                    <div className="min-w-0">
                      <p className="truncate font-semibold text-slate-900 dark:text-slate-100">{tx.description ?? getTransactionTypeLabel(tx.type)}</p>
                      <p className="mt-0.5 text-xs text-slate-400">{new Date(tx.createdAt).toLocaleString('vi-VN')}</p>
                    </div>
                  </div>
                  <div className="shrink-0 text-right">
                    <p className={`font-extrabold ${getStatusAmountClass(String(tx.status), tx.amount)}`}>
                      {tx.amount > 0 ? '+' : ''}{formatVnd(tx.amount)}
                    </p>
                    <span className={`text-[10px] font-semibold uppercase tracking-wide ${getStatusLabelClass(String(tx.status))}`}>{getTransactionStatusLabel(tx.status)}</span>
                  </div>
                </div>
              ))}
            </div>
          )}
        </motion.div>

        {/* Cancel payment confirmation modal */}
        <AnimatePresence>
          {showCancelConfirm && (
            <motion.div
              key="cancel-confirm-overlay"
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              transition={{ duration: 0.18 }}
              className="fixed inset-0 z-[60] flex items-center justify-center bg-slate-950/60 px-4 backdrop-blur-sm"
              onClick={() => !cancelling && setShowCancelConfirm(false)}
            >
              <motion.div
                initial={{ opacity: 0, scale: 0.95, y: 8 }}
                animate={{ opacity: 1, scale: 1, y: 0 }}
                exit={{ opacity: 0, scale: 0.95, y: 8 }}
                transition={{ duration: 0.2, ease: 'easeOut' }}
                onClick={(e) => e.stopPropagation()}
                className="w-full max-w-sm overflow-hidden rounded-2xl bg-white shadow-2xl shadow-slate-950/30 dark:bg-slate-900"
              >
                <div className="p-6">
                  <div className="flex items-start gap-3.5">
                    <span className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-red-500/10 text-red-500">
                      <AlertCircle size={20} strokeWidth={2.25} />
                    </span>
                    <div className="min-w-0 flex-1">
                      <h3 className="text-base font-bold text-slate-900 dark:text-white">
                        Huỷ thanh toán này?
                      </h3>
                      <p className="mt-1.5 text-sm leading-relaxed text-slate-600 dark:text-slate-400">
                        Nếu bạn đã chuyển khoản, vui lòng liên hệ hỗ trợ để được hoàn tiền. Hệ thống không tự hoàn tiền tự động.
                      </p>
                    </div>
                  </div>
                </div>
                <div className="flex gap-2 border-t border-slate-200 bg-slate-50 px-6 py-4 dark:border-slate-800 dark:bg-slate-950/50">
                  <button
                    type="button"
                    onClick={() => setShowCancelConfirm(false)}
                    disabled={cancelling}
                    className="flex-1 rounded-xl border border-slate-200 bg-white px-4 py-2.5 text-sm font-semibold text-slate-700 transition hover:border-slate-300 hover:bg-slate-50 active:scale-[0.98] disabled:cursor-not-allowed disabled:opacity-50 dark:border-slate-700 dark:bg-slate-800 dark:text-slate-200 dark:hover:bg-slate-700"
                  >
                    Tiếp tục thanh toán
                  </button>
                  <button
                    type="button"
                    onClick={() => { void handleCancelTopup(); }}
                    disabled={cancelling}
                    className="flex-1 rounded-xl bg-red-500 px-4 py-2.5 text-sm font-bold text-white shadow-sm shadow-red-500/25 transition hover:bg-red-600 active:scale-[0.98] disabled:cursor-not-allowed disabled:opacity-60"
                  >
                    {cancelling ? (
                      <span className="inline-flex items-center justify-center gap-2">
                        <Loader2 size={14} className="animate-spin" /> Đang huỷ...
                      </span>
                    ) : (
                      'Vẫn huỷ'
                    )}
                  </button>
                </div>
              </motion.div>
            </motion.div>
          )}
        </AnimatePresence>
      </main>
    </div>
  );
}
