const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || '/api';

// ─── Token-refresh guard ─────────────────────────────────────────────────────
// Prevents multiple concurrent refresh attempts when several requests fail at
// the same time (e.g. tab wakes up and fires many parallel requests).

let isRefreshing = false;
let refreshPromise: Promise<boolean> | null = null;

async function refreshTokens(): Promise<boolean> {
    const refreshToken = localStorage.getItem('refreshToken');
    if (!refreshToken) return false;

    try {
        const res = await fetch(`${API_BASE_URL}/auth/refresh`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ token: refreshToken }),
        });

        if (!res.ok) return false;

        const data = await res.json();
        localStorage.setItem('token', data.token);
        localStorage.setItem('refreshToken', data.refreshToken);
        if (data.expiresAt) localStorage.setItem('expiresAt', data.expiresAt);
        return true;
    } catch {
        return false;
    }
}

function getOrCreateRefreshPromise(): Promise<boolean> {
    if (!isRefreshing) {
        isRefreshing = true;
        refreshPromise = refreshTokens().finally(() => {
            isRefreshing = false;
            refreshPromise = null;
        });
    }
    return refreshPromise;
}

// ─── Helpers ────────────────────────────────────────────────────────────────

export function getApiOrigin(): string {
    if (typeof window === 'undefined') {
        return '';
    }

    const baseUrl = API_BASE_URL.replace(/\/$/, '');

    if (baseUrl.startsWith('http://') || baseUrl.startsWith('https://')) {
        const lastSlash = baseUrl.lastIndexOf('/');
        if (lastSlash <= baseUrl.indexOf('://') + 2) {
            return baseUrl;
        }
        const lastSegment = baseUrl.substring(lastSlash + 1);
        if (lastSegment === 'api') {
            return baseUrl.substring(0, lastSlash);
        }
        return baseUrl;
    }

    if (baseUrl === '/api' || baseUrl === 'api') {
        return window.location.origin;
    }

    if (baseUrl.startsWith('/')) {
        return `${window.location.origin}${baseUrl}`;
    }

    return `${window.location.origin}/${baseUrl}`;
}

// ─── Core fetch ───────────────────────────────────────────────────────────────

export type FetchOptions = RequestInit & {
    data?: unknown;
    /** Set to true to skip the 401→refresh retry logic (e.g. for the refresh endpoint itself) */
    _noRetry?: boolean;
};

export async function apiFetch(endpoint: string, options: FetchOptions = {}): Promise<Response> {
    const { data, headers: customHeaders, _noRetry, ...restOptions } = options;

    const headers = new Headers(customHeaders);
    if (!headers.has('Content-Type') && data !== undefined) {
        headers.set('Content-Type', 'application/json');
    }

    const token = localStorage.getItem('token');
    if (token && !headers.has('Authorization')) {
        headers.set('Authorization', `Bearer ${token}`);
    }

    const config: RequestInit = {
        ...restOptions,
        headers,
    };

    if (data !== undefined) config.body = JSON.stringify(data);

    const baseUrl = API_BASE_URL.replace(/\/$/, '');
    const relativeEndpoint = endpoint.startsWith('/') ? endpoint : `/${endpoint}`;
    const url = `${baseUrl}${relativeEndpoint}`;

    let response = await fetch(url, config);

    // 401 → attempt token refresh + retry once
    const shouldRefreshOnUnauthorized = !_noRetry && endpoint !== '/auth/login';
    if (shouldRefreshOnUnauthorized && response.status === 401) {
        const refreshed = await getOrCreateRefreshPromise();

        if (refreshed) {
            // Retry with the new token
            const newToken = localStorage.getItem('token');
            const retryHeaders = new Headers(headers);
            retryHeaders.set('Authorization', `Bearer ${newToken}`);
            response = await fetch(url, { ...config, headers: retryHeaders });
        } else {
            // Refresh failed → force logout
            localStorage.removeItem('token');
            localStorage.removeItem('refreshToken');
            localStorage.removeItem('expiresAt');
            window.location.href = '/login';
        }
    }

    return response;
}

export const api = {
    get: (url: string) => apiFetch(url),
    post: (url: string, data?: Record<string, unknown>) => apiFetch(url, { method: 'POST', data }),
    put: (url: string, data?: Record<string, unknown>) => apiFetch(url, { method: 'PUT', data }),
};
