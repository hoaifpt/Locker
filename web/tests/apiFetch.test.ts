import assert from 'node:assert/strict';
import { fileURLToPath } from 'node:url';
import test from 'node:test';

import { createServer } from 'vite';

test('returns a login 401 without refreshing tokens or reloading the login page', async () => {
  const originalFetch = globalThis.fetch;
  const originalLocalStorage = globalThis.localStorage;
  const originalWindow = globalThis.window;
  let fetchCalls = 0;

  const vite = await createServer({
    root: fileURLToPath(new URL('../', import.meta.url)),
    server: { middlewareMode: true },
    appType: 'custom',
  });

  Object.defineProperty(globalThis, 'localStorage', {
    configurable: true,
    value: {
      getItem: () => null,
      setItem: () => undefined,
      removeItem: () => undefined,
    },
  });
  Object.defineProperty(globalThis, 'window', {
    configurable: true,
    value: { location: { href: '/before-login-request' } },
  });
  globalThis.fetch = async () => {
    fetchCalls += 1;
    return new Response(JSON.stringify({ message: 'Sai mật khẩu.' }), {
      status: 401,
      headers: { 'Content-Type': 'application/json' },
    });
  };

  try {
    const { apiFetch } = await vite.ssrLoadModule('/src/lib/api.ts');
    const response = await apiFetch('/auth/login', {
      method: 'POST',
      data: { identifier: 'user', password: 'wrong' },
    });

    assert.equal(response.status, 401);
    assert.equal(fetchCalls, 1);
    assert.equal(globalThis.window.location.href, '/before-login-request');
  } finally {
    await vite.close();
    globalThis.fetch = originalFetch;
    Object.defineProperty(globalThis, 'localStorage', {
      configurable: true,
      value: originalLocalStorage,
    });
    Object.defineProperty(globalThis, 'window', {
      configurable: true,
      value: originalWindow,
    });
  }
});
