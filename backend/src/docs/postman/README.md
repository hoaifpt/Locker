# Locker API - Postman Collection

## Overview

This collection contains all API endpoints for the Locker Backend application. It includes both success and failure test cases for comprehensive API testing.

## File Structure

- `Locker_API_Collection.json` - Postman Collection with all endpoints and test scripts
- `Locker_API_Environment.json` - Postman Environment with variables

## Import Instructions

### Step 1: Import into Postman

1. Open Postman
2. Click **Import** button
3. Import both files:
   - `Locker_API_Collection.json`
   - `Locker_API_Environment.json`
4. Select the environment "Locker API Environment" from the dropdown

### Step 2: Configure Environment

1. Click **Environments** (gear icon)
2. Select "Locker API Environment"
3. Set the following values:
   - `baseUrl`: `http://localhost:5000` (or your production URL)
   - `adminToken`: JWT token from an admin account (for admin tests)

### Step 3: Run Tests

Recommended test order:

1. **Auth** - Run first to get a token (mandatory)
   - Run "Register - Success" to create a test account
   - Or run "Login - Success" if you already have an account

2. **Users** - Test profile endpoints

3. **Packages** - Get packageId for later Orders tests

4. **Lockers** - Get lockerId for later Orders tests

5. **Orders** - Full order flow test

6. **Payments** - Payment processing tests

7. **Bookings** - Legacy booking tests

8. **Wallet** - Wallet operations

9. **Food Orders** - Restaurant and food ordering

10. **Delivery** - Delivery request tests

11. **Send/Receive** - Send/receive order tests

12. **Notifications** - Notification tests

13. **Device Tokens** - Device token management

14. **Admin** - Admin-only endpoints (requires admin token)

15. **Health** - API health check

## Important Notes

### Special Endpoints

These endpoints have **NO request body**:

- `PATCH /api/orders/{id}/activate` - No body required
- `PATCH /api/send-receive/orders/{id}/confirm` - No body required
- `PATCH /api/send-receive/orders/{id}/complete` - No body required

### Special Fields

| Field | Note |
|-------|------|
| **Wallet Overview** | Does NOT return `transactions` field - must call `/wallet/transactions` separately |
| **Send/Receive** | `pinCode` is required when creating, but is NEVER returned in the response |
| **Food Order** | Automatically creates a Payment with "Pending" status |

### Complete Order Flow Test

```
1. POST /api/orders/reserve          -> orderId
2. POST /api/payments               -> paymentId
3. POST /api/payments/{id}/complete  (fake webhook)
4. PATCH /api/orders/{id}/confirm    (with body {notes})
5. PATCH /api/orders/{id}/activate   (NO body)
6. POST /api/orders/{id}/set-pin
7. PATCH /api/orders/{id}/complete   (with body {notes})
```

### Admin Testing

For Admin endpoints, you need an admin account:

1. Login with an admin account
2. Copy the `accessToken` value
3. Paste it into the `adminToken` environment variable
4. Run Admin folder tests

### Variables Auto-Set

The collection automatically saves these variables:

- `accessToken` - Set after successful login/register
- `refreshToken` - Set after successful login/register
- `userId` - Extracted from JWT token
- `lockerId` - Set from "Get Available Lockers"
- `packageId` - Set from "Get All Packages"
- `orderId` - Set from "Reserve Order"
- `paymentId` - Set from "Create Payment"
- And more...

## Test Coverage

| Folder | Endpoints | Success Tests | Failure Tests |
|--------|-----------|---------------|---------------|
| Auth | 13 | 8 | 5 |
| Users | 5 | 3 | 2 |
| Lockers | 12 | 8 | 4 |
| Packages | 4 | 3 | 1 |
| Orders | 11 | 9 | 2 |
| Payments | 7 | 6 | 1 |
| Bookings | 7 | 5 | 2 |
| Wallet | 6 | 6 | 0 |
| Food Orders | 6 | 6 | 0 |
| Delivery | 5 | 4 | 1 |
| Send/Receive | 5 | 5 | 0 |
| Notifications | 4 | 4 | 0 |
| Device Tokens | 2 | 2 | 0 |
| Admin | 6 | 6 | 0 |
| Health | 1 | 1 | 0 |

**Total: 89 requests with comprehensive test coverage**

## Troubleshooting

### 401 Unauthorized

- Make sure you've logged in or registered first
- Check that the token was saved to the `accessToken` variable
- Run "Login - Success" or "Register - Success" again

### 404 Not Found

- Verify the ID variable is set (check Collection Variables)
- Run the parent request that sets the ID first

### 400 Bad Request

- Check the request body format
- Verify required fields are present
- Check validation rules (e.g., PIN must be 6 digits)

## Additional Resources

- Backend API Documentation: `docs/architecture.md`
- Agent Guidelines: `docs/agent.md`
- Flutter Integration Plan: `docs/flutter_api_integration_plan_1aca8bd0.plan.md`
