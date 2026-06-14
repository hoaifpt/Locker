# API Test Tool Design

**Date:** 2026-06-10  
**Status:** Approved

## Overview

Tool test API dạng web app (React) để test tất cả 10 luồng API của hệ thống Locker. Backend sử dụng .NET, giao tiếp qua REST API với JWT Bearer Token authentication.

---

## UI Structure

### Layout: Sidebar + Main Area

```
┌─────────────────────────────────────────────────────────────┐
│ Header: [Logo] API Test Tool    [Base URL] [Token Status]  │
├──────────────┬──────────────────────────────────────────────┤
│              │                                              │
│  Sidebar     │  Main Area                                   │
│              │                                              │
│  ▼ Auth      │  [Flow Name]                                 │
│    Login     │  ┌─────────────────────────────────────────┐ │
│    Register  │  │ Request Form                            │ │
│    Refresh   │  │ - Endpoint: POST /api/auth/login        │ │
│    Logout    │  │ - Body: { email, password }             │ │
│              │  │                                         │ │
│  ▼ User      │  │ [Send Request]                          │ │
│    Profile   │  └─────────────────────────────────────────┘ │
│    Update    │                                              │
│    Change PW  │  Response Panel                              │
│              │  ┌─────────────────────────────────────────┐ │
│  ▼ Locker    │  │ Status: 200 OK                          │ │
│    Get All   │  │ Time: 150ms                            │ │
│    Available │  │ { "token": "...", ... }                │ │
│    Details   │  │                                         │ │
│    Open Slot │  └─────────────────────────────────────────┘ │
│              │                                              │
│  ... (10 flows)                                            │
│              │                                              │
└──────────────┴──────────────────────────────────────────────┘
```

---

## Authentication

### Header Auth Section
- **Login Form**: Email + Password → gọi `POST /api/auth/login` → lưu token vào state
- **Manual Token**: Textbox cho phép paste token thủ công
- **Token Display**: Decode và hiển thị user info từ JWT payload
- **Logout**: Clear token khỏi state

---

## API Flows

| # | Flow | Endpoints |
|---|------|-----------|
| 1 | **Auth** | POST /api/auth/register, /login, /refresh, /logout |
| 2 | **User** | GET/PUT /api/users/profile, PUT /api/users/change-password |
| 3 | **Locker** | GET /api/lockers, /available, GET /{id}, POST /{id}/open |
| 4 | **Booking** | POST /api/bookings, PUT /{id}/pin, POST /{id}/verify-pin, PUT /{id}/complete, /{id}/cancel |
| 5 | **Order (Locker)** | Reserve → Payment → Confirm → SetPin → Activate → Open → Complete, Cancel, Extend |
| 6 | **Wallet** | GET /api/wallet/balance, /transactions, POST /topup, /transfer |
| 7 | **Food Order** | GET /api/food/restaurants, /{id}/menu, POST /orders |
| 8 | **Delivery** | POST /api/deliveries, GET /{id}, PUT /{id}/status |
| 9 | **Send/Receive** | POST /api/send, GET /receive, PUT /{id}/confirm, /{id}/complete |
| 10 | **Admin** | GET /api/admin/dashboard, /lockers, /payments |

---

## Features

1. **Request Builder**: Form động theo endpoint (body params, query params)
2. **Response Viewer**: JSON syntax highlight, collapsible tree, copy button
3. **Request History**: Lưu lịch sử request trong session (localStorage)
4. **Environment Variables**: Base URL có thể thay đổi từ header
5. **Auto-populate**: Điền sẵn request body từ flow definition

---

## Technical Stack

- **Framework**: React + TypeScript (Vite)
- **HTTP Client**: Axios hoặc fetch API
- **State Management**: React useState/useContext
- **Styling**: Tailwind CSS
- **JSON Viewer**: react-json-view-lite hoặc tự implement

---

## File Structure

```
api-test-tool/
├── src/
│   ├── components/
│   │   ├── Header/
│   │   │   ├── Header.tsx
│   │   │   ├── AuthForm.tsx
│   │   │   └── TokenDisplay.tsx
│   │   ├── Sidebar/
│   │   │   ├── Sidebar.tsx
│   │   │   └── FlowMenu.tsx
│   │   ├── RequestPanel/
│   │   │   ├── RequestPanel.tsx
│   │   │   ├── EndpointSelector.tsx
│   │   │   ├── RequestBodyEditor.tsx
│   │   │   └── QueryParamsEditor.tsx
│   │   └── ResponsePanel/
│   │       ├── ResponsePanel.tsx
│   │       ├── JsonViewer.tsx
│   │       └── ResponseHeaders.tsx
│   ├── flows/
│   │   ├── auth.ts
│   │   ├── user.ts
│   │   ├── locker.ts
│   │   ├── booking.ts
│   │   ├── order.ts
│   │   ├── wallet.ts
│   │   ├── food.ts
│   │   ├── delivery.ts
│   │   ├── sendReceive.ts
│   │   └── admin.ts
│   ├── context/
│   │   └── AuthContext.tsx
│   ├── hooks/
│   │   └── useApiClient.ts
│   ├── types/
│   │   └── index.ts
│   ├── App.tsx
│   └── main.tsx
├── index.html
├── package.json
├── vite.config.ts
└── tailwind.config.js
```

---

## Component Details

### Header
- Logo + title
- Base URL input (editable)
- Auth section: Login form + Token display
- State: token, userInfo

### Sidebar
- Collapsible menu groups
- Each flow as a group with sub-items
- Click to select endpoint → populate RequestPanel

### RequestPanel
- HTTP Method dropdown (GET, POST, PUT, DELETE, PATCH)
- Endpoint path (readonly, populated from selection)
- Tabs: Params | Body | Headers
- Body editor với JSON syntax highlighting
- Send button

### ResponsePanel
- Status badge (color-coded: green=2xx, yellow=3xx, red=4xx/5xx)
- Response time
- Tabs: Body | Headers
- JSON tree view collapsible
- Copy button

---

## Data Flow

1. User chọn flow từ Sidebar
2. RequestPanel hiển thị form với pre-filled data
3. User điều chỉnh params nếu cần
4. User click Send
5. useApiClient hook gọi API với token từ AuthContext
6. Response hiển thị trong ResponsePanel
7. Request được lưu vào history (localStorage)

---

## Error Handling

- Network error: Hiển thị message + retry button
- 401 Unauthorized: Prompt re-login
- 400 Bad Request: Hiển thị validation errors từ response
- Timeout: Configurable timeout (default 30s), show timeout message

---

## Success Criteria

- [ ] UI responsive, clean design
- [ ] Có thể test tất cả 10 flows
- [ ] Login form hoạt động, lưu token
- [ ] Manual token input hoạt động
- [ ] Response hiển thị đúng format
- [ ] Request history được lưu
