const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || '/api';

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

export type FetchOptions = RequestInit & {
    data?: unknown;
};

export async function apiFetch(endpoint: string, options: FetchOptions = {}): Promise<Response> {
    const { data, headers: customHeaders, ...restOptions } = options;

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
    return fetch(`${baseUrl}${relativeEndpoint}`, config);
}

export const api = {
    get: (url: string) => apiFetch(url),
    post: (url: string, data?: Record<string, unknown>) => apiFetch(url, { method: 'POST', data }),
    put: (url: string, data?: Record<string, unknown>) => apiFetch(url, { method: 'PUT', data }),
};
