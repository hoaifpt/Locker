import * as signalR from '@microsoft/signalr';
import { getApiOrigin } from '../../../lib/api';
import type { NotificationDto } from '../types';

export type NotificationsConnectionOptions = {
    onNotification: (notification: NotificationDto) => void;
    onReconnected: () => void;
    onConnectionStateChanged?: (
        state: 'connecting' | 'connected' | 'reconnecting' | 'closed'
    ) => void;
};

export function createNotificationsConnection(
    options: NotificationsConnectionOptions
): signalR.HubConnection {
    const reorderIntervals = [0, 2000, 5000, 10000, 30000];

    const connection = new signalR.HubConnectionBuilder()
        .withUrl(`${getApiOrigin()}/hubs/notifications`, {
            accessTokenFactory: () => localStorage.getItem('token') ?? '',
        })
        .withAutomaticReconnect(reorderIntervals)
        .configureLogging(signalR.LogLevel.Warning)
        .build();

    connection.on('NotificationReceived', (notification: NotificationDto) => {
        options.onNotification(notification);
    });

    connection.onreconnecting(() => {
        console.info('[notifications] reconnecting...');
        options.onConnectionStateChanged?.('reconnecting');
    });

    connection.onreconnected(() => {
        console.info('[notifications] reconnected');
        options.onConnectionStateChanged?.('connected');
        options.onReconnected();
    });

    connection.onclose((err) => {
        console.warn('[notifications] connection closed', err);
        options.onConnectionStateChanged?.('closed');
    });

    options.onConnectionStateChanged?.('connecting');

    return connection;
}

const START_DELAY_MS: ReadonlyArray<number> = [0, 2_000, 5_000, 10_000, 30_000];

function isTransientState(state: signalR.HubConnectionState): boolean {
    return (
        state === signalR.HubConnectionState.Connected ||
        state === signalR.HubConnectionState.Connecting ||
        state === signalR.HubConnectionState.Reconnecting
    );
}

function abortableSleep(ms: number, signal: AbortSignal): Promise<void> {
    if (signal.aborted) {
        return Promise.reject(new DOMException('Aborted', 'AbortError'));
    }
    return new Promise<void>((resolve, reject) => {
        const timer = setTimeout(() => {
            signal.removeEventListener('abort', onAbort);
            resolve();
        }, ms);
        const onAbort = () => {
            clearTimeout(timer);
            signal.removeEventListener('abort', onAbort);
            reject(new DOMException('Aborted', 'AbortError'));
        };
        signal.addEventListener('abort', onAbort, { once: true });
    });
}

export async function startNotificationsConnection(
    connection: signalR.HubConnection,
    signal: AbortSignal
): Promise<void> {
    if (signal.aborted) {
        return;
    }

    for (let attempt = 0; ; attempt++) {
        if (signal.aborted) {
            return;
        }

        if (isTransientState(connection.state)) {
            return;
        }

        try {
            await connection.start();
            return;
        } catch (err) {
            if (signal.aborted) {
                return;
            }
            const delayMs = START_DELAY_MS[Math.min(attempt, START_DELAY_MS.length - 1)];
            console.warn(
                `[notifications] initial start attempt ${attempt + 1} failed; retrying in ${delayMs}ms`,
                err
            );
            try {
                await abortableSleep(delayMs, signal);
            } catch {
                return;
            }
        }
    }
}