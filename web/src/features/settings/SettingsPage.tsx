import { ArrowLeft, Settings } from 'lucide-react';
import { Link } from 'react-router-dom';
import AppearanceCard from './components/AppearanceCard';
import NotificationCard from './components/NotificationCard';

export default function SettingsPage() {
  return (
    <div className="min-h-screen bg-slate-50 pb-20 dark:bg-slate-950">
      <header className="sticky top-0 z-10 flex items-center gap-3 bg-white/80 px-4 py-3 backdrop-blur-md dark:bg-slate-950/80">
        <Link
          to="/"
          aria-label="Quay lại"
          className="inline-flex size-10 shrink-0 items-center justify-center rounded-xl border border-slate-200 bg-white/80 text-slate-600 shadow-sm transition hover:-translate-y-0.5 hover:border-orange-300 hover:bg-orange-50 hover:text-orange-600 dark:border-slate-700 dark:bg-slate-900/80 dark:text-slate-400 dark:hover:border-orange-500/60 dark:hover:bg-slate-800 dark:hover:text-orange-400"
        >
          <ArrowLeft aria-hidden="true" size={18} />
        </Link>
        <div className="flex items-center gap-2">
          <Settings className="size-5 text-orange-500" aria-hidden="true" />
          <h1 className="text-lg font-semibold text-slate-900 dark:text-slate-100">Cài đặt</h1>
        </div>
      </header>

      <main className="mx-auto max-w-3xl px-4 py-6">
        <div className="grid gap-6 sm:grid-cols-2">
          <AppearanceCard />
          <NotificationCard />
        </div>

        <footer className="mt-8 border-t border-slate-200 pt-6 text-center text-sm text-slate-500 dark:border-slate-800 dark:text-slate-400">
          <p>E-Box Locker</p>
          <p className="mt-1">Phiên bản 1.0.0</p>
        </footer>
      </main>
    </div>
  );
}
