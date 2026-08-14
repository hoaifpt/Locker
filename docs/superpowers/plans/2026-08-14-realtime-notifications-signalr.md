# Realtime SignalR Notifications Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace web notification mock/seed data with MongoDB-backed notifications delivered live through authenticated SignalR for SePay wallet top-ups, delivery requests, and feedback submitted to Admins.

**Architecture:** MongoDB remains authoritative and the existing notification REST API supplies initial/recovery state. A shared backend service persists each notification before publishing its DTO to the authenticated recipient's `user:{userId}` SignalR group; the web client loads REST state, merges realtime events by ID, and reloads after reconnect.

**Tech Stack:** ASP.NET Core 10, SignalR, JWT bearer authentication, MediatR, MongoDB, React 18, TypeScript, `@microsoft/signalr`, Vite.

## Global Constraints

- Scope is backend plus web only; Flutter keeps its current API and Firebase Messaging flow.
- Do not create unit tests or mock tests; verify with builds and the manual scenarios specified below.
- Do not use notification seed/mock data as a fallback.
- Persist before publishing; a SignalR delivery failure must not roll back a completed business transaction.
- SignalR recipients are derived from validated JWT claims; clients cannot select another user's group.
- Feedback content and payment secrets must never be included in realtime payloads.
- Existing notification records in MongoDB must not be deleted automatically.
- Do not push commits unless the user explicitly requests a push.

---

## File Structure

### Create

- `backend/src/Locker.Backend.Application/Interfaces/IRealtimeNotificationService.cs` — application-facing persistence-and-publish contract.
- `backend/src/Locker.Backend.Infrastructure/Notifications/NotificationHub.cs` — authenticated SignalR hub and server-owned user group membership.
- `backend/src/Locker.Backend.Infrastructure/Notifications/RealtimeNotificationService.cs` — MongoDB persistence, DTO mapping, Admin lookup, and SignalR publishing.
- `web/src/features/notifications/types.ts` — the camelCase `NotificationDto` TypeScript contract.
- `web/src/features/notifications/api/notificationsApi.ts` — REST operations for list/read state.
- `web/src/features/notifications/api/notificationsRealtime.ts` — authenticated SignalR connection factory.

### Modify

- `backend/src/Locker.Backend/Program.cs` — register/map SignalR and permit query-string JWT only on the hub path.
- `backend/src/Locker.Backend.Infrastructure/DependencyInjection.cs` — register the shared notification service.
- `backend/src/Locker.Backend.Infrastructure/Data/DbSeeder.cs` — remove notification seed dependencies and generation.
- `backend/src/Locker.Backend.Application/Features/DeliveryRequests/Commands/CreateDeliveryRequest/CreateDeliveryRequestCommand.cs` — publish real receiver notification through the shared service.
- `backend/src/Locker.Backend.Application/Features/Wallet/Commands/SepayProcessIpn/SepayProcessIpnCommand.cs` — publish one wallet-owner notification on the first successful completion.
- `backend/src/Locker.Backend.Application/Features/Feedback/Commands/UpsertMyFeedback/UpsertMyFeedbackCommand.cs` — publish feedback notification to each Admin after upsert.
- `web/src/lib/api.ts` — expose a hub-safe API origin helper.
- `web/src/features/notifications/components/NotificationsDropdown.tsx` — replace mock state with REST plus SignalR.
- `web/package.json`, `web/package-lock.json` — add the official SignalR browser client.

---

### Task 1: Authenticated SignalR transport and shared notification service

**Files:**
- Create: `backend/src/Locker.Backend.Application/Interfaces/IRealtimeNotificationService.cs`
- Create: `backend/src/Locker.Backend.Infrastructure/Notifications/NotificationHub.cs`
- Create: `backend/src/Locker.Backend.Infrastructure/Notifications/RealtimeNotificationService.cs`
- Modify: `backend/src/Locker.Backend.Infrastructure/DependencyInjection.cs`
- Modify: `backend/src/Locker.Backend/Program.cs`

**Interfaces:**
- Produces: `Task<NotificationDto> NotifyUserAsync(Guid userId, string title, string message, CancellationToken cancellationToken)`.
- Produces: `Task<IReadOnlyList<NotificationDto>> NotifyAdminsAsync(string title, string message, CancellationToken cancellationToken)`.
- Produces: SignalR event `NotificationReceived` carrying one `NotificationDto`.
- Produces: authenticated hub endpoint `/hubs/notifications` and server-owned group `user:{userId:D}`.

- [ ] **Step 1: Define the application contract**

Create the interface with exact operations:

```csharp
public interface IRealtimeNotificationService
{
    Task<NotificationDto> NotifyUserAsync(
        Guid userId,
        string title,
        string message,
        CancellationToken cancellationToken);

    Task<IReadOnlyList<NotificationDto>> NotifyAdminsAsync(
        string title,
        string message,
        CancellationToken cancellationToken);
}
```

- [ ] **Step 2: Add an authenticated hub with server-controlled membership**

Implement `[Authorize] public sealed class NotificationHub : Hub`. In `OnConnectedAsync`, parse `ClaimTypes.NameIdentifier` with fallback to `sub`; abort invalid connections; otherwise add `Context.ConnectionId` to:

```csharp
$"user:{userId:D}"
```

Do not accept a user ID or group name from a client method.

- [ ] **Step 3: Implement persist-then-publish behavior**

`RealtimeNotificationService.NotifyUserAsync` must create a new `Notification` with `Guid.CreateVersion7()`, `IsRead = false`, and `DateTime.UtcNow`; await `INotificationRepository.CreateAsync`; map the persisted entity to `NotificationDto`; then publish:

```csharp
await _hubContext.Clients
    .Group($"user:{userId:D}")
    .SendAsync("NotificationReceived", dto, cancellationToken);
```

Catch and log only the SignalR publish exception after persistence. Do not catch the repository exception. Return the DTO even when no client is connected.

`NotifyAdminsAsync` must enumerate current users, resolve their roles using `IIdentityService.GetRolesAsync`, select active users whose roles contain `Admin` case-insensitively, and call the same persist/publish helper once per Admin so each receives its own notification ID. Do not send the same DTO to a shared Admin group.

- [ ] **Step 4: Register and map SignalR**

In `AddInfrastructure`, register:

```csharp
services.AddScoped<IRealtimeNotificationService, RealtimeNotificationService>();
```

In `Program.cs`, add `builder.Services.AddSignalR()` and map:

```csharp
app.MapHub<NotificationHub>("/hubs/notifications")
   .RequireAuthorization()
   .RequireRateLimiting("api");
```

Extend the existing `JwtBearerEvents` without removing token revocation or forbidden behavior. `OnMessageReceived` may copy `access_token` into `context.Token` only when `Request.Path.StartsWithSegments("/hubs/notifications")`.

- [ ] **Step 5: Compile the backend**

Run:

```powershell
dotnet build backend/src/Locker.Backend/Locker.Backend.csproj -m:1
```

Expected: exit code `0`, with no missing SignalR registration/type errors.

- [ ] **Step 6: Review and commit the transport layer**

Run `git diff --check`, inspect that the hub has `[Authorize]`, and confirm query-string tokens are restricted to the exact hub path. Commit:

```powershell
git add backend/src/Locker.Backend.Application/Interfaces/IRealtimeNotificationService.cs backend/src/Locker.Backend.Infrastructure/Notifications/NotificationHub.cs backend/src/Locker.Backend.Infrastructure/Notifications/RealtimeNotificationService.cs backend/src/Locker.Backend.Infrastructure/DependencyInjection.cs backend/src/Locker.Backend/Program.cs
git commit -m "feat: add authenticated notification hub"
```

---

### Task 2: Remove notification seeds and connect delivery notifications

**Files:**
- Modify: `backend/src/Locker.Backend.Infrastructure/Data/DbSeeder.cs`
- Modify: `backend/src/Locker.Backend.Application/Features/DeliveryRequests/Commands/CreateDeliveryRequest/CreateDeliveryRequestCommand.cs`

**Interfaces:**
- Consumes: `IRealtimeNotificationService.NotifyUserAsync(...)` from Task 1.
- Produces: no notification seed inserts and a persisted/realtime notification for a registered delivery receiver.

- [ ] **Step 1: Remove notification seed generation**

Delete the `INotificationRepository` resolution from `DbSeeder.SeedAsync` if it becomes unused. Delete the `notificationTitles`, `notificationMessages`, and notification creation loop. Preserve all unrelated seeding.

- [ ] **Step 2: Replace the delivery handler's direct repository dependency**

Replace `INotificationRepository` with `IRealtimeNotificationService`. When a receiver is found, call:

```csharp
await _notificationService.NotifyUserAsync(
    receiver.Id,
    "Kiện hàng mới",
    $"Bạn có một kiện hàng mới từ {request.SenderName} tại tủ {item.LockerId}",
    cancellationToken);
```

Keep the existing behavior where no notification is created if the receiver phone is not registered.

- [ ] **Step 3: Verify backend and seed removal**

Run:

```powershell
rg -n "notificationTitles|notificationMessages|Generate Notifications" backend/src/Locker.Backend.Infrastructure/Data/DbSeeder.cs
dotnet build backend/src/Locker.Backend/Locker.Backend.csproj -m:1
git diff --check
```

Expected: `rg` returns no matches; build and diff check exit successfully.

- [ ] **Step 4: Commit**

```powershell
git add backend/src/Locker.Backend.Infrastructure/Data/DbSeeder.cs backend/src/Locker.Backend.Application/Features/DeliveryRequests/Commands/CreateDeliveryRequest/CreateDeliveryRequestCommand.cs
git commit -m "feat: publish delivery notifications"
```

---

### Task 3: Publish SePay and feedback business notifications

**Files:**
- Modify: `backend/src/Locker.Backend.Application/Features/Wallet/Commands/SepayProcessIpn/SepayProcessIpnCommand.cs`
- Modify: `backend/src/Locker.Backend.Application/Features/Feedback/Commands/UpsertMyFeedback/UpsertMyFeedbackCommand.cs`

**Interfaces:**
- Consumes: `NotifyUserAsync` and `NotifyAdminsAsync` from Task 1.
- Produces: one wallet notification on the first `Pending -> Completed` transition, plus one independently persisted notification per Admin after each feedback upsert.

- [ ] **Step 1: Add the wallet-owner notification**

Inject `IRealtimeNotificationService` into `SepayProcessIpnCommandHandler`. After the payment update and wallet transaction creation succeed, call:

```csharp
await _notificationService.NotifyUserAsync(
    payment.UserId,
    "Nạp tiền thành công",
    $"Ví E-Box Pay của bạn đã được cộng {payment.Amount:N0} đ.",
    cancellationToken);
```

Keep this call below the existing early return for `PaymentStatus.Completed`. Therefore replaying a completed IPN creates no duplicate notification. Do not include the SePay transaction ID, payment ID, secret, or webhook payload.

- [ ] **Step 2: Distinguish feedback create versus update without changing repository contracts**

Before `UpsertByUserIdAsync`, call `GetByUserIdAsync(request.UserId, cancellationToken)` and record `isUpdate = existing is not null`. After the upsert succeeds, call:

```csharp
await _notificationService.NotifyAdminsAsync(
    isUpdate ? "Feedback đã được cập nhật" : "Feedback mới",
    $"Có feedback {request.Rating}/5 về chủ đề {request.Topic} cần xem xét.",
    cancellationToken);
```

Do not include `request.Content`, email, token, or feedback/user GUID in the message.

- [ ] **Step 3: Verify ordering, idempotency, and compilation**

Read the final handlers and verify:

- Completed-IPN early return occurs before notification creation.
- Wallet/payment persistence occurs before notification creation.
- Feedback upsert occurs before Admin notification creation.

Run:

```powershell
dotnet build backend/src/Locker.Backend/Locker.Backend.csproj -m:1
git diff --check
```

Expected: both commands exit successfully.

- [ ] **Step 4: Commit**

```powershell
git add backend/src/Locker.Backend.Application/Features/Wallet/Commands/SepayProcessIpn/SepayProcessIpnCommand.cs backend/src/Locker.Backend.Application/Features/Feedback/Commands/UpsertMyFeedback/UpsertMyFeedbackCommand.cs
git commit -m "feat: publish wallet and feedback notifications"
```

---

### Task 4: Add the web notification API and SignalR client

**Files:**
- Create: `web/src/features/notifications/types.ts`
- Create: `web/src/features/notifications/api/notificationsApi.ts`
- Create: `web/src/features/notifications/api/notificationsRealtime.ts`
- Modify: `web/src/lib/api.ts`
- Modify: `web/package.json`
- Modify: `web/package-lock.json`

**Interfaces:**
- Consumes: existing REST endpoints and `/hubs/notifications` from Task 1.
- Produces: `NotificationDto`, `getMyNotifications`, `markNotificationAsRead`, `markAllNotificationsAsRead`, and `createNotificationsConnection(onNotification, onReconnected)`.

- [ ] **Step 1: Install the official browser client**

Run from the repository root:

```powershell
npm.cmd --prefix web install @microsoft/signalr
```

Expected: `package.json` and `package-lock.json` include `@microsoft/signalr`.

- [ ] **Step 2: Define the exact DTO**

```ts
export interface NotificationDto {
  id: string;
  title: string;
  message: string;
  isRead: boolean;
  createdAt: string;
}
```

- [ ] **Step 3: Implement REST operations using the shared API client**

Each function must throw a Vietnamese `Error` on non-2xx without assuming the error body is JSON:

```ts
export async function getMyNotifications(): Promise<NotificationDto[]>;
export async function markNotificationAsRead(id: string): Promise<void>;
export async function markAllNotificationsAsRead(): Promise<void>;
```

Use `encodeURIComponent(id)` and accept `204 No Content` for mutation success.

- [ ] **Step 4: Expose the backend origin safely**

In `web/src/lib/api.ts`, retain `VITE_API_BASE_URL || '/api'` for REST and export a helper that converts:

- `https://api.example.com/api` to `https://api.example.com`
- `/api` to `window.location.origin`
- an absolute base URL without `/api` to its own origin/path without a trailing slash

Do not hard-code production or localhost URLs.

- [ ] **Step 5: Build the authenticated SignalR connection factory**

Use `HubConnectionBuilder`, `.withUrl(`${getApiOrigin()}/hubs/notifications`, { accessTokenFactory })`, `.withAutomaticReconnect([0, 2000, 5000, 10000, 30000])`, and `.configureLogging(LogLevel.Warning)`.

The token factory must read the current `localStorage.getItem('token')` each time and return `''` when absent. Register `NotificationReceived` before calling `start()`. Register `onreconnected` to invoke the supplied recovery callback. Return the `HubConnection` so the React effect can stop it during cleanup.

- [ ] **Step 6: Compile the web client**

Run:

```powershell
npm.cmd --prefix web run build
```

Expected: exit code `0`, no missing SignalR/type errors.

- [ ] **Step 7: Commit**

```powershell
git add web/package.json web/package-lock.json web/src/lib/api.ts web/src/features/notifications/types.ts web/src/features/notifications/api/notificationsApi.ts web/src/features/notifications/api/notificationsRealtime.ts
git commit -m "feat: add realtime notification client"
```

---

### Task 5: Replace the web notification dropdown mock with REST plus realtime state

**Files:**
- Modify: `web/src/features/notifications/components/NotificationsDropdown.tsx`

**Interfaces:**
- Consumes: all Task 4 web APIs and `NotificationDto`.
- Produces: real persisted notification dropdown with loading/error/retry, realtime merge, reconnect recovery, and API-backed read state.

- [ ] **Step 1: Replace seed imports and state**

Remove `getNotificationsByUser`, `SeedNotification`, `Link`, and the `userId ?? 'u-001'` fallback. Add:

```ts
const [notifications, setNotifications] = useState<NotificationDto[]>([]);
const [isLoading, setIsLoading] = useState(true);
const [error, setError] = useState<string | null>(null);
```

- [ ] **Step 2: Add one reusable authoritative reload function**

Create a `useCallback` function that calls `getMyNotifications`, sorts descending by `createdAt`, replaces state, and handles error/loading. Use a mounted/request-generation guard so an older reload cannot overwrite newer state after reconnect.

- [ ] **Step 3: Start one SignalR connection and merge events by ID**

On mount, run the initial REST load, create/start the connection, and register this merge behavior:

```ts
setNotifications(current => {
  const withoutDuplicate = current.filter(item => item.id !== incoming.id);
  return [incoming, ...withoutDuplicate];
});
```

After reconnect, call the authoritative reload. On cleanup, invalidate pending loads and await/trigger `connection.stop()` without updating unmounted state.

- [ ] **Step 4: Make read mutations authoritative**

For a single row, await `markNotificationAsRead(id)` before setting that row's `isRead` to `true`. For mark-all, await the REST mutation before updating all rows. Disable repeated mutation clicks while the corresponding request is running; on failure keep the previous state and show a retryable error.

- [ ] **Step 5: Render loading, retryable error, and real empty state**

Use these Vietnamese states:

- Loading: `Đang tải thông báo...`
- Error: `Không thể tải thông báo.` with button `Thử lại`
- Empty: `Không có thông báo nào.`

Keep the existing dropdown layout and dark/light behavior. Keep the unread badge derived only from real `!isRead` items.

- [ ] **Step 6: Verify there are no web notification seed dependencies**

Run:

```powershell
rg -n "SEED_NOTIFICATIONS|getNotificationsByUser|SeedNotification|u-001" web/src/features/notifications web/src/components/layout/AppHeader.tsx
npm.cmd --prefix web run build
git diff --check
```

Expected: `rg` returns no matches; build and diff check succeed.

- [ ] **Step 7: Commit**

```powershell
git add web/src/features/notifications/components/NotificationsDropdown.tsx
git commit -m "feat: show live persisted notifications"
```

---

### Task 6: Manual end-to-end verification and final review

**Files:**
- No product files unless a verified defect requires a focused fix.

**Interfaces:**
- Consumes: completed backend/web notification implementation.
- Produces: evidence that real notifications persist, route correctly, reconnect, and avoid duplicates.

- [ ] **Step 1: Run fresh builds and static checks**

```powershell
dotnet build backend/src/Locker.Backend/Locker.Backend.csproj -m:1
npm.cmd --prefix web run build
git diff --check
git status --short
```

Expected: both builds and diff check exit `0`; status contains only intended work.

- [ ] **Step 2: Start local services**

Start MongoDB using the project's normal local setup, then run backend and web in separate terminals:

```powershell
dotnet run --project backend/src/Locker.Backend/Locker.Backend.csproj
npm.cmd --prefix web run dev
```

Use the configured local URL. Do not paste access tokens or secrets into test evidence.

- [ ] **Step 3: Verify fresh empty state**

Sign in as an account with no notification records. Open the bell and confirm `Không có thông báo nào.` appears and no seeded welcome/order notification is returned by `GET /api/notifications/my`.

- [ ] **Step 4: Verify delivery routing and persistence**

Open sender and registered receiver sessions. Create a delivery request addressed to the receiver's registered phone. Confirm only the receiver receives `NotificationReceived`, the unread badge increments, and refresh retains the record.

- [ ] **Step 5: Verify feedback routing to Admins**

Keep an Admin and ordinary user session open. Submit feedback and then update it. Confirm each action creates a new Admin notification, ordinary users do not receive it, and the full feedback content is absent from the SignalR payload.

- [ ] **Step 6: Verify SePay top-up notification and duplicate protection**

Complete one valid local SePay IPN using the already configured public tunnel. Confirm the wallet owner receives one notification after the payment becomes `Completed`. Replay the same IPN and confirm the notification count does not increase.

- [ ] **Step 7: Verify read state and reconnect recovery**

Mark one and then all notifications read and refresh to confirm persistence. Temporarily disconnect the browser network, create a real notification, reconnect, and confirm the REST recovery adds it exactly once.

- [ ] **Step 8: Inspect security and final diff**

In browser network tools, confirm the hub negotiates at `/hubs/notifications`, an unauthenticated connection is rejected, and no user-controlled group parameter exists. Inspect `git diff`/recent commits for secrets, generated build output, unrelated edits, or notification seed fallback.

- [ ] **Step 9: Commit only verified fixes, if any**

If manual verification required code corrections, rerun both builds and `git diff --check`, then create one focused fix commit. If no corrections were needed, do not create an empty commit.
