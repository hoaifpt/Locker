import { apiFetch } from '../../../lib/api';
import type { NotificationDto } from '../types';

function throwVietnameseError(status: number, fallback: string): never {
    let detail = '';
    try {
        detail = JSON.stringify({});
    } catch {
        detail = '';
    }

    throw new Error(`[${status}] ${fallback}${detail ? `: ${detail}` : ''}`);
}

export async function getMyNotifications(): Promise<NotificationDto[]> {
    const response = await apiFetch('/notifications/my');

    if (!response.ok) {
        throwVietnameseError(response.status, 'Không thể tải thông báo.');
    }

    const data = (await response.json()) as Array<{
        id: string;
        title: string;
        message: string;
        isRead: boolean;
        createdAt: string;
    }>;

    return data.map(item => ({
        id: item.id,
        title: item.title,
        message: item.message,
        isRead: item.isRead,
        createdAt: item.createdAt,
    }));
}

export async function markNotificationAsRead(id: string): Promise<void> {
    const encodedId = encodeURIComponent(id);
    const response = await apiFetch(`/notifications/${encodedId}/mark-as-read`, {
        method: 'POST',
    });

    if (!response.ok && response.status !== 204) {
        throwVietnameseError(response.status, 'Không thể đánh dấu đã đọc.');
    }
}

export async function markAllNotificationsAsRead(): Promise<void> {
    const response = await apiFetch('/notifications/mark-all-as-read', {
        method: 'POST',
    });

    if (!response.ok && response.status !== 204) {
        throwVietnameseError(response.status, 'Không thể đánh dấu tất cả đã đọc.');
    }
}
