import { useState, useEffect, useRef } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Bell, Check, Package, CreditCard, Send, Lock } from 'lucide-react';
import { useNotifications } from '../context/NotificationsContext';

function getIcon(title: string) {
    const t = title.toLowerCase();
    if (t.includes('thanh toán') || t.includes('nạp')) {
        return <CreditCard size={14} className="text-blue-500" />;
    }
    if (t.includes('gửi hàng') || t.includes('nhận') || t.includes('kiện')) {
        return <Send size={14} className="text-green-500" />;
    }
    if (t.includes('kích hoạt') || t.includes('thời gian')) {
        return <Lock size={14} className="text-orange-500" />;
    }
    return <Package size={14} className="text-gray-500" />;
}

export default function NotificationsDropdown() {
    const [isOpen, setIsOpen] = useState(false);
    const dropdownRef = useRef<HTMLDivElement>(null);
    const {
        notifications,
        unreadCount,
        isLoading,
        loadError,
        mutationError,
        connectionState,
        refresh,
        markAsRead,
        markAllAsRead,
    } = useNotifications();

    useEffect(() => {
        const handleClickOutside = (event: MouseEvent) => {
            if (dropdownRef.current && !dropdownRef.current.contains(event.target as Node)) {
                setIsOpen(false);
            }
        };
        document.addEventListener('mousedown', handleClickOutside);
        return () => document.removeEventListener('mousedown', handleClickOutside);
    }, []);

    const isMarkingAllRef = useRef(false);

    const handleMarkAllAsRead = async () => {
        if (isMarkingAllRef.current) return;
        isMarkingAllRef.current = true;
        try {
            await markAllAsRead();
        } finally {
            isMarkingAllRef.current = false;
        }
    };

    const handleMarkAsRead = (id: string) => {
        void markAsRead(id);
    };

    return (
        <div className="relative" ref={dropdownRef}>
            <button
                onClick={() => setIsOpen(!isOpen)}
                className="relative flex h-10 w-10 items-center justify-center rounded-full bg-gray-100 text-gray-600 transition hover:bg-gray-200"
                aria-label="Thông báo"
                aria-haspopup="dialog"
                aria-expanded={isOpen}
            >
                <Bell size={18} />
                {unreadCount > 0 && (
                    <span className="absolute right-2 top-2 h-2.5 w-2.5 rounded-full bg-red-500 ring-2 ring-white" />
                )}
            </button>

            <AnimatePresence>
                {isOpen && (
                    <motion.div
                        initial={{ opacity: 0, y: 10, scale: 0.95 }}
                        animate={{ opacity: 1, y: 0, scale: 1 }}
                        exit={{ opacity: 0, y: 10, scale: 0.95 }}
                        transition={{ duration: 0.15 }}
                        className="absolute right-0 mt-2 w-80 sm:w-96 origin-top-right rounded-2xl border border-gray-100 bg-white shadow-xl shadow-gray-200/50 z-50 overflow-hidden"
                    >
                        <div className="flex items-center justify-between border-b border-gray-100 p-4">
                            <div className="flex items-center gap-2">
                                <h3 className="font-bold text-gray-900">Thông báo</h3>
                                <span
                                    className={`h-1.5 w-1.5 rounded-full ${
                                        connectionState === 'connected'
                                            ? 'bg-emerald-500'
                                            : connectionState === 'reconnecting' || connectionState === 'connecting'
                                              ? 'bg-amber-500'
                                              : 'bg-slate-300'
                                    }`}
                                    title={`Trạng thái kết nối: ${connectionState}`}
                                />
                            </div>
                            {unreadCount > 0 && !isLoading && !loadError && (
                                <button
                                    onClick={handleMarkAllAsRead}
                                    className="flex items-center gap-1 text-xs font-semibold text-orange-500 hover:text-orange-600"
                                >
                                    <Check size={14} /> Đánh dấu đã đọc
                                </button>
                            )}
                        </div>

                        {mutationError && (
                            <div className="border-b border-orange-100 bg-orange-50 px-4 py-2 text-xs text-orange-700">
                                {mutationError}
                            </div>
                        )}

                        <div className="max-h-[400px] overflow-y-auto">
                            {isLoading ? (
                                <div className="p-8 text-center text-sm text-gray-400">Đang tải thông báo...</div>
                            ) : loadError ? (
                                <div className="p-8 text-center text-sm text-gray-500">
                                    <p>{loadError}</p>
                                    <button
                                        onClick={() => void refresh()}
                                        className="mt-3 inline-flex items-center justify-center rounded-full border border-orange-500 px-4 py-1.5 text-xs font-semibold text-orange-500 hover:bg-orange-50"
                                    >
                                        Thử lại
                                    </button>
                                </div>
                            ) : notifications.length === 0 ? (
                                <div className="p-8 text-center text-sm text-gray-400">Không có thông báo nào.</div>
                            ) : (
                                <div className="divide-y divide-gray-50">
                                    {notifications.map((n) => (
                                        <div
                                            key={n.id}
                                            onClick={() => {
                                                if (!n.isRead) handleMarkAsRead(n.id);
                                            }}
                                            className={`flex cursor-pointer items-start gap-3 p-4 transition hover:bg-gray-50 ${!n.isRead ? 'bg-orange-50/30' : ''}`}
                                        >
                                            <div className="mt-0.5 flex h-8 w-8 shrink-0 items-center justify-center rounded-full bg-gray-100">
                                                {getIcon(n.title)}
                                            </div>
                                            <div className="flex-1">
                                                <p className={`text-sm ${!n.isRead ? 'font-bold text-gray-900' : 'font-medium text-gray-700'}`}>{n.title}</p>
                                                <p className="mt-0.5 text-xs text-gray-500 line-clamp-2">{n.message}</p>
                                                <p className="mt-1.5 text-[10px] text-gray-400">{new Date(n.createdAt).toLocaleString('vi-VN')}</p>
                                            </div>
                                            {!n.isRead && <div className="mt-1.5 h-2 w-2 shrink-0 rounded-full bg-orange-500" />}
                                        </div>
                                    ))}
                                </div>
                            )}
                        </div>
                    </motion.div>
                )}
            </AnimatePresence>
        </div>
    );
}