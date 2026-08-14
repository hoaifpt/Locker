import * as signalR from '@microsoft/signalr';
import { getApiOrigin } from '../../../lib/api';

export type PaymentStatusChangedEvent = {
    paymentId: string;
    amount: number;
    status: string;
    paidAt?: string | null;
    transactionId?: string | null;
};

export type PaymentRealtimeHandlers = {
    onPaymentStatusChanged: (payload: PaymentStatusChangedEvent) => void;
};

export function createPaymentRealtimeConnection(
    handlers: PaymentRealtimeHandlers
): signalR.HubConnection {
    const connection = new signalR.HubConnectionBuilder()
        .withUrl(`${getApiOrigin()}/hubs/notifications`, {
            accessTokenFactory: () => localStorage.getItem('token') ?? '',
        })
        .withAutomaticReconnect([0, 2000, 5000, 10000, 30000])
        .configureLogging(signalR.LogLevel.Warning)
        .build();

    connection.on('PaymentStatusChanged', (payload: PaymentStatusChangedEvent) => {
        handlers.onPaymentStatusChanged(payload);
    });

    return connection;
}
