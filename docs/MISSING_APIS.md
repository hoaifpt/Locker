# Missing APIs and Mobile Integration Checklist

This document lists backend endpoints that are missing or incomplete for the current mobile app, maps mobile screens to required APIs, sets priorities, and provides short request/response examples and notes for implementation.

---

## Summary

- Backend: implement core endpoints for locker map, open/unlock, locker settings, notifications, and payment webhook/reconciliation. Add device/firmware callbacks and security (rate-limit, audit).  
- Mobile: update endpoint constants, migrate mocks to network calls (orders, payments), add notification device-token registration, and guard/open flows.

---

## Backend — Missing / Needed Endpoints (with priority)

1. GET `/api/lockers/map`  (Priority: High)
   - Purpose: Return list of locker slots with status for the map UI.
   - Response (200):
     ```json
     [
       {
         "lockerId": "locker-001",
         "slotIndex": 0,
         "size": "M",
         "status": "Available", // Available, Occupied, Reserved, Fault
         "sensorState": "Closed",
         "hubLocation": "Main Hall"
       }
     ]
     ```
   - Auth: public or token depending on privacy.

2. POST `/api/lockers/{id}/open`  (Priority: High)
   - Purpose: Trigger open of a locker from mobile (map/detail).
   - Request (POST):
     ```json
     { "slotIndex": 0, "reason": "user_request" }
     ```
   - Response: 204 No Content or 400/403 with message.
   - Auth & Authorization: Must verify user owns active booking/order for that slot or has role `Admin|Shipper`.
   - Notes: add audit log, rate-limit (per-user & per-locker), return operation id if async.

3. PATCH `/api/lockers/{id}/settings`  (Priority: Medium)
   - Purpose: Update locker settings (auto-lock / intrusion alarm).
   - Request body (PATCH):
     ```json
     { "isAutoLockEnabled": true, "isIntrusionAlertEnabled": false }
     ```
   - Response: 200 with updated locker detail or 204.
   - Auth: Admin or hub owner.

4. Notifications endpoints (Priority: Medium)
   - GET `/api/notifications/my` — list notifications for current user.
   - POST `/api/notifications/{id}/mark-as-read` — mark single notification.
   - POST `/api/notifications/mark-all-as-read` — mark all.
   - POST `/api/notifications/register-device` — register device token for push. (body: `{ deviceToken, platform }`)

5. Payments / Webhooks (Priority: High)
   - Implement payment gateway webhook endpoint to reconcile payments and mark orders/bookings paid.
   - Complete backend logic for `POST /api/orders/{id}/payment` (currently stubbed).
   - Ensure idempotency and security (signature verification) for webhooks.

6. Firmware / Device callbacks (Priority: High)
   - Provide secure callback or webhook for firmware to confirm slot open events and status updates; complement existing `POST /api/lockers/{id}/slots/{slotIndex}/status`.

7. Optional improvements (Priority: Low–Medium)
   - Pagination/filters for `GET /api/lockers`, `GET /api/packages`.
   - Add metrics/logging and request validation for critical endpoints.

---

## Mobile — Required Changes / Missing Client Work (with priority)

1. Update API constants
   - Add constants for:
     - `/api/lockers/map`
     - `/api/lockers/{id}/open`
     - `/api/lockers/{id}/settings`
     - `/api/notifications/*` endpoints
   - Location: `mobile/lib/core/constants/api_endpoints.dart` (High)

2. Replace mocks with network calls (Medium → High when BE ready)
   - `OrdersRepository` (currently mock) → call `/api/orders` or `/api/bookings` depending on flow.
   - `SendReceiveRepository`, `PaymentSuccessRepository`, `LockerOverdueRepository` → replace or add adapters to call BE endpoints.

3. Locker open flow (High)
   - `locker_map_screen` and `locker_detail_screen` must call `POST /api/lockers/{id}/open`.
   - UI must verify user has booking/order or present reserve/payment flow if not.
   - Add exponential backoff and UX for open failure, and handle 403/401/429.

4. Notifications client (Medium)
   - Register device token on backend via `POST /api/notifications/register-device`.
   - Use `GET /api/notifications/my` and mark-as-read endpoints.

5. Payment integration (High)
   - Use `POST /api/payments` to create payment, handle redirect or in-app flow, then rely on webhook or `POST /api/payments/{id}/complete` to finalize.
   - Update `payment_success` flow to be driven by server-confirmed payment status.

6. Auth robustness (High)
   - Ensure `AuthRepository.refreshToken()` is used automatically on 401 and original requests retried.
   - Ensure logout calls `/auth/logout` with refresh token when desired.

7. Security & UX (Medium)
   - Add client-side debounce for open requests. Show clear error states for 403/401/429.

---

## Per-screen quick mapping (high-level)

- `locker_map_screen` → `GET /api/lockers/map`, `POST /api/lockers/{id}/open`  
- `locker_detail_screen` → `GET /api/lockers/{id}`, `POST /api/lockers/{id}/open`, `PATCH /api/lockers/{id}/settings`  
- `home_screen` → `GET /api/bookings/my?status=Active`, `GET /api/lockers/available`  
- `auth/login_screen` → `/api/auth/*` (login, refresh, logout, forgot/reset)  
- `send_receive` flows → `POST /api/bookings` or order reserve + payment flow  
- `orders` / history → `/api/orders/my`, `/api/orders/{id}` and order actions  
- `profile` → `/api/users/me`, `PUT /api/users/me`, `/api/users/me/change-password`  
- `notifications` UI → `/api/notifications/*`

---

## Example API contract snippets (suggested)

1) POST `/api/lockers/{id}/open`
- Request headers: `Authorization: Bearer <token>`
- Body:
  ```json
  { "slotIndex": 0, "reason": "user_request" }
  ```
- Responses:
  - `204 No Content` — opened (or queued)  
  - `403 Forbidden` — user not authorized  
  - `404 Not Found` — locker/slot not found  
  - `429 Too Many Requests` — rate limit

2) GET `/api/lockers/map`
- Query: optional `?hubId=...`
- Response: array of slot objects (see earlier example)

3) POST `/api/notifications/register-device`
- Body:
  ```json
  { "deviceToken": "abc", "platform": "android" }
  ```

---

## Recommended implementation plan (short)

1. BE: implement `/api/lockers/map`, `/api/lockers/{id}/open`, payment webhook, notifications. Add tests for open authorization. (2–3 sprint days)
2. Mobile: update constants and wire `locker_map` & `locker_detail` to `open` and `map` endpoints; replace mocks for orders/payments. (1–2 sprint days after BE)
3. Cross-team: define payment webhook security (signature) and test with staging payment gateway. (1 sprint day)

---

If you want, I can also:  
- generate controller stubs for the backend (C#) under `src/Locker.Backend/Controllers` with TODOs, or  
- produce a formal OpenAPI spec (YAML) for the missing endpoints.

Created by automation — review and adjust authorization rules to match your domain logic.
