import { useState, useEffect, useRef, useCallback } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Bell, Check, Package, CreditCard, Send, Lock } from 'lucide-react';
import type { HubConnection } from '@microsoft/signalr';
import { getMyNotifications, markNotificationAsRead, markAllNotificationsAsRead } from '../api/notificationsApi';
import { createNotificationsConnection, startNotificationsConnection } from '../api/notificationsRealtime';
import type { NotificationDto } from '../types';

function mergeNotifications(
    current: NotificationDto[],
    incoming: NotificationDto[]
): NotificationDto[] {
    const byId = new Map(current.map((item) => [item.id, item]));
    for (const item of incoming) {
        byId.set(item.id, item);
    }
    return [...byId.values()].sort(
        (a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime()
    );
}

export default function NotificationsDropdown() {
    const [isOpen, setIsOpen] = useState(false);
    const [notifications, setNotifications] = useState<NotificationDto[]>([]);
    const [isLoading, setIsLoading] = useState(true);
    const [loadError, setLoadError] = useState<string | null>(null);
    const [mutationError, setMutationError] = useState<string | null>(null);
    const [pendingReadIds, setPendingReadIds] = useState<Set<string>>(new Set());
    const [isMarkingAll, setIsMarkingAll] = useState(false);
    const dropdownRef = useRef<HTMLDivElement>(null);
    const connectionRef = useRef<HubConnection | null>(null);
    const requestGenerationRef = useRef(0);
    const isMountedRef = useRef(true);

    const loadNotifications = useCallback(async () => {
        const generation = ++requestGenerationRef.current;
        setIsLoading(true);
        setLoadError(null);
        try {
            const items = await getMyNotifications();
            if (generation !== requestGenerationRef.current || !isMountedRef.current) {
                return;
            }
            setNotifications((current) => mergeNotifications(current, items));
        } catch (err) {
            if (generation !== requestGenerationRef.current || !isMountedRef.current) {
                return;
            }
            console.error('Failed to load notifications', err);
            setLoadError('Không thể tải thông báo.');
            setNotifications([]);
        } finally {
            if (generation === requestGenerationRef.current && isMountedRef.current) {
                setIsLoading(false);
            }
        }
    }, []);

    useEffect(() => {
        isMountedRef.current = true;
        loadNotifications();

        const connection = createNotificationsConnection({
            onNotification: (incoming) => {
                if (!isMountedRef.current) return;
                setNotifications((current) => mergeNotifications(current, [incoming]));
            },
            onReconnected: () => {
                loadNotifications();
            },
        });

        connectionRef.current = connection;

        const abortController = new AbortController();
        void startNotificationsConnection(connection, abortController.signal);

        return () => {
            isMountedRef.current = false;
            requestGenerationRef.current++;
            abortController.abort();
            const conn = connectionRef.current;
            connectionRef.current = null;
            if (conn) {
                conn.stop().catch((err) => {
                    console.error('SignalR stop failed', err);
                });
            }
        };
    }, [loadNotifications]);

    useEffect(() => {
        const handleClickOutside = (event: MouseEvent) => {
            if (dropdownRef.current && !dropdownRef.current.contains(event.target as Node)) {
                setIsOpen(false);
            }
        };
        document.addEventListener('mousedown', handleClickOutside);
        return () => document.removeEventListener('mousedown', handleClickOutside);
    }, []);

    const unreadCount = notifications.filter((n) => !n.isRead).length;

    const markAllAsRead = async () => {
        if (isMarkingAll) return;
        setIsMarkingAll(true);
        setMutationError(null);
        try {
            await markAllNotificationsAsRead();
            if (!isMountedRef.current) return;
            setNotifications((prev) => prev.map((n) => ({ ...n, isRead: true })));
        } catch (err) {
            console.error('Failed to mark all as read', err);
            if (isMountedRef.current) {
                setMutationError('Không thể đánh dấu tất cả đã đọc.');
            }
        } finally {
            if (isMountedRef.current) {
                setIsMarkingAll(false);
            }
        }
    };

    const markAsRead = async (id: string) => {
        if (pendingReadIds.has(id)) return;
        setPendingReadIds((prev) => {
            const next = new Set(prev);
            next.add(id);
            return next;
        });
        setMutationError(null);
        try {
            await markNotificationAsRead(id);
            if (!isMountedRef.current) return;
            setNotifications((prev) => prev.map((n) => (n.id === id ? { ...n, isRead: true } : n)));
        } catch (err) {
            console.error('Failed to mark notification as read', err);
            if (isMountedRef.current) {
                setMutationError('Không thể đánh dấu đã đọc.');
            }
        } finally {
            setPendingReadIds((prev) => {
                const next = new Set(prev);
                next.delete(id);
                return next;
            });
        }
    };

    const getIcon = (title: string) => {
        const t = title.toLowerCase();
        if (t.includes('thanh toán') || t.includes('nạp')) return <CreditCard size={14} className="text-blue-500" />;
        if (t.includes('gửi hàng') || t.includes('nhận') || t.includes('kiện')) return <Send size={14} className="text-green-500" />;
        if (t.includes('kích hoạt') || t.includes('thời gian')) return <Lock size={14} className="text-orange-500" />;
        return <Package size={14} className="text-gray-500" />;
    };

    return (
        <div className="relative" ref={dropdownRef}>
            <button onClick={() => setIsOpen(!isOpen)} className="relative flex h-10 w-10 items-center justify-center rounded-full bg-gray-100 text-gray-600 transition hover:bg-gray-200">
                <Bell size={18} />
                {unreadCount > 0 && (
                    <span className="absolute right-2 top-2 h-2.5 w-2.5 rounded-full bg-red-500 ring-2 ring-white"></span>
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
                            <h3 className="font-bold text-gray-900">Thông báo</h3>
                            {unreadCount > 0 && !isLoading && !loadError && (
                                <button
                                    onClick={markAllAsRead}
                                    disabled={isMarkingAll}
                                    className="flex items-center gap-1 text-xs font-semibold text-orange-500 hover:text-orange-600 disabled:opacity-50"
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
                                        onClick={loadNotifications}
                                        className="mt-3 inline-flex items-center justify-center rounded-full border border-orange-500 px-4 py-1.5 text-xs font-semibold text-orange-500 hover:bg-orange-50"
                                    >
                                        Thử lại
                                    </button>
                                </div>
                            ) : notifications.length === 0 ? (
                                <div className="p-8 text-center text-sm text-gray-400">Không có thông báo nào.</div>
                            ) : (
                                <div className="divide-y divide-gray-50">
                                    {notifications.map((n) => {
                                        const isPending = pendingReadIds.has(n.id);
                                        return (
                                            <div
                                                key={n.id}
                                                onClick={() => {
                                                    if (!n.isRead) markAsRead(n.id);
                                                }}
                                                className={`flex cursor-pointer items-start gap-3 p-4 transition hover:bg-gray-50 ${!n.isRead ? 'bg-orange-50/30' : ''} ${isPending ? 'opacity-60' : ''}`}
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
                                        );
                                    })}
                                </div>
                            )}
                        </div>
                    </motion.div>
                )}
            </AnimatePresence>
        </div>
    );
}