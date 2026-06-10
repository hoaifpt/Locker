# API Test Tool Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a web-based API testing tool for testing all 10 API flows in the Locker backend system.

**Architecture:** React + TypeScript SPA with Vite, using Tailwind CSS for styling. JWT authentication with both login form and manual token input. Request/response handled via useApiClient custom hook with AuthContext for global token state.

**Tech Stack:** React 18, TypeScript, Vite, Tailwind CSS, Axios

---

## File Structure

```
api-test-tool/
├── index.html
├── package.json
├── vite.config.ts
├── tailwind.config.js
├── tsconfig.json
└── src/
    ├── main.tsx
    ├── App.tsx
    ├── index.css
    ├── types/
    │   └── index.ts
    ├── context/
    │   └── AuthContext.tsx
    ├── hooks/
    │   └── useApiClient.ts
    ├── flows/
    │   ├── auth.ts
    │   ├── user.ts
    │   ├── locker.ts
    │   ├── booking.ts
    │   ├── order.ts
    │   ├── wallet.ts
    │   ├── food.ts
    │   ├── delivery.ts
    │   ├── sendReceive.ts
    │   └── admin.ts
    └── components/
        ├── Header/
        │   ├── Header.tsx
        │   ├── AuthForm.tsx
        │   └── TokenDisplay.tsx
        ├── Sidebar/
        │   ├── Sidebar.tsx
        │   └── FlowMenu.tsx
        ├── RequestPanel/
        │   ├── RequestPanel.tsx
        │   └── RequestBodyEditor.tsx
        └── ResponsePanel/
            ├── ResponsePanel.tsx
            └── JsonViewer.tsx
```

---

## Tasks

### Task 1: Project Setup

**Files:**
- Create: `api-test-tool/package.json`
- Create: `api-test-tool/vite.config.ts`
- Create: `api-test-tool/tsconfig.json`
- Create: `api-test-tool/tailwind.config.js`
- Create: `api-test-tool/index.html`
- Create: `api-test-tool/src/main.tsx`
- Create: `api-test-tool/src/index.css`
- Create: `api-test-tool/src/App.tsx`

- [ ] **Step 1: Create package.json**

```json
{
  "name": "api-test-tool",
  "private": true,
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "tsc && vite build",
    "preview": "vite preview"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "axios": "^1.6.0",
    "react-icons": "^4.12.0"
  },
  "devDependencies": {
    "@types/react": "^18.2.43",
    "@types/react-dom": "^18.2.17",
    "@vitejs/plugin-react": "^4.2.1",
    "autoprefixer": "^10.4.16",
    "postcss": "^8.4.32",
    "tailwindcss": "^3.3.6",
    "typescript": "^5.2.2",
    "vite": "^5.0.8"
  }
}
```

- [ ] **Step 2: Create vite.config.ts**

```typescript
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    port: 3000,
    open: true
  }
})
```

- [ ] **Step 3: Create tsconfig.json**

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx",
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true
  },
  "include": ["src"],
  "references": [{ "path": "./tsconfig.node.json" }]
}
```

- [ ] **Step 4: Create tsconfig.node.json**

```json
{
  "compilerOptions": {
    "composite": true,
    "skipLibCheck": true,
    "module": "ESNext",
    "moduleResolution": "bundler",
    "allowSyntheticDefaultImports": true
  },
  "include": ["vite.config.ts"]
}
```

- [ ] **Step 5: Create tailwind.config.js**

```javascript
/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
```

- [ ] **Step 6: Create postcss.config.js**

```javascript
export default {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
```

- [ ] **Step 7: Create index.html**

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <link rel="icon" type="image/svg+xml" href="/vite.svg" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>API Test Tool</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
```

- [ ] **Step 8: Create src/main.tsx**

```typescript
import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App'
import './index.css'

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
)
```

- [ ] **Step 9: Create src/index.css**

```css
@tailwind base;
@tailwind components;
@tailwind utilities;

body {
  margin: 0;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}
```

- [ ] **Step 10: Create src/App.tsx**

```typescript
import { useState } from 'react'
import { AuthProvider } from './context/AuthContext'
import Header from './components/Header/Header'
import Sidebar from './components/Sidebar/Sidebar'
import RequestPanel from './components/RequestPanel/RequestPanel'
import ResponsePanel from './components/ResponsePanel/ResponsePanel'
import { FlowEndpoint } from './types'

function App() {
  const [selectedEndpoint, setSelectedEndpoint] = useState<FlowEndpoint | null>(null)
  const [response, setResponse] = useState<{
    status: number
    data: unknown
    time: number
    headers?: Record<string, string>
  } | null>(null)

  return (
    <AuthProvider>
      <div className="h-screen flex flex-col bg-gray-50">
        <Header />
        <div className="flex-1 flex overflow-hidden">
          <Sidebar onSelectEndpoint={setSelectedEndpoint} />
          <main className="flex-1 flex flex-col p-4 overflow-auto">
            <div className="flex-1 grid grid-cols-1 lg:grid-cols-2 gap-4">
              <RequestPanel
                selectedEndpoint={selectedEndpoint}
                onResponse={setResponse}
              />
              <ResponsePanel response={response} />
            </div>
          </main>
        </div>
      </div>
    </AuthProvider>
  )
}

export default App
```

- [ ] **Step 11: Install dependencies**

Run: `cd api-test-tool && npm install`

---

### Task 2: Types and Context

**Files:**
- Create: `api-test-tool/src/types/index.ts`
- Create: `api-test-tool/src/context/AuthContext.tsx`

- [ ] **Step 1: Create src/types/index.ts**

```typescript
export interface FlowEndpoint {
  id: string
  name: string
  method: 'GET' | 'POST' | 'PUT' | 'DELETE' | 'PATCH'
  path: string
  description?: string
  bodyTemplate?: Record<string, unknown>
  queryParams?: { name: string; required: boolean; description?: string }[]
  requiresAuth?: boolean
}

export interface FlowGroup {
  id: string
  name: string
  icon: string
  endpoints: FlowEndpoint[]
}

export interface ApiResponse {
  status: number
  data: unknown
  time: number
  headers?: Record<string, string>
}

export interface AuthState {
  token: string | null
  user: { id: string; email: string; role: string } | null
  login: (email: string, password: string) => Promise<void>
  loginWithToken: (token: string) => void
  logout: () => void
}
```

- [ ] **Step 2: Create src/context/AuthContext.tsx**

```typescript
import { createContext, useContext, useState, useCallback, ReactNode } from 'react'
import axios from 'axios'
import { AuthState } from '../types'

const AuthContext = createContext<AuthState | null>(null)

export function useAuth() {
  const context = useContext(AuthContext)
  if (!context) {
    throw new Error('useAuth must be used within AuthProvider')
  }
  return context
}

interface AuthProviderProps {
  children: ReactNode
}

export function AuthProvider({ children }: AuthProviderProps) {
  const [token, setToken] = useState<string | null>(() => localStorage.getItem('api_token'))
  const [user, setUser] = useState<{ id: string; email: string; role: string } | null>(() => {
    const savedToken = localStorage.getItem('api_token')
    if (savedToken) {
      try {
        const payload = JSON.parse(atob(savedToken.split('.')[1]))
        return { id: payload.sub || payload.nameid, email: payload.email, role: payload.role || payload['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'] }
      } catch {
        return null
      }
    }
    return null
  })

  const login = useCallback(async (email: string, password: string) => {
    const baseUrl = localStorage.getItem('base_url') || 'http://localhost:5000'
    const response = await axios.post(`${baseUrl}/api/auth/login`, { email, password })
    const { token: newToken } = response.data
    setToken(newToken)
    setUserFromToken(newToken)
    localStorage.setItem('api_token', newToken)
  }, [])

  const setUserFromToken = (newToken: string) => {
    try {
      const payload = JSON.parse(atob(newToken.split('.')[1]))
      setUser({ id: payload.sub || payload.nameid, email: payload.email, role: payload.role || payload['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'] })
    } catch {
      setUser(null)
    }
  }

  const loginWithToken = useCallback((newToken: string) => {
    setToken(newToken)
    setUserFromToken(newToken)
    localStorage.setItem('api_token', newToken)
  }, [])

  const logout = useCallback(() => {
    setToken(null)
    setUser(null)
    localStorage.removeItem('api_token')
  }, [])

  return (
    <AuthContext.Provider value={{ token, user, login, loginWithToken, logout }}>
      {children}
    </AuthContext.Provider>
  )
}
```

- [ ] **Step 3: Commit**

Run: `git add -A && git commit -m "feat: Add types and AuthContext"`

---

### Task 3: Flow Definitions

**Files:**
- Create: `api-test-tool/src/flows/auth.ts`
- Create: `api-test-tool/src/flows/user.ts`
- Create: `api-test-tool/src/flows/locker.ts`
- Create: `api-test-tool/src/flows/booking.ts`
- Create: `api-test-tool/src/flows/order.ts`
- Create: `api-test-tool/src/flows/wallet.ts`
- Create: `api-test-tool/src/flows/food.ts`
- Create: `api-test-tool/src/flows/delivery.ts`
- Create: `api-test-tool/src/flows/sendReceive.ts`
- Create: `api-test-tool/src/flows/admin.ts`
- Create: `api-test-tool/src/flows/index.ts`

- [ ] **Step 1: Create src/flows/auth.ts**

```typescript
import { FlowGroup } from '../types'

export const authFlow: FlowGroup = {
  id: 'auth',
  name: 'Authentication',
  icon: '🔐',
  endpoints: [
    {
      id: 'auth-login',
      name: 'Login',
      method: 'POST',
      path: '/api/auth/login',
      description: 'Login with email and password',
      bodyTemplate: { email: '', password: '' },
      requiresAuth: false,
    },
    {
      id: 'auth-register',
      name: 'Register',
      method: 'POST',
      path: '/api/auth/register',
      description: 'Register new user',
      bodyTemplate: { email: '', password: '', confirmPassword: '', fullName: '' },
      requiresAuth: false,
    },
    {
      id: 'auth-refresh',
      name: 'Refresh Token',
      method: 'POST',
      path: '/api/auth/refresh',
      description: 'Refresh access token',
      requiresAuth: true,
    },
    {
      id: 'auth-logout',
      name: 'Logout',
      method: 'POST',
      path: '/api/auth/logout',
      description: 'Logout user',
      requiresAuth: true,
    },
  ],
}
```

- [ ] **Step 2: Create src/flows/user.ts**

```typescript
import { FlowGroup } from '../types'

export const userFlow: FlowGroup = {
  id: 'user',
  name: 'User',
  icon: '👤',
  endpoints: [
    {
      id: 'user-profile',
      name: 'Get Profile',
      method: 'GET',
      path: '/api/users/profile',
      description: 'Get current user profile',
      requiresAuth: true,
    },
    {
      id: 'user-update',
      name: 'Update Profile',
      method: 'PUT',
      path: '/api/users/profile',
      description: 'Update user profile',
      bodyTemplate: { fullName: '', phoneNumber: '' },
      requiresAuth: true,
    },
    {
      id: 'user-change-password',
      name: 'Change Password',
      method: 'PUT',
      path: '/api/users/change-password',
      description: 'Change user password',
      bodyTemplate: { currentPassword: '', newPassword: '' },
      requiresAuth: true,
    },
  ],
}
```

- [ ] **Step 3: Create src/flows/locker.ts**

```typescript
import { FlowGroup } from '../types'

export const lockerFlow: FlowGroup = {
  id: 'locker',
  name: 'Locker',
  icon: '📦',
  endpoints: [
    {
      id: 'locker-get-all',
      name: 'Get All Lockers',
      method: 'GET',
      path: '/api/lockers',
      description: 'Get all lockers',
      requiresAuth: false,
    },
    {
      id: 'locker-available',
      name: 'Get Available Lockers',
      method: 'GET',
      path: '/api/lockers/available',
      description: 'Get available lockers',
      queryParams: [{ name: 'size', required: false, description: 'Locker size filter' }],
      requiresAuth: false,
    },
    {
      id: 'locker-details',
      name: 'Get Locker Details',
      method: 'GET',
      path: '/api/lockers/{id}',
      description: 'Get specific locker by ID',
      queryParams: [{ name: 'id', required: true, description: 'Locker ID' }],
      requiresAuth: false,
    },
    {
      id: 'locker-open',
      name: 'Open Locker',
      method: 'POST',
      path: '/api/lockers/{id}/open',
      description: 'Open a locker slot',
      bodyTemplate: { slotNumber: 1 },
      requiresAuth: true,
    },
  ],
}
```

- [ ] **Step 4: Create src/flows/booking.ts**

```typescript
import { FlowGroup } from '../types'

export const bookingFlow: FlowGroup = {
  id: 'booking',
  name: 'Booking',
  icon: '📅',
  endpoints: [
    {
      id: 'booking-create',
      name: 'Create Booking',
      method: 'POST',
      path: '/api/bookings',
      description: 'Create new booking',
      bodyTemplate: { lockerId: '', slotNumber: 1, size: 'Small', duration: 60 },
      requiresAuth: true,
    },
    {
      id: 'booking-set-pin',
      name: 'Set PIN',
      method: 'PUT',
      path: '/api/bookings/{id}/pin',
      description: 'Set booking PIN',
      bodyTemplate: { pin: '1234' },
      requiresAuth: true,
    },
    {
      id: 'booking-verify-pin',
      name: 'Verify PIN',
      method: 'POST',
      path: '/api/bookings/{id}/verify-pin',
      description: 'Verify booking PIN',
      bodyTemplate: { pin: '1234' },
      requiresAuth: false,
    },
    {
      id: 'booking-complete',
      name: 'Complete Booking',
      method: 'PUT',
      path: '/api/bookings/{id}/complete',
      description: 'Mark booking as complete',
      requiresAuth: true,
    },
    {
      id: 'booking-cancel',
      name: 'Cancel Booking',
      method: 'PUT',
      path: '/api/bookings/{id}/cancel',
      description: 'Cancel a booking',
      requiresAuth: true,
    },
  ],
}
```

- [ ] **Step 5: Create src/flows/order.ts**

```typescript
import { FlowGroup } from '../types'

export const orderFlow: FlowGroup = {
  id: 'order',
  name: 'Order (Locker)',
  icon: '🛒',
  endpoints: [
    {
      id: 'order-reserve',
      name: 'Reserve Locker',
      method: 'POST',
      path: '/api/orders/reserve',
      description: 'Reserve a locker slot',
      bodyTemplate: { lockerId: '', slotNumber: 1, size: 'Small', duration: 60 },
      requiresAuth: true,
    },
    {
      id: 'order-init-payment',
      name: 'Initialize Payment',
      method: 'POST',
      path: '/api/orders/{orderId}/init-payment',
      description: 'Initialize payment for order',
      bodyTemplate: { paymentMethod: 'VnPay' },
      requiresAuth: true,
    },
    {
      id: 'order-confirm-payment',
      name: 'Confirm Payment',
      method: 'POST',
      path: '/api/orders/{orderId}/confirm-payment',
      description: 'Confirm payment callback',
      bodyTemplate: { transactionId: '', amount: 0 },
      requiresAuth: false,
    },
    {
      id: 'order-set-pin',
      name: 'Set PIN',
      method: 'PUT',
      path: '/api/orders/{orderId}/pin',
      description: 'Set order PIN',
      bodyTemplate: { pin: '1234' },
      requiresAuth: true,
    },
    {
      id: 'order-activate',
      name: 'Activate Order',
      method: 'POST',
      path: '/api/orders/{orderId}/activate',
      description: 'Activate order to open locker',
      bodyTemplate: { pin: '1234' },
      requiresAuth: false,
    },
    {
      id: 'order-complete',
      name: 'Complete Order',
      method: 'PUT',
      path: '/api/orders/{orderId}/complete',
      description: 'Mark order as complete',
      requiresAuth: true,
    },
    {
      id: 'order-cancel',
      name: 'Cancel Order',
      method: 'PUT',
      path: '/api/orders/{orderId}/cancel',
      description: 'Cancel an order',
      bodyTemplate: { reason: '' },
      requiresAuth: true,
    },
    {
      id: 'order-extend',
      name: 'Extend Order',
      method: 'PUT',
      path: '/api/orders/{orderId}/extend',
      description: 'Extend order duration',
      bodyTemplate: { additionalMinutes: 30 },
      requiresAuth: true,
    },
  ],
}
```

- [ ] **Step 6: Create src/flows/wallet.ts**

```typescript
import { FlowGroup } from '../types'

export const walletFlow: FlowGroup = {
  id: 'wallet',
  name: 'Wallet',
  icon: '💰',
  endpoints: [
    {
      id: 'wallet-balance',
      name: 'Get Balance',
      method: 'GET',
      path: '/api/wallet/balance',
      description: 'Get wallet balance',
      requiresAuth: true,
    },
    {
      id: 'wallet-transactions',
      name: 'Get Transactions',
      method: 'GET',
      path: '/api/wallet/transactions',
      description: 'Get transaction history',
      queryParams: [
        { name: 'page', required: false },
        { name: 'pageSize', required: false },
      ],
      requiresAuth: true,
    },
    {
      id: 'wallet-topup',
      name: 'Top Up',
      method: 'POST',
      path: '/api/wallet/topup',
      description: 'Initialize wallet top-up',
      bodyTemplate: { amount: 100000, paymentMethod: 'VnPay' },
      requiresAuth: true,
    },
    {
      id: 'wallet-transfer',
      name: 'Transfer',
      method: 'POST',
      path: '/api/wallet/transfer',
      description: 'Transfer to another user',
      bodyTemplate: { recipientEmail: '', amount: 0 },
      requiresAuth: true,
    },
  ],
}
```

- [ ] **Step 7: Create src/flows/food.ts**

```typescript
import { FlowGroup } from '../types'

export const foodFlow: FlowGroup = {
  id: 'food',
  name: 'Food Order',
  icon: '🍔',
  endpoints: [
    {
      id: 'food-restaurants',
      name: 'Get Restaurants',
      method: 'GET',
      path: '/api/food/restaurants',
      description: 'Get all restaurants',
      requiresAuth: false,
    },
    {
      id: 'food-menu',
      name: 'Get Menu',
      method: 'GET',
      path: '/api/food/{restaurantId}/menu',
      description: 'Get restaurant menu',
      queryParams: [{ name: 'restaurantId', required: true }],
      requiresAuth: false,
    },
    {
      id: 'food-create-order',
      name: 'Create Order',
      method: 'POST',
      path: '/api/food/orders',
      description: 'Create food order',
      bodyTemplate: {
        restaurantId: '',
        items: [{ menuItemId: '', quantity: 1 }],
        deliveryAddress: '',
      },
      requiresAuth: true,
    },
  ],
}
```

- [ ] **Step 8: Create src/flows/delivery.ts**

```typescript
import { FlowGroup } from '../types'

export const deliveryFlow: FlowGroup = {
  id: 'delivery',
  name: 'Delivery',
  icon: '🚚',
  endpoints: [
    {
      id: 'delivery-create',
      name: 'Create Delivery',
      method: 'POST',
      path: '/api/deliveries',
      description: 'Create new delivery',
      bodyTemplate: {
        senderAddress: '',
        receiverAddress: '',
        packageSize: 'Medium',
      },
      requiresAuth: true,
    },
    {
      id: 'delivery-get',
      name: 'Get Delivery',
      method: 'GET',
      path: '/api/deliveries/{id}',
      description: 'Get delivery details',
      queryParams: [{ name: 'id', required: true }],
      requiresAuth: true,
    },
    {
      id: 'delivery-update-status',
      name: 'Update Status',
      method: 'PUT',
      path: '/api/deliveries/{id}/status',
      description: 'Update delivery status',
      bodyTemplate: { status: 'PickedUp' },
      requiresAuth: true,
    },
  ],
}
```

- [ ] **Step 9: Create src/flows/sendReceive.ts**

```typescript
import { FlowGroup } from '../types'

export const sendReceiveFlow: FlowGroup = {
  id: 'sendReceive',
  name: 'Send/Receive',
  icon: '📬',
  endpoints: [
    {
      id: 'send-create',
      name: 'Send Package',
      method: 'POST',
      path: '/api/send',
      description: 'Create send request',
      bodyTemplate: {
        recipientEmail: '',
        recipientPhone: '',
        lockerId: '',
        slotNumber: 1,
      },
      requiresAuth: true,
    },
    {
      id: 'receive-list',
      name: 'Get Received',
      method: 'GET',
      path: '/api/receive',
      description: 'Get list of received packages',
      requiresAuth: true,
    },
    {
      id: 'receive-confirm',
      name: 'Confirm Receive',
      method: 'PUT',
      path: '/api/send/{id}/confirm',
      description: 'Confirm package received',
      bodyTemplate: { pin: '1234' },
      requiresAuth: false,
    },
    {
      id: 'receive-complete',
      name: 'Complete Receive',
      method: 'PUT',
      path: '/api/send/{id}/complete',
      description: 'Mark receive as complete',
      requiresAuth: true,
    },
  ],
}
```

- [ ] **Step 10: Create src/flows/admin.ts**

```typescript
import { FlowGroup } from '../types'

export const adminFlow: FlowGroup = {
  id: 'admin',
  name: 'Admin',
  icon: '⚙️',
  endpoints: [
    {
      id: 'admin-dashboard',
      name: 'Dashboard',
      method: 'GET',
      path: '/api/admin/dashboard',
      description: 'Get admin dashboard data',
      requiresAuth: true,
    },
    {
      id: 'admin-lockers',
      name: 'Manage Lockers',
      method: 'GET',
      path: '/api/admin/lockers',
      description: 'Get all lockers for admin',
      requiresAuth: true,
    },
    {
      id: 'admin-payments',
      name: 'Payment History',
      method: 'GET',
      path: '/api/admin/payments',
      description: 'Get all payments',
      queryParams: [
        { name: 'page', required: false },
        { name: 'startDate', required: false },
        { name: 'endDate', required: false },
      ],
      requiresAuth: true,
    },
  ],
}
```

- [ ] **Step 11: Create src/flows/index.ts**

```typescript
import { FlowGroup } from '../types'
import { authFlow } from './auth'
import { userFlow } from './user'
import { lockerFlow } from './locker'
import { bookingFlow } from './booking'
import { orderFlow } from './order'
import { walletFlow } from './wallet'
import { foodFlow } from './food'
import { deliveryFlow } from './delivery'
import { sendReceiveFlow } from './sendReceive'
import { adminFlow } from './admin'

export const allFlows: FlowGroup[] = [
  authFlow,
  userFlow,
  lockerFlow,
  bookingFlow,
  orderFlow,
  walletFlow,
  foodFlow,
  deliveryFlow,
  sendReceiveFlow,
  adminFlow,
]

export { authFlow, userFlow, lockerFlow, bookingFlow, orderFlow, walletFlow, foodFlow, deliveryFlow, sendReceiveFlow, adminFlow }
```

- [ ] **Step 12: Commit**

Run: `git add -A && git commit -m "feat: Add all 10 API flow definitions"`

---

### Task 4: useApiClient Hook

**Files:**
- Create: `api-test-tool/src/hooks/useApiClient.ts`

- [ ] **Step 1: Create src/hooks/useApiClient.ts**

```typescript
import { useCallback } from 'react'
import axios, { AxiosRequestConfig } from 'axios'
import { useAuth } from '../context/AuthContext'

interface ApiResponse {
  status: number
  data: unknown
  time: number
  headers?: Record<string, string>
}

export function useApiClient() {
  const { token } = useAuth()

  const getBaseUrl = useCallback(() => {
    return localStorage.getItem('base_url') || 'http://localhost:5000'
  }, [])

  const request = useCallback(
    async (config: {
      method: 'GET' | 'POST' | 'PUT' | 'DELETE' | 'PATCH'
      path: string
      body?: Record<string, unknown>
      queryParams?: Record<string, string>
      requiresAuth?: boolean
    }): Promise<ApiResponse> => {
      const baseUrl = getBaseUrl()
      const url = new URL(config.path, baseUrl).toString()

      const headers: Record<string, string> = {
        'Content-Type': 'application/json',
      }

      if (config.requiresAuth !== false && token) {
        headers['Authorization'] = `Bearer ${token}`
      }

      if (config.queryParams) {
        const params = new URLSearchParams(config.queryParams)
        const queryString = params.toString()
        if (queryString) {
          // Handle path params like {id}
          const pathWithParams = config.path.replace(/\{(\w+)\}/g, (_, key) => {
            const value = config.queryParams![key]
            return value || `{${key}}`
          })
          return request({
            ...config,
            path: pathWithParams + '?' + queryString,
            queryParams: undefined,
          })
        }
      }

      const axiosConfig: AxiosRequestConfig = {
        method: config.method,
        url,
        headers,
        data: config.body,
      }

      const startTime = Date.now()

      try {
        const response = await axios(axiosConfig)
        const endTime = Date.now()

        return {
          status: response.status,
          data: response.data,
          time: endTime - startTime,
          headers: response.headers as Record<string, string>,
        }
      } catch (error: unknown) {
        const endTime = Date.now()
        if (axios.isAxiosError(error) && error.response) {
          return {
            status: error.response.status,
            data: error.response.data,
            time: endTime - startTime,
            headers: error.response.headers as Record<string, string>,
          }
        }
        throw error
      }
    },
    [token, getBaseUrl]
  )

  return { request }
}
```

- [ ] **Step 2: Commit**

Run: `git add -A && git commit -m "feat: Add useApiClient hook"`

---

### Task 5: Header Components

**Files:**
- Create: `api-test-tool/src/components/Header/Header.tsx`
- Create: `api-test-tool/src/components/Header/AuthForm.tsx`
- Create: `api-test-tool/src/components/Header/TokenDisplay.tsx`

- [ ] **Step 1: Create src/components/Header/AuthForm.tsx**

```typescript
import { useState } from 'react'
import { useAuth } from '../../context/AuthContext'

export default function AuthForm() {
  const { login } = useAuth()
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setError('')
    setLoading(true)

    try {
      await login(email, password)
      setEmail('')
      setPassword('')
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : 'Login failed')
    } finally {
      setLoading(false)
    }
  }

  return (
    <form onSubmit={handleSubmit} className="flex gap-2 items-end">
      <div>
        <input
          type="email"
          placeholder="Email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          className="px-3 py-1.5 text-sm border border-gray-300 rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
        />
      </div>
      <div>
        <input
          type="password"
          placeholder="Password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          className="px-3 py-1.5 text-sm border border-gray-300 rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
        />
      </div>
      <button
        type="submit"
        disabled={loading}
        className="px-4 py-1.5 text-sm bg-blue-600 text-white rounded hover:bg-blue-700 disabled:opacity-50"
      >
        {loading ? '...' : 'Login'}
      </button>
      {error && <span className="text-red-500 text-sm">{error}</span>}
    </form>
  )
}
```

- [ ] **Step 2: Create src/components/Header/TokenDisplay.tsx**

```typescript
import { useAuth } from '../../context/AuthContext'
import { FaUser, FaSignOutAlt } from 'react-icons/fa'

export default function TokenDisplay() {
  const { user, logout, token } = useAuth()

  if (!token) return null

  const handleCopyToken = () => {
    navigator.clipboard.writeText(token)
  }

  return (
    <div className="flex items-center gap-3">
      <div className="flex items-center gap-2 px-3 py-1.5 bg-green-50 border border-green-200 rounded">
        <FaUser className="text-green-600" />
        <div className="text-sm">
          <span className="font-medium text-gray-700">{user?.email || 'Unknown'}</span>
          {user?.role && <span className="ml-2 text-xs text-gray-500">({user.role})</span>}
        </div>
      </div>
      <button
        onClick={handleCopyToken}
        className="px-2 py-1 text-xs text-gray-500 hover:text-gray-700 border border-gray-300 rounded"
        title="Copy token"
      >
        Copy Token
      </button>
      <button
        onClick={logout}
        className="p-1.5 text-gray-500 hover:text-red-600"
        title="Logout"
      >
        <FaSignOutAlt />
      </button>
    </div>
  )
}
```

- [ ] **Step 3: Create src/components/Header/Header.tsx**

```typescript
import { useState, useEffect } from 'react'
import { FaServer, FaKey } from 'react-icons/fa'
import AuthForm from './AuthForm'
import TokenDisplay from './TokenDisplay'

export default function Header() {
  const [baseUrl, setBaseUrl] = useState(() => localStorage.getItem('base_url') || 'http://localhost:5000')
  const [showManualToken, setShowManualToken] = useState(false)
  const [manualToken, setManualToken] = useState('')

  useEffect(() => {
    localStorage.setItem('base_url', baseUrl)
  }, [baseUrl])

  const handleManualToken = () => {
    if (manualToken.trim()) {
      localStorage.setItem('api_token', manualToken.trim())
      window.location.reload()
    }
  }

  return (
    <header className="bg-white border-b border-gray-200 px-4 py-3">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-4">
          <h1 className="text-xl font-bold text-gray-800">API Test Tool</h1>

          <div className="flex items-center gap-2">
            <FaServer className="text-gray-400" />
            <input
              type="text"
              value={baseUrl}
              onChange={(e) => setBaseUrl(e.target.value)}
              className="px-3 py-1 text-sm border border-gray-300 rounded focus:outline-none focus:ring-2 focus:ring-blue-500 w-64"
              placeholder="Base URL"
            />
          </div>
        </div>

        <div className="flex items-center gap-4">
          <button
            onClick={() => setShowManualToken(!showManualToken)}
            className="flex items-center gap-1 px-3 py-1.5 text-sm text-gray-600 hover:text-gray-800 border border-gray-300 rounded"
          >
            <FaKey />
            Manual Token
          </button>

          <TokenDisplay />
          <AuthForm />
        </div>
      </div>

      {showManualToken && (
        <div className="mt-3 p-3 bg-gray-50 border border-gray-200 rounded">
          <div className="flex gap-2">
            <input
              type="text"
              value={manualToken}
              onChange={(e) => setManualToken(e.target.value)}
              placeholder="Paste JWT token here"
              className="flex-1 px-3 py-1.5 text-sm border border-gray-300 rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
            <button
              onClick={handleManualToken}
              className="px-4 py-1.5 text-sm bg-gray-800 text-white rounded hover:bg-gray-900"
            >
              Apply Token
            </button>
            <button
              onClick={() => {
                setShowManualToken(false)
                setManualToken('')
              }}
              className="px-3 py-1.5 text-sm text-gray-600 hover:text-gray-800"
            >
              Cancel
            </button>
          </div>
        </div>
      )}
    </header>
  )
}
```

- [ ] **Step 4: Commit**

Run: `git add -A && git commit -m "feat: Add Header components with auth form"`

---

### Task 6: Sidebar Component

**Files:**
- Create: `api-test-tool/src/components/Sidebar/Sidebar.tsx`

- [ ] **Step 1: Create src/components/Sidebar/Sidebar.tsx**

```typescript
import { useState } from 'react'
import { allFlows } from '../../flows'
import { FlowEndpoint, FlowGroup } from '../../types'

interface SidebarProps {
  onSelectEndpoint: (endpoint: FlowEndpoint) => void
}

export default function Sidebar({ onSelectEndpoint }: SidebarProps) {
  const [expandedGroups, setExpandedGroups] = useState<string[]>(['auth'])
  const [selectedEndpointId, setSelectedEndpointId] = useState<string | null>(null)

  const toggleGroup = (groupId: string) => {
    setExpandedGroups((prev) =>
      prev.includes(groupId) ? prev.filter((id) => id !== groupId) : [...prev, groupId]
    )
  }

  const handleSelect = (endpoint: FlowEndpoint, group: FlowGroup) => {
    setSelectedEndpointId(endpoint.id)
    onSelectEndpoint(endpoint)
  }

  return (
    <aside className="w-64 bg-white border-r border-gray-200 overflow-y-auto">
      <div className="p-4">
        <h2 className="text-xs font-semibold text-gray-500 uppercase tracking-wide mb-3">
          API Flows
        </h2>
        <nav className="space-y-1">
          {allFlows.map((group) => (
            <div key={group.id}>
              <button
                onClick={() => toggleGroup(group.id)}
                className="w-full flex items-center gap-2 px-3 py-2 text-sm font-medium text-gray-700 hover:bg-gray-100 rounded"
              >
                <span className="text-lg">{group.icon}</span>
                <span className="flex-1 text-left">{group.name}</span>
                <span className="text-gray-400">
                  {expandedGroups.includes(group.id) ? '▼' : '▶'}
                </span>
              </button>

              {expandedGroups.includes(group.id) && (
                <div className="ml-4 mt-1 space-y-1">
                  {group.endpoints.map((endpoint) => (
                    <button
                      key={endpoint.id}
                      onClick={() => handleSelect(endpoint, group)}
                      className={`w-full flex items-center gap-2 px-3 py-1.5 text-sm rounded ${
                        selectedEndpointId === endpoint.id
                          ? 'bg-blue-50 text-blue-700'
                          : 'text-gray-600 hover:bg-gray-50'
                      }`}
                    >
                      <span
                        className={`text-xs font-bold ${
                          endpoint.method === 'GET'
                            ? 'text-green-600'
                            : endpoint.method === 'POST'
                            ? 'text-blue-600'
                            : endpoint.method === 'PUT'
                            ? 'text-yellow-600'
                            : endpoint.method === 'DELETE'
                            ? 'text-red-600'
                            : 'text-purple-600'
                        }`}
                      >
                        {endpoint.method}
                      </span>
                      <span className="truncate">{endpoint.name}</span>
                      {endpoint.requiresAuth === false && (
                        <span className="text-xs text-gray-400">🔓</span>
                      )}
                    </button>
                  ))}
                </div>
              )}
            </div>
          ))}
        </nav>
      </div>
    </aside>
  )
}
```

- [ ] **Step 2: Commit**

Run: `git add -A && git commit -m "feat: Add Sidebar component with flow menu"`

---

### Task 7: Request Panel Component

**Files:**
- Create: `api-test-tool/src/components/RequestPanel/RequestPanel.tsx`
- Create: `api-test-tool/src/components/RequestPanel/RequestBodyEditor.tsx`

- [ ] **Step 1: Create src/components/RequestPanel/RequestBodyEditor.tsx**

```typescript
import { useState, useEffect } from 'react'

interface RequestBodyEditorProps {
  value: Record<string, unknown>
  onChange: (value: Record<string, unknown>) => void
}

export default function RequestBodyEditor({ value, onChange }: RequestBodyEditorProps) {
  const [jsonString, setJsonString] = useState(JSON.stringify(value, null, 2))
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    setJsonString(JSON.stringify(value, null, 2))
  }, [value])

  const handleChange = (newValue: string) => {
    setJsonString(newValue)
    try {
      const parsed = JSON.parse(newValue)
      onChange(parsed)
      setError(null)
    } catch (e) {
      setError('Invalid JSON')
    }
  }

  return (
    <div>
      <textarea
        value={jsonString}
        onChange={(e) => handleChange(e.target.value)}
        className={`w-full h-48 font-mono text-sm p-3 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500 ${
          error ? 'border-red-500' : 'border-gray-300'
        }`}
        placeholder='{ "key": "value" }'
      />
      {error && <p className="mt-1 text-xs text-red-500">{error}</p>}
    </div>
  )
}
```

- [ ] **Step 2: Create src/components/RequestPanel/RequestPanel.tsx**

```typescript
import { useState, useEffect } from 'react'
import { FlowEndpoint } from '../../types'
import { useApiClient } from '../../hooks/useApiClient'
import RequestBodyEditor from './RequestBodyEditor'
import { FaPlay } from 'react-icons/fa'

interface RequestPanelProps {
  selectedEndpoint: FlowEndpoint | null
  onResponse: (response: { status: number; data: unknown; time: number; headers?: Record<string, string> }) => void
}

export default function RequestPanel({ selectedEndpoint, onResponse }: RequestPanelProps) {
  const { request } = useApiClient()
  const [body, setBody] = useState<Record<string, unknown>>({})
  const [loading, setLoading] = useState(false)
  const [pathParams, setPathParams] = useState<Record<string, string>>({})

  useEffect(() => {
    if (selectedEndpoint?.bodyTemplate) {
      setBody(selectedEndpoint.bodyTemplate)
    } else {
      setBody({})
    }
    // Extract path params from path
    if (selectedEndpoint?.path) {
      const matches = selectedEndpoint.path.match(/\{(\w+)\}/g)
      if (matches) {
        const params: Record<string, string> = {}
        matches.forEach((m) => {
          const key = m.replace(/[{}]/g, '')
          params[key] = ''
        })
        setPathParams(params)
      } else {
        setPathParams({})
      }
    }
  }, [selectedEndpoint])

  const handleSend = async () => {
    if (!selectedEndpoint) return

    setLoading(true)

    try {
      // Replace path params
      let path = selectedEndpoint.path
      Object.entries(pathParams).forEach(([key, value]) => {
        path = path.replace(`{${key}}`, value || `{${key}}`)
      })

      const response = await request({
        method: selectedEndpoint.method,
        path,
        body: Object.keys(body).length > 0 ? body : undefined,
        requiresAuth: selectedEndpoint.requiresAuth,
      })

      onResponse(response)
    } catch (error) {
      onResponse({
        status: 0,
        data: { error: error instanceof Error ? error.message : 'Unknown error' },
        time: 0,
      })
    } finally {
      setLoading(false)
    }
  }

  if (!selectedEndpoint) {
    return (
      <div className="bg-white rounded-lg shadow p-6 flex items-center justify-center h-full">
        <p className="text-gray-500">Select an endpoint from the sidebar to test</p>
      </div>
    )
  }

  return (
    <div className="bg-white rounded-lg shadow p-4 flex flex-col h-full">
      <div className="flex items-center justify-between mb-4">
        <div>
          <h3 className="text-lg font-semibold text-gray-800">{selectedEndpoint.name}</h3>
          <p className="text-sm text-gray-500">{selectedEndpoint.description}</p>
        </div>
        <button
          onClick={handleSend}
          disabled={loading}
          className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700 disabled:opacity-50"
        >
          <FaPlay />
          {loading ? 'Sending...' : 'Send'}
        </button>
      </div>

      <div className="mb-4">
        <div className="flex items-center gap-2">
          <span
            className={`px-2 py-1 text-xs font-bold rounded ${
              selectedEndpoint.method === 'GET'
                ? 'bg-green-100 text-green-700'
                : selectedEndpoint.method === 'POST'
                ? 'bg-blue-100 text-blue-700'
                : selectedEndpoint.method === 'PUT'
                ? 'bg-yellow-100 text-yellow-700'
                : selectedEndpoint.method === 'DELETE'
                ? 'bg-red-100 text-red-700'
                : 'bg-purple-100 text-purple-700'
            }`}
          >
            {selectedEndpoint.method}
          </span>
          <code className="text-sm text-gray-700">{selectedEndpoint.path}</code>
          {!selectedEndpoint.requiresAuth && (
            <span className="text-xs text-gray-400">(No auth required)</span>
          )}
        </div>
      </div>

      {/* Path Parameters */}
      {Object.keys(pathParams).length > 0 && (
        <div className="mb-4">
          <h4 className="text-sm font-medium text-gray-700 mb-2">Path Parameters</h4>
          <div className="space-y-2">
            {Object.entries(pathParams).map(([key]) => (
              <div key={key} className="flex items-center gap-2">
                <label className="text-sm text-gray-600 w-24">{key}:</label>
                <input
                  type="text"
                  value={pathParams[key]}
                  onChange={(e) => setPathParams((prev) => ({ ...prev, [key]: e.target.value }))}
                  placeholder={`Enter ${key}`}
                  className="flex-1 px-3 py-1.5 text-sm border border-gray-300 rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
                />
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Request Body */}
      {['POST', 'PUT', 'PATCH'].includes(selectedEndpoint.method) && (
        <div className="flex-1">
          <h4 className="text-sm font-medium text-gray-700 mb-2">Request Body</h4>
          <RequestBodyEditor value={body} onChange={setBody} />
        </div>
      )}
    </div>
  )
}
```

- [ ] **Step 3: Commit**

Run: `git add -A && git commit -m "feat: Add RequestPanel component"`

---

### Task 8: Response Panel Component

**Files:**
- Create: `api-test-tool/src/components/ResponsePanel/ResponsePanel.tsx`
- Create: `api-test-tool/src/components/ResponsePanel/JsonViewer.tsx`

- [ ] **Step 1: Create src/components/ResponsePanel/JsonViewer.tsx**

```typescript
import { useState } from 'react'

interface JsonViewerProps {
  data: unknown
}

export default function JsonViewer({ data }: JsonViewerProps) {
  const [expanded, setExpanded] = useState(true)

  const renderValue = (value: unknown, key?: string, depth = 0): JSX.Element => {
    const indent = depth * 16

    if (value === null) {
      return <span className="text-gray-500">null</span>
    }

    if (value === undefined) {
      return <span className="text-gray-400">undefined</span>
    }

    if (typeof value === 'boolean') {
      return <span className="text-purple-600">{value.toString()}</span>
    }

    if (typeof value === 'number') {
      return <span className="text-blue-600">{value}</span>
    }

    if (typeof value === 'string') {
      return <span className="text-green-600">"{value}"</span>
    }

    if (Array.isArray(value)) {
      if (value.length === 0) {
        return <span className="text-gray-500">[]</span>
      }

      return (
        <div>
          <span
            className="cursor-pointer text-gray-500"
            onClick={() => setExpanded(!expanded)}
          >
            {expanded ? '▼' : '▶'} [{value.length}]
          </span>
          {expanded && (
            <div className="ml-4">
              {value.map((item, index) => (
                <div key={index} style={{ paddingLeft: indent }}>
                  {renderValue(item, undefined, depth + 1)}
                  {index < value.length - 1 && ','}
                </div>
              ))}
            </div>
          )}
          {!expanded && ' ...'}
        </div>
      )
    }

    if (typeof value === 'object') {
      const entries = Object.entries(value as Record<string, unknown>)
      if (entries.length === 0) {
        return <span className="text-gray-500">{'{}'}</span>
      }

      return (
        <div>
          <span
            className="cursor-pointer text-gray-500"
            onClick={() => setExpanded(!expanded)}
          >
            {expanded ? '▼' : '▶'} {'{...}'}
          </span>
          {expanded && (
            <div className="ml-4">
              {entries.map(([k, v], index) => (
                <div key={k} style={{ paddingLeft: indent }}>
                  <span className="text-red-600">"{k}"</span>: {renderValue(v, k, depth + 1)}
                  {index < entries.length - 1 && ','}
                </div>
              ))}
            </div>
          )}
        </div>
      )
    }

    return <span>{String(value)}</span>
  }

  return (
    <pre className="font-mono text-sm bg-gray-50 p-4 rounded overflow-auto">
      {renderValue(data)}
    </pre>
  )
}
```

- [ ] **Step 2: Create src/components/ResponsePanel/ResponsePanel.tsx**

```typescript
import { FaCopy, FaCheck } from 'react-icons/fa'
import { useState } from 'react'
import JsonViewer from './JsonViewer'

interface ResponsePanelProps {
  response: {
    status: number
    data: unknown
    time: number
    headers?: Record<string, string>
  } | null
}

export default function ResponsePanel({ response }: ResponsePanelProps) {
  const [copied, setCopied] = useState(false)

  const handleCopy = () => {
    if (response) {
      navigator.clipboard.writeText(JSON.stringify(response.data, null, 2))
      setCopied(true)
      setTimeout(() => setCopied(false), 2000)
    }
  }

  if (!response) {
    return (
      <div className="bg-white rounded-lg shadow p-6 flex items-center justify-center h-full">
        <p className="text-gray-500">Response will appear here</p>
      </div>
    )
  }

  const getStatusColor = (status: number) => {
    if (status >= 200 && status < 300) return 'bg-green-100 text-green-700'
    if (status >= 300 && status < 400) return 'bg-yellow-100 text-yellow-700'
    if (status >= 400 && status < 500) return 'bg-orange-100 text-orange-700'
    if (status >= 500) return 'bg-red-100 text-red-700'
    return 'bg-gray-100 text-gray-700'
  }

  return (
    <div className="bg-white rounded-lg shadow p-4 flex flex-col h-full">
      <div className="flex items-center justify-between mb-4">
        <div className="flex items-center gap-3">
          <span className={`px-3 py-1 text-sm font-bold rounded ${getStatusColor(response.status)}`}>
            {response.status === 0 ? 'Error' : response.status}
          </span>
          <span className="text-sm text-gray-500">{response.time}ms</span>
        </div>
        <button
          onClick={handleCopy}
          className="flex items-center gap-1 px-3 py-1.5 text-sm text-gray-600 hover:text-gray-800 border border-gray-300 rounded"
        >
          {copied ? <FaCheck className="text-green-600" /> : <FaCopy />}
          {copied ? 'Copied!' : 'Copy'}
        </button>
      </div>

      <div className="flex-1 overflow-auto">
        <JsonViewer data={response.data} />
      </div>

      {response.headers && Object.keys(response.headers).length > 0 && (
        <div className="mt-4 pt-4 border-t">
          <h4 className="text-sm font-medium text-gray-700 mb-2">Response Headers</h4>
          <div className="text-xs font-mono bg-gray-50 p-2 rounded max-h-32 overflow-auto">
            {Object.entries(response.headers).map(([key, value]) => (
              <div key={key} className="flex gap-2">
                <span className="text-blue-600">{key}:</span>
                <span className="text-gray-700">{value}</span>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  )
}
```

- [ ] **Step 3: Commit**

Run: `git add -A && git commit -m "feat: Add ResponsePanel component with JsonViewer"`

---

### Task 9: Final Build & Test

- [ ] **Step 1: Run build to verify**

Run: `cd api-test-tool && npm run build`

Expected: Successful build without errors

- [ ] **Step 2: Start dev server and verify**

Run: `cd api-test-tool && npm run dev`

- [ ] **Step 3: Commit final changes**

Run: `git add -A && git commit -m "feat: Complete API Test Tool - initial implementation"`

---

## Self-Review Checklist

1. **Spec coverage:** All 10 flows defined with endpoints ✓
2. **Placeholder scan:** No TBD/TODO in code ✓
3. **Type consistency:** FlowEndpoint and AuthState used consistently ✓

---

**Plan complete and saved to `docs/superpowers/plans/2026-06-10-api-test-tool.md`.**

**Two execution options:**

**1. Subagent-Driven (recommended)** - I dispatch a fresh subagent per task, review between tasks, fast iteration

**2. Inline Execution** - Execute tasks in this session using executing-plans, batch execution with checkpoints

**Which approach?**
