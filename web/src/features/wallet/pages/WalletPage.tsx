import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { Wallet, Plus, Send as SendIcon, ArrowUpRight, ArrowDownLeft, ShieldCheck, Clock, CreditCard, ChevronRight } from 'lucide-react';
import AppHeader from '../../../components/layout/AppHeader';
import { hidden, visible, trans } from '../../../lib/animations';
import { getWalletTransactionsByUser, getWalletBalance, SeedWalletTransaction } from '../../../mocks/seed';
import { useToast } from '../../../context/ToastContext';

export default function WalletPage() {
  const userId = localStorage.getItem('userId') ?? 'u-001';
  const { show: showToast } = useToast();
  const [balance, setBalance] = useState(0);
  const [transactions, setTransactions] = useState<SeedWalletTransaction[]>([]);
  const [loading, setLoading] = useState(true);
  const [showTopup, setShowTopup] = useState(false);
  const [topupAmount, setTopupAmount] = useState('100000');
  const [processing, setProcessing] = useState(false);

  useEffect(() => {
    setTimeout(() => {
      setBalance(getWalletBalance(userId));
      setTransactions(getWalletTransactionsByUser(userId).sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime()));
      setLoading(false);
    }, 300);
  }, [userId]);

  const handleTopup = async (e: React.FormEvent) => {
    e.preventDefault();
    setProcessing(true);
    await new Promise(r => setTimeout(r, 1500));
    setBalance(b => b + Number(topupAmount));
    const newTx: SeedWalletTransaction = {
      id: `tx-mock-${Date.now()}`, userId, amount: Number(topupAmount), type: 'TopUp', status: 'Completed', description: 'Nạp tiền vào ví', createdAt: new Date().toISOString()
    };
    setTransactions(prev => [newTx, ...prev]);
    showToast(`✓ Nạp thành công ${Number(topupAmount).toLocaleString('vi-VN')}đ`, 'success');
    setProcessing(false);
    setShowTopup(false);
  };

  const getIcon = (type: string, amount: number) => {
    if (type === 'TopUp' || amount > 0) return <ArrowDownLeft size={16} className="text-green-500" />;
    return <ArrowUpRight size={16} className="text-red-500" />;
  };

  return (
    <div className="min-h-screen bg-[#F9F8F6] font-sans antialiased">
      <AppHeader />
      <main className="mx-auto max-w-2xl px-4 py-8 lg:px-8">
        
        {/* Balance Card */}
        <motion.div initial={hidden} animate={visible} transition={trans(0)} className="mb-6 relative overflow-hidden rounded-3xl bg-gradient-to-br from-gray-900 to-gray-800 p-8 shadow-xl shadow-gray-900/20">
          <div className="absolute top-0 right-0 p-4 opacity-10">
            <Wallet size={120} />
          </div>
          <div className="relative z-10 flex items-center justify-between">
            <span className="flex items-center gap-2 rounded-full bg-white/10 px-3 py-1 text-xs font-semibold text-white backdrop-blur-md">
              <ShieldCheck size={14} /> LuxeLock Pay
            </span>
          </div>
          <div className="relative z-10 mt-6">
            <p className="text-sm font-medium text-gray-400">Số dư khả dụng</p>
            <h2 className="mt-1 flex items-baseline gap-1 text-4xl font-extrabold tracking-tight text-white">
              {loading ? '...' : balance.toLocaleString('vi-VN')} <span className="text-lg font-normal text-gray-400">VNĐ</span>
            </h2>
          </div>
          <div className="relative z-10 mt-8 flex gap-3">
            <button onClick={() => setShowTopup(true)} className="flex flex-1 items-center justify-center gap-2 rounded-xl bg-orange-500 py-3 text-sm font-semibold text-white transition hover:bg-orange-600">
              <Plus size={16} /> Nạp tiền
            </button>
            <button onClick={() => showToast('Tính năng rút tiền đang phát triển', 'info')} className="flex flex-1 items-center justify-center gap-2 rounded-xl bg-white/10 py-3 text-sm font-semibold text-white backdrop-blur-md transition hover:bg-white/20">
              <SendIcon size={14} /> Chuyển khoản
            </button>
          </div>
        </motion.div>

        {/* Topup Modal */}
        {showTopup && (
          <motion.div initial={hidden} animate={visible} transition={trans(0)} className="mb-6 rounded-3xl border border-gray-100 bg-white p-6 shadow-sm">
            <h3 className="mb-4 font-bold text-gray-900 flex items-center gap-2"><CreditCard size={18} className="text-orange-500"/> Nạp tiền vào ví</h3>
            <form onSubmit={handleTopup}>
              <div className="grid grid-cols-3 gap-2 mb-4">
                {[50000, 100000, 200000, 500000, 1000000, 2000000].map(amt => (
                  <button key={amt} type="button" onClick={() => setTopupAmount(amt.toString())}
                    className={`rounded-xl border py-2 text-sm font-semibold transition ${topupAmount === amt.toString() ? 'border-orange-500 bg-orange-50 text-orange-600' : 'border-gray-200 bg-white text-gray-600 hover:border-orange-300'}`}>
                    {(amt / 1000).toFixed(0)}K
                  </button>
                ))}
              </div>
              <div className="flex gap-2">
                <input type="number" value={topupAmount} onChange={e => setTopupAmount(e.target.value)}
                  className="flex-1 rounded-xl border border-gray-200 bg-gray-50 px-4 text-sm font-semibold text-gray-900 outline-none focus:border-orange-500 focus:ring-2 focus:ring-orange-100" />
                <button type="submit" disabled={processing || !topupAmount} className="flex items-center gap-2 rounded-xl bg-gray-900 px-6 py-3 text-sm font-semibold text-white transition hover:bg-black disabled:opacity-50">
                  {processing ? 'Đang xử lý...' : 'Xác nhận'}
                </button>
              </div>
            </form>
          </motion.div>
        )}

        {/* Transactions */}
        <motion.div initial={hidden} animate={visible} transition={trans(0.1)}>
          <h3 className="mb-4 text-lg font-bold text-gray-900">Lịch sử giao dịch</h3>
          {loading ? (
            <div className="space-y-3">{[...Array(4)].map((_, i) => <div key={i} className="h-16 animate-pulse rounded-2xl bg-gray-200" />)}</div>
          ) : transactions.length === 0 ? (
            <div className="rounded-2xl border border-dashed border-gray-300 py-10 text-center"><Clock size={24} className="mx-auto mb-2 text-gray-300"/><p className="text-sm text-gray-400">Chưa có giao dịch nào.</p></div>
          ) : (
            <div className="space-y-3">
              {transactions.map(tx => (
                <div key={tx.id} className="flex items-center justify-between rounded-2xl border border-gray-100 bg-white p-4 shadow-sm transition hover:shadow-md">
                  <div className="flex items-center gap-3">
                    <div className={`flex h-10 w-10 items-center justify-center rounded-xl ${tx.amount > 0 ? 'bg-green-100' : 'bg-red-100'}`}>
                      {getIcon(tx.type, tx.amount)}
                    </div>
                    <div>
                      <p className="font-semibold text-gray-900">{tx.description ?? tx.type}</p>
                      <p className="text-xs text-gray-400">{new Date(tx.createdAt).toLocaleString('vi-VN')}</p>
                    </div>
                  </div>
                  <div className="text-right">
                    <p className={`font-bold ${tx.amount > 0 ? 'text-green-600' : 'text-gray-900'}`}>
                      {tx.amount > 0 ? '+' : ''}{tx.amount.toLocaleString('vi-VN')}đ
                    </p>
                    <span className="text-[10px] font-semibold uppercase text-gray-400">{tx.status}</span>
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
