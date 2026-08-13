import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { Wallet, Plus, ArrowUpRight, ArrowDownLeft, ShieldCheck, Clock, CreditCard, Sparkles, X } from 'lucide-react';
import AppHeader from '../../../components/layout/AppHeader';
import { hidden, visible, trans } from '../../../lib/animations';
import { apiFetch } from '../../../lib/api';
import { useToast } from '../../../context/ToastContext';
import { formatVnd, formatVndInput, normalizeVndInput } from '../utils/currency';

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

const TRANSACTION_TYPE_LABELS = ['Nạp tiền', 'Chuyển khoản', 'Thanh toán', 'Hoàn tiền'];
const TRANSACTION_STATUS_LABELS = ['Đang xử lý', 'Hoàn thành', 'Thất bại'];
const TOP_UP_AMOUNTS = [50_000, 100_000, 200_000, 500_000, 1_000_000, 2_000_000];

export default function WalletPage() {
  const { show: showToast } = useToast();
  const [balance, setBalance] = useState(0);
  const [transactions, setTransactions] = useState<WalletTransaction[]>([]);
  const [loading, setLoading] = useState(true);
  const [showTopup, setShowTopup] = useState(false);
  const [topupAmount, setTopupAmount] = useState('100000');
  const [processing, setProcessing] = useState(false);

  useEffect(() => {
    let active = true;

    const loadWallet = async () => {
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

        if (!active) return;
        setBalance(overview.balance);
        setTransactions(walletTransactions.sort(
          (a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime(),
        ));
      } catch (error) {
        if (!active) return;
        const message = error instanceof Error ? error.message : 'Không thể tải thông tin ví.';
        showToast(message, 'error');
      } finally {
        if (active) setLoading(false);
      }
    };

    const refreshWhenVisible = () => {
      if (document.visibilityState === 'visible') void loadWallet();
    };

    void loadWallet();
    document.addEventListener('visibilitychange', refreshWhenVisible);

    return () => {
      active = false;
      document.removeEventListener('visibilitychange', refreshWhenVisible);
    };
  }, []);

  const handleSepayTopup = async (e: React.FormEvent) => {
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

      const result = await response.json();
      const checkoutUrl = result.checkoutUrl ?? result.paymentUrl;
      const formFields = result.formFields;

      if (!checkoutUrl || !formFields) {
        throw new Error('Không nhận được dữ liệu thanh toán từ server.');
      }

      submitSepayCheckoutForm(checkoutUrl, formFields);
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : 'Đã có lỗi xảy ra.';
      showToast(errorMessage, 'error');
      setProcessing(false);
    }
  };

  const submitSepayCheckoutForm = (checkoutUrl: string, fields: Record<string, string>) => {
    const fieldOrder = [
      'order_amount',
      'merchant',
      'currency',
      'operation',
      'order_description',
      'order_invoice_number',
      'customer_id',
      'payment_method',
      'success_url',
      'error_url',
      'cancel_url',
      'signature',
    ];

    const form = document.createElement('form');
    form.method = 'POST';
    form.action = checkoutUrl;
    form.style.display = 'none';

    fieldOrder
      .filter(field => fields[field])
      .forEach(field => {
        const input = document.createElement('input');
        input.type = 'hidden';
        input.name = field;
        input.value = fields[field];
        form.appendChild(input);
      });

    document.body.appendChild(form);
    form.submit();
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
    return status;
  };

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
              onClick={() => setShowTopup(true)}
              className="mt-8 flex w-full items-center justify-center gap-2 rounded-2xl bg-orange-500 px-5 py-3.5 text-sm font-bold text-white shadow-lg shadow-orange-950/30 transition hover:-translate-y-0.5 hover:bg-orange-600 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-orange-300 sm:w-auto sm:min-w-52"
            >
              <Plus size={18} /> Nạp tiền vào ví
            </button>
          </div>
        </motion.div>

        {/* Top-up panel */}
        {showTopup && (
          <motion.div initial={hidden} animate={visible} transition={trans(0)} className="mb-7 rounded-[28px] border border-slate-200 bg-white p-5 shadow-xl shadow-slate-200/40 sm:p-7 dark:border-slate-800 dark:bg-slate-900 dark:shadow-black/20">
            <div className="mb-6 flex items-start justify-between gap-4">
              <div>
                <div className="flex items-center gap-2 text-lg font-extrabold text-slate-950 dark:text-white">
                  <span className="flex h-10 w-10 items-center justify-center rounded-xl bg-orange-50 text-orange-500 dark:bg-orange-950/50"><CreditCard size={20} /></span>
                  Nạp tiền qua SePay
                </div>
                <p className="mt-2 text-sm text-slate-500 dark:text-slate-400">Chọn nhanh hoặc nhập số tiền bạn muốn nạp.</p>
              </div>
              <button type="button" onClick={() => setShowTopup(false)} aria-label="Đóng phần nạp tiền" className="rounded-xl p-2 text-slate-400 transition hover:bg-slate-100 hover:text-slate-700 dark:hover:bg-slate-800 dark:hover:text-white">
                <X size={19} />
              </button>
            </div>
            <form onSubmit={handleSepayTopup}>
              <p className="mb-2 text-xs font-bold uppercase tracking-wider text-slate-500 dark:text-slate-400">Mức tiền phổ biến</p>
              <div className="mb-5 grid grid-cols-2 gap-2.5 sm:grid-cols-3">
                {TOP_UP_AMOUNTS.map(amt => (
                  <button key={amt} type="button" aria-pressed={topupAmount === amt.toString()} onClick={() => setTopupAmount(amt.toString())}
                    className={`rounded-2xl border px-3 py-3 text-sm font-bold transition ${topupAmount === amt.toString() ? 'border-orange-500 bg-orange-50 text-orange-600 shadow-sm ring-2 ring-orange-100 dark:bg-orange-950/40 dark:text-orange-400 dark:ring-orange-950' : 'border-slate-200 bg-white text-slate-700 hover:border-orange-300 hover:bg-orange-50/50 dark:border-slate-700 dark:bg-slate-950 dark:text-slate-200 dark:hover:border-orange-500/60 dark:hover:bg-orange-950/30'}`}>
                    {formatVnd(amt)}
                  </button>
                ))}
              </div>
              <label htmlFor="topup-amount" className="mb-2 block text-xs font-bold uppercase tracking-wider text-slate-500 dark:text-slate-400">Số tiền muốn nạp</label>
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
                <button type="submit" disabled={processing || !topupAmount} className="flex min-w-40 items-center justify-center gap-2 rounded-2xl bg-slate-950 px-6 py-3.5 text-sm font-bold text-white transition hover:bg-orange-500 disabled:cursor-not-allowed disabled:opacity-50 dark:bg-orange-500 dark:hover:bg-orange-600">
                  {processing ? 'Đang xử lý...' : 'Thanh toán'}
                </button>
              </div>
              <p className="mt-3 text-xs leading-5 text-slate-400">Bạn sẽ được chuyển đến cổng thanh toán SePay an toàn để hoàn tất giao dịch.</p>
            </form>
          </motion.div>
        )}

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
