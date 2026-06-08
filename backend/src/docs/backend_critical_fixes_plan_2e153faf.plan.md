---
name: Backend Critical Fixes Plan
overview: Fix all critical, high, and medium severity issues found in the code review — covering security vulnerabilities, broken business logic, database gaps, and architectural problems.
todos:
  - id: fix-secrets
    content: "Phase 1a: Fix hardcoded secrets — move to environment variables"
    status: completed
  - id: fix-webhook-auth
    content: "Phase 1b: Add payment webhook signature verification"
    status: completed
  - id: fix-otp-rng
    content: "Phase 1c: Replace System.Random with RandomNumberGenerator for OTP"
    status: completed
  - id: fix-email-verify
    content: "Phase 1d: Remove EmailConfirmed=true bypass in registration"
    status: completed
  - id: fix-wallet-transfer
    content: "Phase 2a: Fix wallet transfer — create debit + credit transactions"
    status: completed
  - id: fix-order-expiration
    content: "Phase 2b: Add payment expiration check in ConfirmOrder"
    status: completed
  - id: fix-booking-pin-gate
    content: "Phase 2c: Fix Booking PIN payment gate"
    status: completed
  - id: fix-sr-receiver-complete
    content: "Phase 2d: Allow SendReceive receiver to complete order"
    status: completed
  - id: fix-food-order-payment
    content: "Phase 2e: Add payment flow for food orders"
    status: completed
  - id: add-mongo-indexes
    content: "Phase 3a: Add MongoDB indexes for all critical queries"
    status: completed
  - id: add-ttl-indexes
    content: "Phase 3b: Add TTL index for expired OTP and refresh tokens"
    status: completed
  - id: fix-concurrency
    content: "Phase 3c: Implement optimistic concurrency in repository"
    status: completed
  - id: fix-jwt-revocation
    content: "Phase 4a: Add JWT access token revocation list"
    status: in_progress
  - id: fix-jwt-secret
    content: "Phase 4b: Enforce minimum JWT secret strength"
    status: completed
  - id: fix-pin-rate-limit
    content: "Phase 4c: Add PIN rate limiting (attempt counter, lockout)"
    status: completed
  - id: fix-qr-bypass
    content: "Phase 4d: Fix QR code bypass — use locker ID only"
    status: completed
  - id: fix-pin-open
    content: "Phase 4e: Verify PIN when opening physical locker"
    status: completed
  - id: fix-cancel-active
    content: "Phase 5a: Allow Active orders to be cancelled with partial payment"
    status: pending
  - id: fix-race-condition
    content: "Phase 5b: Use MongoDB transaction for atomic slot reservation"
    status: pending
  - id: add-overdue-check
    content: "Phase 5c: Add overdue order detection background service"
    status: pending
  - id: fix-delivery-slot
    content: "Phase 5d: Reserve slot atomically when creating delivery request"
    status: pending
  - id: fix-medium-priority
    content: "Phase 6: Align password config, CORS, email token expiry, admin pagination"
    status: pending
  - id: fix-technical-debt
    content: "Phase 7: Technical debt — OTP rate limit, audit logging, soft delete consistency"
    status: pending
isProject: false
---

## 1. Security — Critical Fixes

### 1a. Hardcoded Secrets (`appsettings.json`)
- **File:** `Locker.Backend/appsettings.json`
- Move all secrets to environment variables: MongoDB password, Gmail app password, JWT secret, admin credentials
- Create `appsettings.Development.json` and `appsettings.Production.json` (gitignored) with real values
- Update `Program.cs` to read secrets from `IConfiguration` with env var fallback

### 1b. Payment Webhook — Add Signature Verification
- **File:** `Controllers/PaymentsController.cs`, `Application/Features/Payments/Commands/ProcessPaymentWebhook/ProcessPaymentWebhookCommand.cs`
- Add webhook signature verification: read shared secret from config, compute HMAC-SHA256 of payload, compare with `X-Signature` header
- Reject requests with missing or invalid signatures with `401 Unauthorized`
- Add webhook secret to configuration

### 1c. OTP — Use Cryptographically Secure RNG
- **File:** `Application/Features/Auth/Commands/SendForgotPasswordOtp/SendForgotPasswordOtpCommand.cs`
- Replace `new Random().Next(100000, 999999)` with `RandomNumberGenerator.GetInt32(100000, 999999)`

### 1d. Email Verification — Remove Auto-Confirm
- **File:** `Application/Features/Auth/Commands/Register/RegisterCommand.cs`
- Change `EmailConfirmed = true` to `EmailConfirmed = false`
- Login should remain functional (allow login without verification for MVP convenience), but email verification endpoint must work end-to-end

---

## 2. Business Logic — Critical Bug Fixes

### 2a. Wallet Transfer — Fix Receiver Credit
- **File:** `Application/Features/Wallet/Commands/Transfer/TransferCommand.cs`
- Create TWO transactions: one debit from sender, one credit to receiver
- Both with `Type = Transfer`, `Status = Completed`
- Sender tx: `UserId = senderId`, `RelatedUserId = receiverId`
- Receiver tx: `UserId = receiverId`, `RelatedUserId = senderId`
- This way `GetBalanceAsync` correctly counts sender as `-amount` and receiver as `+amount`

### 2b. Order Payment Expiration — Add Expiration Check
- **File:** `Application/Features/Orders/Commands/CreateOrder/CreateOrderCommand.cs`
- Add `PaymentExpirationTime` field to `Order` entity
- Create a new command or background service that calls `GetExpiredOrdersAsync` and cancels orders past their expiration time
- At minimum, add a check in `ConfirmOrder` to reject if `DateTime.UtcNow > order.PaymentExpirationTime`

### 2c. Booking PIN Without Payment — Fix Payment Gate
- **File:** `Application/Features/Bookings/Commands/SetPin/SetPinCommand.cs`
- Change `if (booking.PaymentId != null)` to always require completed payment regardless of whether `PaymentId` is set
- If no payment is linked, return `false` (forbidden) instead of allowing PIN to be set

### 2d. SendReceive — Allow Receiver to Complete
- **File:** `Application/Features/SendReceiveOrders/Commands/CompleteOrder/CompleteOrderCommand.cs`
- Change authorization: allow `request.UserId == order.SenderId` OR `request.UserId == receiverId`
- Add `ReceiverId` field to `SendReceiveOrder` entity (currently missing)
- `ConfirmOrder` should also check receiver identity for pickup flow

### 2e. Food Order — No Payment Flow
- **File:** `Application/Features/FoodOrders/Commands/CreateFoodOrder/CreateFoodOrderCommand.cs`
- Food orders are created but never paid. Two options:
  - Option A (quick): Add `PaymentId` field to `FoodOrder` and create payment flow
  - Option B (MVP): Return `PaymentRequired` status, add `CreateFoodOrderPaymentCommand`
- Recommend Option A for MVP completeness

---

## 3. Database — Indexes & Constraints

### 3a. Add MongoDB Indexes
- **File:** `Infrastructure/Mongo/MongoContext.cs`
- Add indexes in `MongoContext` constructor or via repository startup:
  ```
  users: { email: 1 } unique, { phoneNumber: 1 }
  refresh_tokens: { token: 1 } unique, { userId: 1 }
  otp_codes: { userId: 1, target: 1, expiresAt: 1 }, { expiresAt: 1 } TTL
  orders: { lockerId: 1, slotIndex: 1, status: 1 }, { userId: 1, status: 1 }, { status: 1, createdAt: 1 }
  bookings: { userId: 1, status: 1 }, { lockerId: 1, slotIndex: 1 }
  wallet_transactions: { userId: 1, createdAt: -1 }
  delivery_requests: { trackingCode: 1 } unique, { userId: 1 }
  send_receive_orders: { senderId: 1 }, { receiverId: 1 }
  locker_events: { lockerId: 1, slotIndex: 1 }, { createdAt: 1 }
  ```

### 3b. Add TTL Index for Expired Data
- **File:** `Infrastructure/Mongo/MongoContext.cs`
- Add TTL index on `otp_codes.expiresAt` (auto-delete expired OTPs)
- Consider TTL on `refresh_tokens` for automatic cleanup

### 3c. Optimistic Concurrency
- **File:** `Infrastructure/Repositories/GenericRepository.cs`
- Add version check in `UpdateAsync`: `e.Version == entity.Version`
- Increment `entity.Version` before update
- Throw `ConcurrencyException` if version mismatch

---

## 4. Security — High Severity Fixes

### 4a. JWT Access Token — Add Revocation List
- **File:** `Infrastructure/Security/JwtTokenService.cs`, `Application/Features/Auth/Commands/Logout/LogoutCommand.cs`
- On logout, add the access token's `jti` claim to a revoked tokens collection
- Add a Redis or MongoDB-backed revoked token store
- Check token `jti` against revoked list in `JwtTokenService` validation
- Alternative (simpler for MVP): reduce access token expiry to 15 minutes

### 4b. JWT Secret — Enforce Minimum Strength
- **File:** `Infrastructure/Security/JwtSettings.cs`
- Add validation: if `Secret.Length < 32`, throw on startup
- Default should be at least 256-bit (32 bytes of random chars)
- Document requirement clearly in README

### 4c. Order/Booking PIN — Add Rate Limiting
- **File:** `Application/Features/Orders/Commands/VerifyPin/VerifyPinCommand.cs` (or similar)
- Add attempt counter to `Order`/`Booking` entity: `PinAttempts`, `LockedUntil`
- After 3 failed attempts, lock for 5 minutes
- Return clear error on lockout

### 4d. QR Code — Fix Trivial Bypass
- **File:** `Application/Features/Lockers/Queries/ValidateQrCode/ValidateQrCodeQuery.cs`
- Remove locker name matching — only accept locker ID (GUID) in QR code
- QR code should contain `{ lockerId, lockerName, slotIndex? }` signed with a shared secret
- Validate signature if using signed tokens

### 4e. Physical Open — Verify PIN
- **File:** `Application/Features/Lockers/Commands/OpenLockerSlot/OpenLockerSlotCommand.cs`
- After checking `UserId == booking.UserId || UserId == order.UserId`, also verify PIN
- Call PIN verification service before allowing open
- Only Admin/Shipper can bypass PIN check

---

## 5. Business Logic — High Priority Fixes

### 5a. Active Orders Cannot Be Cancelled
- **File:** `Application/Features/Orders/Commands/CancelOrder/CancelOrderCommand.cs`
- Allow cancellation of `Active` orders
- Calculate partial payment based on actual usage time (hourly rate)
- Either auto-deduct from wallet or mark order as requiring payment before slot release

### 5b. Concurrent Slot Booking Race Condition
- **File:** `Application/Features/Orders/Commands/CreateOrder/CreateOrderCommand.cs`
- Use MongoDB multi-document transaction to atomically create order + update slot status
- Wrap `CreateAsync` + `UpdateAsync` in a session transaction
- Same fix needed in `CreateFoodOrder`, `CreateDeliveryRequest`

### 5c. No Overdue Detection
- **File:** `Application/Features/Orders/Commands/` (new file)
- Create a `CheckOverdueOrdersCommand` or a `BackgroundService`
- Detect orders where `CheckOutTime < DateTime.UtcNow` and `Status == Active`
- Apply penalty fee, send notification, auto-complete order
- For MVP, auto-complete overdue orders and notify user

### 5d. Delivery Request — Reserve Slot
- **File:** `Application/Features/DeliveryRequests/Commands/CreateDeliveryRequest/CreateDeliveryRequestCommand.cs`
- After creating delivery request, update `LockerSlot` status to `Pending`
- Use MongoDB transaction for atomicity
- Shipper assignment should validate slot availability

---

## 6. Medium Priority Fixes

### 6a. ASP.NET Identity Password Config
- **File:** `Infrastructure/DependencyInjection.cs`
- Align `identityOptions.Password` with FluentValidation rules: minimum 8 chars, require digit, require special char, require uppercase

### 6b. CORS — Remove Wildcard
- **File:** `Program.cs`
- Remove the `allowedOrigins.Length == 0` fallback that allows any origin
- Require explicit `AllowedOrigins` configuration in all environments
- Add a startup validation warning if CORS origins are empty

### 6c. Email Verification Token — Add Expiry
- **File:** `Domain/Entities/User.cs`, `Application/Features/Auth/Commands/Register/RegisterCommand.cs`
- Add `EmailVerificationTokenExpiry` field to `User`
- Set expiry to 24 hours
- Reject expired tokens in `VerifyEmailCommand`

### 6d. Email Subject Encoding
- **File:** `Infrastructure/Services/EmailService.cs`
- Fix email subject encoding: ensure UTF-8 encoding on subject lines

### 6e. Duplicate Booking/Order Systems
- This is a design issue, not a quick fix. Recommend:
  - Deprecate `Booking` system in favor of `Order`
  - Keep `Order` as the single system
  - Add `OrderType` enum: `LockerRental`, `FoodDelivery`, `SendReceive`
  - For MVP, document the difference and ensure `Payment.BookingId` maps to `Order.Id`

### 6f. Admin Payments — Add Pagination
- **File:** `Application/Features/Admin/Queries/GetAllPayments/GetAllPaymentsQuery.cs`
- Add pagination: `skip`, `take` parameters
- Add date range filter
- Add total count response

### 6g. Update Profile Email Change — Require Re-Verification
- **File:** `Application/Features/Users/Commands/UpdateProfile/UpdateProfileCommand.cs`
- On email change, set `EmailConfirmed = false` and generate new verification token
- Send verification email to new address

---

## 7. Low Priority / Technical Debt

### 7a. OTP Submission Rate Limiting
- Add attempt counter to OTP validation (brute-force protection)

### 7b. Audit Logging for Sensitive Operations
- Wrap `OpenLockerSlot`, `CancelOrder`, `ResetPassword` in audit logging
- Write to `LockerEvent` collection with `EventType.Audit`

### 7c. Notification Content Sanitization
- Add max length validation on `Notification.Title` and `Notification.Message`

### 7d. Soft Delete Consistency
- Add soft delete to `Restaurant`, `MenuItem`, `FoodOrder`
- Standardize `IsDeleted` behavior across all entities

### 7e. GetAvailableSlots — Fix Time Range Check
- **File:** `Application/Features/Orders/Queries/GetAvailableSlotsByLocker/GetAvailableSlotsByLockerQuery.cs`
- The query already correctly filters `Status == Available` at line 44, so this is confirmed working

### 7f. Booking Status — CancelBooking Incomplete Check
- **File:** `Application/Features/Bookings/Commands/CancelBooking/CancelBookingCommand.cs`
- Add checks for `Expired` and `Canceled` statuses with descriptive error messages
