import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useRef,
  useState,
  type ReactNode,
} from 'react';
import type { HubConnection } from '@microsoft/signalr';
import { getMyNotifications, markAllNotificationsAsRead, markNotificationAsRead } from '../api/notificationsApi';
import {
  createNotificationsConnection,
  startNotificationsConnection,
} from '../api/notificationsRealtime';
import type { NotificationDto } from '../types';

const POLL_FALLBACK_MS = 30_000;

interface NotificationsContextValue {
  notifications: NotificationDto[];
  unreadCount: number;
  isLoading: boolean;
  loadError: string | null;
  mutationError: string | null;
  connectionState: 'idle' | 'connecting' | 'connected' | 'reconnecting' | 'closed';
  refresh: () => Promise<void>;
  markAsRead: (id: string) => Promise<void>;
  markAllAsRead: () => Promise<void>;
}

const NotificationsContext = createContext<NotificationsContextValue | undefined>(undefined);

function dedupeMerge(current: NotificationDto[], incoming: NotificationDto[]): NotificationDto[] {
  const byId = new Map(current.map((item) => [item.id, item]));
  for (const item of incoming) byId.set(item.id, item);
  return [...byId.values()].sort(
    (a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime(),
  );
}

function hasAuthToken(): boolean {
  try {
    return !!localStorage.getItem('token');
  } catch {
    return false;
  }
}

export function NotificationsProvider({ children }: { children: ReactNode }) {
  const [notifications, setNotifications] = useState<NotificationDto[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [loadError, setLoadError] = useState<string | null>(null);
  const [mutationError, setMutationError] = useState<string | null>(null);
  const [connectionState, setConnectionState] =
    useState<NotificationsContextValue['connectionState']>('idle');

  const connectionRef = useRef<HubConnection | null>(null);
  const abortRef = useRef<AbortController | null>(null);
  const pollRef = useRef<ReturnType<typeof setInterval> | null>(null);
  const requestGenRef = useRef(0);

  const loadNotifications = useCallback(async () => {
    if (!hasAuthToken()) {
      setNotifications([]);
      return;
    }
    const generation = ++requestGenRef.current;
    setIsLoading(true);
    setLoadError(null);
    try {
      const items = await getMyNotifications();
      if (generation !== requestGenRef.current) return;
      setNotifications((current) => dedupeMerge(current, items));
    } catch (err) {
      if (generation !== requestGenRef.current) return;
      console.error('[notifications] load failed', err);
      setLoadError('Không thể tải thông báo.');
    } finally {
      if (generation === requestGenRef.current) {
        setIsLoading(false);
      }
    }
  }, []);

  const stopPolling = useCallback(() => {
    if (pollRef.current) {
      clearInterval(pollRef.current);
      pollRef.current = null;
    }
  }, []);

  const startPolling = useCallback(() => {
    stopPolling();
    pollRef.current = setInterval(() => {
      void loadNotifications();
    }, POLL_FALLBACK_MS);
  }, [loadNotifications, stopPolling]);

  const startConnection = useCallback(() => {
    if (!hasAuthToken()) return;
    if (connectionRef.current) return;

    setConnectionState('connecting');
    const connection = createNotificationsConnection({
      onNotification: (incoming) => {
        setNotifications((current) => dedupeMerge(current, [incoming]));
      },
      onReconnected: () => {
        setConnectionState('connected');
        stopPolling();
        void loadNotifications();
      },
      onConnectionStateChanged: (state) => {
        setConnectionState(state);
        if (state === 'connected') stopPolling();
        else if (state === 'reconnecting' || state === 'connecting') startPolling();
        else if (state === 'closed') startPolling();
      },
    });
    connectionRef.current = connection;

    const abort = new AbortController();
    abortRef.current = abort;
    void startNotificationsConnection(connection, abort.signal);
  }, [loadNotifications, startPolling, stopPolling]);

  const stopConnection = useCallback(async () => {
    abortRef.current?.abort();
    abortRef.current = null;
    const conn = connectionRef.current;
    connectionRef.current = null;
    if (conn) {
      try {
        await conn.stop();
      } catch (err) {
        console.warn('[notifications] stop failed', err);
      }
    }
    setConnectionState('closed');
  }, []);

  useEffect(() => {
    const onStorage = (event: StorageEvent) => {
      if (event.key === 'token') {
        if (event.newValue) {
          void stopConnection().then(() => {
            startConnection();
            void loadNotifications();
          });
        } else {
          void stopConnection();
          stopPolling();
          setNotifications([]);
          setConnectionState('closed');
        }
      }
    };
    window.addEventListener('storage', onStorage);
    return () => window.removeEventListener('storage', onStorage);
  }, [loadNotifications, startConnection, stopConnection, stopPolling]);

  useEffect(() => {
    if (hasAuthToken()) {
      startConnection();
      void loadNotifications();
    }
    return () => {
      void stopConnection();
      stopPolling();
    };
    // mount-once: connection lifecycle is owned by the provider.
    // Token changes are handled via the storage-event listener above.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const markAsRead = useCallback(async (id: string) => {
    setMutationError(null);
    try {
      await markNotificationAsRead(id);
      setNotifications((prev) => prev.map((n) => (n.id === id ? { ...n, isRead: true } : n)));
    } catch (err) {
      console.error('[notifications] markAsRead failed', err);
      setMutationError('Không thể đánh dấu đã đọc.');
    }
  }, []);

  const markAllAsRead = useCallback(async () => {
    setMutationError(null);
    try {
      await markAllNotificationsAsRead();
      setNotifications((prev) => prev.map((n) => ({ ...n, isRead: true })));
    } catch (err) {
      console.error('[notifications] markAllAsRead failed', err);
      setMutationError('Không thể đánh dấu tất cả đã đọc.');
    }
  }, []);

  const unreadCount = useMemo(
    () => notifications.filter((n) => !n.isRead).length,
    [notifications],
  );

  const value = useMemo<NotificationsContextValue>(
    () => ({
      notifications,
      unreadCount,
      isLoading,
      loadError,
      mutationError,
      connectionState,
      refresh: loadNotifications,
      markAsRead,
      markAllAsRead,
    }),
    [
      notifications,
      unreadCount,
      isLoading,
      loadError,
      mutationError,
      connectionState,
      loadNotifications,
      markAsRead,
      markAllAsRead,
    ],
  );

  return <NotificationsContext.Provider value={value}>{children}</NotificationsContext.Provider>;
}

export function useNotifications(): NotificationsContextValue {
  const ctx = useContext(NotificationsContext);
  if (!ctx) {
    throw new Error('useNotifications must be used within NotificationsProvider');
  }
  return ctx;
}