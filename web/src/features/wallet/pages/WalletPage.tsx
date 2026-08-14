import { useState, useEffect, useRef, useCallback } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import {
  Wallet, Plus, ArrowUpRight, ArrowDownLeft, ShieldCheck, Clock, CreditCard, Sparkles,
  QrCode, Copy, CheckCircle, XCircle, Building2, Hash, ChevronLeft, Loader2,
} from 'lucide-react';
import type { HubConnection } from '@microsoft/signalr';
import AppHeader from '../../../components/layout/AppHeader';
import { hidden, visible, trans } from '../../../lib/animations';
import { apiFetch } from '../../../lib/api';
import { useToast } from '../../../context/ToastContext';
import { formatVnd, formatVndInput, normalizeVndInput } from '../utils/currency';
import { createPaymentRealtimeConnection } from '../api/paymentRealtime';

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
const TRANSACTION_STATUS_LABELS = ['Đang xử lý', 'Hoàn thành', 'Thất bại'];
const TOP_UP_AMOUNTS = [50_000, 100_000, 200_000, 500_000, 1_000_000, 2_000_000];
const POLL_INTERVAL_MS = 3000;
const PAYMENT_STORAGE_KEY = 'locker:pending-topup';

type TopupStep = 'idle' | 'select-amount' | 'paying';

export default function WalletPage() {
  const { show: showToast } = useToast();
  const [balance, setBalance] = useState(0);
  const [transactions, setTransactions] = useState<WalletTransaction[]>([]);
  const [loading, setLoading] = useState(true);

  const [step, setStep] = useState<TopupStep>('idle');
  const [topupAmount, setTopupAmount] = useState('100000');
  const [processing, setProcessing] = useState(false);

  const [payment, setPayment] = useState<SepayInitResponse | null>(null);
  const [paymentStatus, setPaymentStatus] = useState<PaymentStatus | null>(null);
  const [secondsLeft, setSecondsLeft] = useState(0);
  const [copied, setCopied] = useState(false);

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
          String(payload.status).toLowerCase() === 'completed' ? 1 :
          String(payload.status).toLowerCase() === 'failed' ? 2 : 0;
        setPaymentStatus({
          id: payload.paymentId,
          amount: payload.amount,
          status: numericStatus,
          paidAt: payload.paidAt ?? null,
        });
        if (numericStatus === 1) {
          stopPolling();
          showToast('Nạp tiền thành công!', 'success');
          void loadWallet();
          setTimeout(() => handleCloseTopup(), 1500);
        } else if (numericStatus === 2) {
          stopPolling();
          showToast('Thanh toán thất bại.', 'error');
        }
      },
    });
    realtimeRef.current = conn;
    try {
      await conn.start();
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
    setStep('select-amount');
    setPayment(null);
    setPaymentStatus(null);
  };

  const handleCloseTopup = () => {
    stopPolling();
    setStep('idle');
    setPayment(null);
    setPaymentStatus(null);
    setProcessing(false);
    persistPendingPayment(null);
    void closeRealtime();
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
          showToast('Nạp tiền thành công!', 'success');
          await loadWallet();
          setTimeout(() => handleCloseTopup(), 1500);
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
    return status;
  };

  const expired = secondsLeft <= 0 && step === 'paying';
  const statusValue = typeof paymentStatus?.status === 'number' ? paymentStatus.status : -1;
  const isCompleted = statusValue === 1;
  const isFailed = statusValue === 2;

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
        <motion.div initial={hidden} animate={visible} transition={trans(0.05)} className="relative mb-7 overflow-hidden rounded-[30px] bg-gradient-to-br from-slate-950 via-slate-900 to-orange-950 p-6 shadow-2xl shadow-slate-900/20 sm:p-9 dark:border dark:border-slate-800">
          <div className="absolute -right-16 -top-20 h-64 w-64 rounded-full bg-orange-500/20 blur-3xl" />
          <div className="absolute -bottom-24 left-1/3 h-48 w-48 rounded-full bg-amber-400/10 blur-3xl" />
          <div className="absolute right-5 top-5 opacity-[0.08]">
            <Wallet size={150} className="text-white" />
          </div>
          <div className="relative z-10">
            <span className="inline-flex items-center gap-2 rounded-full border border-white/10 bg-white/10 px-3 py-1.5 text-xs font-semibold text-white backdrop-blur-md">
              <ShieldCheck size={14} className="text-orange-400" /> Được bảo vệ bởi E-Box
            </span>
            <p className="mt-8 text-sm font-medium text-slate-400">Số dư khả dụng</p>
            <h2 className="mt-2 text-4xl font-extrabold tracking-[-0.03em] text-white sm:text-5xl">
              {loading ? '...' : formatVnd(balance)}
            </h2>
            <p className="mt-2 text-xs text-slate-400">Số dư được cập nhật sau khi SePay xác nhận thanh toán.</p>
            <button
              type="button"
              onClick={handleOpenTopup}
              className="mt-8 flex w-full items-center justify-center gap-2 rounded-2xl bg-orange-500 px-5 py-3.5 text-sm font-bold text-white shadow-lg shadow-orange-950/30 transition hover:-translate-y-0.5 hover:bg-orange-600 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-orange-300 sm:w-auto sm:min-w-52"
            >
              <Plus size={18} /> Nạp tiền vào ví
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
                  {step === 'paying' && (
                    <button type="button" onClick={handleCreateNew} aria-label="Quay lại" className="rounded-xl p-2 text-slate-500 transition hover:bg-slate-100 hover:text-slate-900 dark:text-slate-400 dark:hover:bg-slate-800 dark:hover:text-white">
                      <ChevronLeft size={18} />
                    </button>
                  )}
                  <div className="flex items-center gap-2 text-base font-extrabold text-slate-950 dark:text-white">
                    <span className="flex h-9 w-9 items-center justify-center rounded-xl bg-orange-50 text-orange-500 dark:bg-orange-950/50">
                      {step === 'select-amount' ? <CreditCard size={18} /> : <QrCode size={18} />}
                    </span>
                    {step === 'select-amount' ? 'Chọn số tiền nạp' : 'Quét QR để thanh toán'}
                  </div>
                </div>
                <div className="flex items-center gap-2">
                  <span className={`flex h-7 w-7 items-center justify-center rounded-full text-xs font-bold ${step !== 'select-amount' ? 'bg-orange-500 text-white' : 'bg-slate-200 text-slate-500 dark:bg-slate-800 dark:text-slate-300'}`}>1</span>
                  <span className="text-xs font-semibold text-slate-400">›</span>
                  <span className={`flex h-7 w-7 items-center justify-center rounded-full text-xs font-bold ${step === 'paying' ? 'bg-orange-500 text-white' : 'bg-slate-200 text-slate-500 dark:bg-slate-800 dark:text-slate-300'}`}>2</span>
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
                    >
                      <p className="mb-2 text-xs font-bold uppercase tracking-wider text-slate-500 dark:text-slate-400">Mức tiền phổ biến</p>
                      <div className="mb-5 grid grid-cols-2 gap-2.5 sm:grid-cols-3">
                        {TOP_UP_AMOUNTS.map(amt => (
                          <button
                            key={amt}
                            type="button"
                            aria-pressed={topupAmount === amt.toString()}
                            onClick={() => setTopupAmount(amt.toString())}
                            className={`rounded-2xl border px-3 py-3 text-sm font-bold transition ${topupAmount === amt.toString() ? 'border-orange-500 bg-orange-50 text-orange-600 shadow-sm ring-2 ring-orange-100 dark:bg-orange-950/40 dark:text-orange-400 dark:ring-orange-950' : 'border-slate-200 bg-white text-slate-700 hover:border-orange-300 hover:bg-orange-50/50 dark:border-slate-700 dark:bg-slate-950 dark:text-slate-200 dark:hover:border-orange-500/60 dark:hover:bg-orange-950/30'}`}
                          >
                            {formatVnd(amt)}
                          </button>
                        ))}
                      </div>
                      <label htmlFor="topup-amount" className="mb-2 block text-xs font-bold uppercase tracking-wider text-slate-500 dark:text-slate-400">Hoặc nhập số tiền</label>
                      <div className="flex flex-col gap-3 sm:flex-row">
                        <div className="relative min-w-0 flex-1">
                          <input
                            id="topup-amount"
                            type="text"
                            inputMode="numeric"
                            autoComplete="off"
                            value={formatVndInput(topupAmount)}
                            onChange={e => setTopupAmount(normalizeVndInput(e.target.value))}
                            placeholder="Nhập số tiền"
                            className="h-13 w-full rounded-2xl border border-slate-200 bg-slate-50 px-4 pr-12 py-3.5 text-base font-bold text-slate-950 outline-none transition placeholder:font-normal placeholder:text-slate-400 focus:border-orange-500 focus:bg-white focus:ring-4 focus:ring-orange-100 dark:border-slate-700 dark:bg-slate-950 dark:text-white dark:focus:border-orange-500 dark:focus:ring-orange-950"
                          />
                          <span className="pointer-events-none absolute right-4 top-1/2 -translate-y-1/2 text-sm font-bold text-slate-500">₫</span>
                        </div>
                        <button
                          type="submit"
                          disabled={processing || !topupAmount}
                          className="flex min-w-40 items-center justify-center gap-2 rounded-2xl bg-slate-950 px-6 py-3.5 text-sm font-bold text-white transition hover:bg-orange-500 disabled:cursor-not-allowed disabled:opacity-50 dark:bg-orange-500 dark:hover:bg-orange-600"
                        >
                          {processing ? <><Loader2 size={16} className="animate-spin" /> Đang tạo QR...</> : 'Tạo mã QR'}
                        </button>
                      </div>
                      <p className="mt-3 text-xs leading-5 text-slate-400">Hệ thống sẽ tạo mã QR VietQR động — quét bằng app ngân hàng để hoàn tất.</p>
                    </motion.form>
                  )}

                  {step === 'paying' && payment && (
                    <motion.div
                      key="paying"
                      initial={{ opacity: 0, x: 10 }}
                      animate={{ opacity: 1, x: 0 }}
                      exit={{ opacity: 0, x: 10 }}
                      transition={{ duration: 0.25 }}
                      className="grid grid-cols-1 gap-6 lg:grid-cols-5"
                    >
                      {/* LEFT — QR + copy */}
                      <div className="lg:col-span-3">
                        <div className="rounded-2xl border border-slate-100 bg-slate-50 p-4 text-center dark:border-slate-800 dark:bg-slate-950">
                          <img
                            src={payment.paymentUrl}
                            alt="QR nạp tiền"
                            className="mx-auto block h-72 w-72 max-w-full rounded-xl bg-white object-contain p-2"
                            onError={(e) => { (e.target as HTMLImageElement).style.display = 'none'; }}
                          />
                          <div className="mt-4">
                            <p className="mb-1.5 text-[10px] font-bold uppercase tracking-wider text-slate-500 dark:text-slate-400">Nội dung chuyển khoản</p>
                            <button
                              type="button"
                              onClick={handleCopy}
                              className="mx-auto flex items-center gap-2 rounded-xl border border-slate-200 bg-white px-4 py-2.5 text-sm font-bold text-slate-900 transition hover:border-orange-300 hover:bg-orange-50 dark:border-slate-700 dark:bg-slate-900 dark:text-white dark:hover:border-orange-500/60 dark:hover:bg-orange-950/30"
                            >
                              <Hash size={15} className="text-orange-500" />
                              <span className="font-mono">{payment.sepayCode}</span>
                              {copied ? <CheckCircle size={15} className="text-emerald-500" /> : <Copy size={15} className="text-slate-400" />}
                            </button>
                          </div>
                        </div>

                        {/* Status pill */}
                        <div className="mt-4">
                          {isCompleted ? (
                            <div className="flex items-center justify-center gap-2 rounded-2xl bg-emerald-50 px-4 py-3 text-sm font-semibold text-emerald-700 dark:bg-emerald-950/30 dark:text-emerald-400">
                              <CheckCircle size={16} /> Thanh toán thành công — đang cập nhật ví...
                            </div>
                          ) : isFailed ? (
                            <div className="flex items-center justify-center gap-2 rounded-2xl bg-red-50 px-4 py-3 text-sm font-semibold text-red-700 dark:bg-red-950/30 dark:text-red-400">
                              <XCircle size={16} /> Thanh toán thất bại
                            </div>
                          ) : expired ? (
                            <div className="flex items-center justify-center gap-2 rounded-2xl bg-red-50 px-4 py-3 text-sm font-semibold text-red-700 dark:bg-red-950/30 dark:text-red-400">
                              <XCircle size={16} /> Đơn đã hết hạn
                            </div>
                          ) : (
                            <div className="flex items-center justify-center gap-2 rounded-2xl bg-amber-50 px-4 py-3 text-sm font-semibold text-amber-700 dark:bg-amber-950/30 dark:text-amber-400">
                              <span className="relative flex h-2.5 w-2.5">
                                <span className="absolute inline-flex h-full w-full animate-ping rounded-full bg-amber-400 opacity-75" />
                                <span className="relative inline-flex h-2.5 w-2.5 rounded-full bg-amber-500" />
                              </span>
                              Đang chờ thanh toán...
                            </div>
                          )}
                        </div>
                      </div>

                      {/* RIGHT — amount + bank info */}
                      <div className="lg:col-span-2 space-y-4">
                        {/* Amount card */}
                        <div className="overflow-hidden rounded-2xl bg-gradient-to-br from-orange-500 to-orange-600 p-5 text-white shadow-lg shadow-orange-200/50">
                          <p className="text-xs text-orange-100">Số tiền cần nạp</p>
                          <p className="mt-1 text-3xl font-extrabold">{formatVnd(payment.amount)}</p>
                          <div className="mt-4 flex items-center gap-2 text-xs text-orange-100">
                            <Clock size={14} />
                            {isCompleted ? 'Đã thanh toán' :
                              isFailed ? 'Thất bại' :
                              expired ? 'Đã hết hạn' :
                              <>Hết hạn sau: <span className="font-bold">{formatCountdown(secondsLeft)}</span></>}
                          </div>
                        </div>

                        {/* Bank info */}
                        <div className="rounded-2xl border border-slate-200 bg-white p-4 dark:border-slate-800 dark:bg-slate-900">
                          <div className="mb-3 flex items-center gap-2 text-sm font-bold text-slate-700 dark:text-slate-200">
                            <Building2 size={15} className="text-orange-500" /> Thông tin nhận
                          </div>
                          <div className="space-y-2 text-sm">
                            <div className="flex justify-between gap-2"><span className="text-slate-500 dark:text-slate-400">Ngân hàng</span><span className="font-semibold text-slate-900 dark:text-white">TPBank</span></div>
                            <div className="flex justify-between gap-2"><span className="text-slate-500 dark:text-slate-400">Số tài khoản</span><span className="font-mono font-semibold text-slate-900 dark:text-white">84519828888</span></div>
                            <div className="flex justify-between gap-2"><span className="text-slate-500 dark:text-slate-400">Chủ tài khoản</span><span className="font-semibold uppercase text-slate-900 dark:text-white">PHAM DUC HUNG</span></div>
                            <div className="flex justify-between gap-2 border-t border-slate-100 pt-2 dark:border-slate-800"><span className="text-slate-500 dark:text-slate-400">Số tiền</span><span className="font-extrabold text-orange-500">{formatVnd(payment.amount)}</span></div>
                          </div>
                        </div>

                        <button
                          type="button"
                          onClick={handleCloseTopup}
                          className="block w-full rounded-2xl border border-slate-200 bg-white px-5 py-2.5 text-sm font-semibold text-slate-700 transition hover:bg-slate-50 dark:border-slate-700 dark:bg-slate-900 dark:text-slate-200 dark:hover:bg-slate-800"
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
          <div className="mb-5 flex items-center justify-between">
            <div>
              <h3 className="text-lg font-extrabold text-slate-950 dark:text-white">Lịch sử giao dịch</h3>
              <p className="mt-1 text-xs text-slate-400">Các giao dịch gần đây của ví</p>
            </div>
            {!loading && <span className="rounded-full bg-slate-100 px-3 py-1 text-xs font-bold text-slate-500 dark:bg-slate-800 dark:text-slate-300">{transactions.length} giao dịch</span>}
          </div>
          {loading ? (
            <div className="space-y-3">{[...Array(4)].map((_, i) => <div key={i} className="h-16 animate-pulse rounded-2xl bg-slate-100 dark:bg-slate-800" />)}</div>
          ) : transactions.length === 0 ? (
            <div className="rounded-2xl border border-dashed border-slate-300 py-12 text-center dark:border-slate-700"><Clock size={26} className="mx-auto mb-2 text-slate-300 dark:text-slate-600" /><p className="text-sm text-slate-400">Chưa có giao dịch nào.</p></div>
          ) : (
            <div className="divide-y divide-slate-100 dark:divide-slate-800">
              {transactions.map(tx => (
                <div key={tx.id} className="flex items-center justify-between gap-3 py-4 first:pt-0 last:pb-0">
                  <div className="flex min-w-0 items-center gap-3">
                    <div className={`flex h-11 w-11 shrink-0 items-center justify-center rounded-2xl ${tx.amount > 0 ? 'bg-emerald-50 dark:bg-emerald-950/40' : 'bg-red-50 dark:bg-red-950/40'}`}>
                      {getIcon(String(tx.type), tx.amount)}
                    </div>
                    <div className="min-w-0">
                      <p className="truncate font-semibold text-slate-900 dark:text-slate-100">{tx.description ?? getTransactionTypeLabel(tx.type)}</p>
                      <p className="mt-0.5 text-xs text-slate-400">{new Date(tx.createdAt).toLocaleString('vi-VN')}</p>
                    </div>
                  </div>
                  <div className="shrink-0 text-right">
                    <p className={`font-extrabold ${tx.amount > 0 ? 'text-emerald-600 dark:text-emerald-400' : 'text-slate-900 dark:text-white'}`}>
                      {tx.amount > 0 ? '+' : ''}{formatVnd(tx.amount)}
                    </p>
                    <span className="text-[10px] font-semibold uppercase tracking-wide text-slate-400">{getTransactionStatusLabel(tx.status)}</span>
                  </div>
                </div>
              ))}
            </div>
          )}
        </motion.div>
      </main>
    </div>
  );
}