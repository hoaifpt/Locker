const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || '/api';

type FetchOptions = RequestInit & {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    data?: Record<string, any>;
};

export async function apiFetch(endpoint: string, options: FetchOptions = {}) {
    const { data, headers: customHeaders, ...restOptions } = options;

    const headers = {
        'Content-Type': 'application/json',
        ...customHeaders,
    };

    const config: RequestInit = {
        ...restOptions,
        headers,
    };

    if (data) config.body = JSON.stringify(data);

    return fetch(`${API_BASE_URL}${endpoint}`, config);
}

export const api = {
    get: (url: string) => apiFetch(url),
    post: (url: string, data?: Record<string, unknown>) => apiFetch(url, { method: 'POST', data }),
};