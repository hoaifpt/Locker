/**
 * API Endpoints constants for frontend
 * Frontend can easily use these constants to construct API URLs
 */

const API_BASE = '/api';

export const API_ENDPOINTS = {
  auth: {
    login: `${API_BASE}/auth/login`,
    register: `${API_BASE}/auth/register`,
    verifyEmail: `${API_BASE}/auth/verify-email`,
    resendVerification: `${API_BASE}/auth/resend-verification`,
    refresh: `${API_BASE}/auth/refresh`,
    logout: `${API_BASE}/auth/logout`,
    logoutAll: `${API_BASE}/auth/logout-all`,
    forgotPassword: `${API_BASE}/auth/forgot-password`,
    resetPassword: `${API_BASE}/auth/reset-password`,
  },

  users: {
    getMe: `${API_BASE}/users/me`,
    updateMe: `${API_BASE}/users/me`,
    changePassword: `${API_BASE}/users/me/change-password`,
  },

  lockers: {
    getAll: `${API_BASE}/lockers`,
    create: `${API_BASE}/lockers`,
    getById: (id: string) => `${API_BASE}/lockers/${id}`,
    update: (id: string) => `${API_BASE}/lockers/${id}`,
    delete: (id: string) => `${API_BASE}/lockers/${id}`,
    getAvailable: `${API_BASE}/lockers/available`,
    updateSlotStatus: (id: string, slotIndex: number) =>
      `${API_BASE}/lockers/${id}/slots/${slotIndex}/status`,
  },

  bookings: {
    getById: (id: string) => `${API_BASE}/bookings/${id}`,
    getMy: `${API_BASE}/bookings/my`,
    create: `${API_BASE}/bookings`,
    setPin: (id: string) => `${API_BASE}/bookings/${id}/set-pin`,
    verifyPin: (id: string) => `${API_BASE}/bookings/${id}/verify-pin`,
    complete: (id: string) => `${API_BASE}/bookings/${id}/complete`,
    cancel: (id: string) => `${API_BASE}/bookings/${id}/cancel`,
  },

  packages: {
    getAll: `${API_BASE}/packages`,
    create: `${API_BASE}/packages`,
    getById: (id: string) => `${API_BASE}/packages/${id}`,
    update: (id: string) => `${API_BASE}/packages/${id}`,
    delete: (id: string) => `${API_BASE}/packages/${id}`,
  },

  payments: {
    getById: (id: string) => `${API_BASE}/payments/${id}`,
    getByBookingId: (bookingId: string) => `${API_BASE}/payments/booking/${bookingId}`,
    getMy: `${API_BASE}/payments/my`,
    create: `${API_BASE}/payments`,
    complete: (id: string) => `${API_BASE}/payments/${id}/complete`,
  },

  admin: {
    users: {
      getAll: `${API_BASE}/admin/users`,
      updateRole: (id: string) => `${API_BASE}/admin/users/${id}/role`,
      deactivate: (id: string) => `${API_BASE}/admin/users/${id}/deactivate`,
      activate: (id: string) => `${API_BASE}/admin/users/${id}/activate`,
    },
    bookings: {
      getAll: `${API_BASE}/admin/bookings`,
    },
    payments: {
      getAll: `${API_BASE}/admin/payments`,
    },
  },

  health: {
    check: `${API_BASE}/health`,
  },
};

// Helper function to build URL with query parameters
export const buildUrl = (
  endpoint: string,
  params?: Record<string, string | number | boolean>
): string => {
  if (!params || Object.keys(params).length === 0) {
    return endpoint;
  }

  const searchParams = new URLSearchParams();
  Object.entries(params).forEach(([key, value]) => {
    searchParams.append(key, String(value));
  });

  return `${endpoint}?${searchParams.toString()}`;
};

// Example usage in frontend:
// import { API_ENDPOINTS, buildUrl } from '@/constants/api-endpoints'
//
// GET request:
// fetch(API_ENDPOINTS.users.getMe)
//
// With ID parameter:
// fetch(API_ENDPOINTS.lockers.getById('locker-123'))
//
// With query parameters:
// fetch(buildUrl(API_ENDPOINTS.bookings.getMy, { status: 'Active' }))
//
// POST request:
// fetch(API_ENDPOINTS.auth.login, {
//   method: 'POST',
//   headers: { 'Content-Type': 'application/json' },
//   body: JSON.stringify(loginData)
// })
