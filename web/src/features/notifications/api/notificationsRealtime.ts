import * as signalR from '@microsoft/signalr';
import { getApiOrigin } from '../../../lib/api';
import type { NotificationDto } from '../types';

export type NotificationsConnectionOptions = {
    onNotification: (notification: NotificationDto) => void;
    onReconnected: () => void;
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

    connection.onreconnected(() => {
        options.onReconnected();
    });

    return connection;
}
