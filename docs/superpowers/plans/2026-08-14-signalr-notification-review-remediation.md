# SignalR Notification Review Remediation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Correct the verified local routing, initial connection, REST/realtime race, mutation error, and concurrent SePay IPN idempotency defects in the realtime notification implementation.

**Architecture:** Keep MongoDB as the notification source of truth and SignalR as the live delivery channel. Route the hub through Vite during local development, explicitly retry the initial SignalR start, reconcile REST snapshots with live events by notification ID, and use a conditional MongoDB payment transition so only one concurrent IPN owns the wallet-transaction and notification side effects.

**Tech Stack:** ASP.NET Core 10, SignalR, JWT bearer authentication, MongoDB.Driver, React 18, TypeScript, `@microsoft/signalr`, Vite.

## Global Constraints

- Fix only the verified review findings; do not introduce an outbox, message broker, or Flutter SignalR client.
- Do not create unit tests or mock tests; use builds, static checks, and manual verification.
- Do not restore seeded or mocked notification behavior.
- Do not expose tokens, SePay secrets, webhook payloads, payment IDs, or feedback content in notification payloads or logs.
- A sequential or concurrent replay of the same completed SePay IPN must not create a second wallet transaction or notification.
- Existing notification and wallet transaction records must not be deleted automatically.
- Preserve authenticated, server-controlled `user:{userId:D}` group membership.
- Do not push commits unless the user explicitly requests it.

---

## File Structure

### Modify

- `web/vite.config.ts` — proxy local SignalR HTTP/WebSocket traffic to the backend.
- `web/src/features/notifications/api/notificationsRealtime.ts` — own cancellable initial-start retry behavior.
- `web/src/features/notifications/components/NotificationsDropdown.tsx` — prevent REST/realtime state loss and separate load errors from read-mutation errors.
- `backend/src/Locker.Backend.Application/Interfaces/IPaymentRepository.cs` — expose an atomic pending-to-completed transition.
- `backend/src/Locker.Backend.Infrastructure/Repositories/PaymentRepository.cs` — implement the conditional MongoDB update.
- `backend/src/Locker.Backend.Application/Features/Wallet/Commands/SepayProcessIpn/SepayProcessIpnCommand.cs` — grant side-effect ownership only to the successful atomic transition.
- `web/src/mocks/seed.ts` — remove the unused notification mock definitions.

No new product files are required.

---

### Task 1: Make the SignalR connection reliable in local development and at initial startup

**Files:**
- Modify: `web/vite.config.ts`
- Modify: `web/src/features/notifications/api/notificationsRealtime.ts`
- Modify: `web/src/features/notifications/components/NotificationsDropdown.tsx`

**Interfaces:**
- Produces: local `/hubs/*` proxy with WebSocket forwarding.
- Produces: `startNotificationsConnection(connection, signal): Promise<void>` with bounded exponential retry until success or cancellation.
- Consumes: existing `createNotificationsConnection(...)` factory and component cleanup lifecycle.

- [ ] **Step 1: Add the local hub proxy**

Add a sibling entry to the existing `/api` proxy:

```ts
'/hubs': {
  target: 'http://localhost:5000',
  changeOrigin: true,
  ws: true,
},
```

Keep `getApiOrigin()` unchanged: when REST uses `/api`, it correctly returns the Vite origin, and Vite now forwards `/hubs/notifications` to the backend.

- [ ] **Step 2: Add a cancellable retry helper for the first connection**

Export this signature from `notificationsRealtime.ts`:

```ts
export async function startNotificationsConnection(
  connection: signalR.HubConnection,
  signal: AbortSignal,
): Promise<void>;
```

Implementation requirements:

- Attempt `connection.start()` immediately.
- Retry failed initial starts after `0`, `2_000`, `5_000`, `10_000`, then `30_000` milliseconds.
- Continue using `30_000` milliseconds for later attempts.
- Stop retrying when `signal.aborted` is true.
- Do not retry when `connection.state` is already `Connected`, `Connecting`, or `Reconnecting`.
- Implement the delay with an abort-aware Promise that removes its abort listener after resolve/reject.
- Log one warning per failed attempt without logging the access token.
- Leave `.withAutomaticReconnect(...)` in the factory for interruptions after a successful connection.

- [ ] **Step 3: Wire retry lifecycle into the dropdown**

Inside the SignalR effect:

```ts
const abortController = new AbortController();
void startNotificationsConnection(connection, abortController.signal);
```

In cleanup, call `abortController.abort()` before `connection.stop()`. Treat cancellation as normal cleanup and do not set component error state from it.

- [ ] **Step 4: Verify local routing and compilation**

Run:

```powershell
npm.cmd --prefix web run build
git diff --check
```

Then run backend and Vite locally and inspect the browser Network tab. Expected:

- `/hubs/notifications/negotiate` is requested from the Vite origin.
- Vite forwards it to `http://localhost:5000`.
- The connection upgrades to WebSocket when supported.
- Starting Vite before the backend causes retries; starting the backend later establishes the connection without reloading the page.

- [ ] **Step 5: Commit**

```powershell
git add web/vite.config.ts web/src/features/notifications/api/notificationsRealtime.ts web/src/features/notifications/components/NotificationsDropdown.tsx
git commit -m "fix: reconnect notification hub reliably"
```

---

### Task 2: Reconcile REST snapshots with realtime events without losing notifications

**Files:**
- Modify: `web/src/features/notifications/components/NotificationsDropdown.tsx`

**Interfaces:**
- Consumes: `NotificationDto` from the existing notification feature.
- Produces: one deterministic `mergeNotifications(current, incoming)` behavior used by REST and SignalR.

- [ ] **Step 1: Add a stable merge helper**

Define a module-level helper:

```ts
function mergeNotifications(
  current: NotificationDto[],
  incoming: NotificationDto[],
): NotificationDto[] {
  const byId = new Map(current.map(item => [item.id, item]));
  for (const item of incoming) {
    byId.set(item.id, item);
  }
  return [...byId.values()].sort(
    (a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime(),
  );
}
```

Incoming REST records replace matching local records so persisted `isRead` state wins. Unmatched realtime records already in `current` remain present.

- [ ] **Step 2: Merge REST results instead of replacing state**

Keep the request-generation and mounted guards, but replace:

```ts
setNotifications(sorted);
```

with:

```ts
setNotifications(current => mergeNotifications(current, items));
```

Do not clear a valid notification list when a later recovery load fails. Only the initial load may show the full load-error state when the list is empty.

- [ ] **Step 3: Use the same merge path for SignalR**

Replace the custom prepend/filter callback with:

```ts
setNotifications(current => mergeNotifications(current, [incoming]));
```

This prevents duplicate IDs and preserves descending timestamp order.

- [ ] **Step 4: Separate load failures from read-mutation failures**

Replace the single `error` state with:

```ts
const [loadError, setLoadError] = useState<string | null>(null);
const [mutationError, setMutationError] = useState<string | null>(null);
```

Requirements:

- Initial/recovery GET failures update `loadError`.
- Mark-one and mark-all failures update `mutationError` and leave the list visible.
- Render `mutationError` as a compact message above the list.
- Clear `mutationError` when the same action is attempted again or succeeds.
- A failed row remains unread and clickable, so clicking it again retries that exact mutation.
- A failed mark-all leaves the header action enabled after `isMarkingAll` returns to false.
- The `Thử lại` button in the full load-error state calls only `loadNotifications`.

- [ ] **Step 5: Verify race and retry behavior manually**

Use browser throttling to delay `GET /api/notifications/my`, then create a real notification while the GET is pending. Expected: the SignalR notification remains visible after the delayed GET finishes and appears exactly once.

Force a `500` or disconnect the backend before marking a row read. Expected: the existing list stays visible, the row stays unread, and repeating the row action after recovery succeeds.

- [ ] **Step 6: Build and commit**

```powershell
npm.cmd --prefix web run build
git diff --check
git add web/src/features/notifications/components/NotificationsDropdown.tsx
git commit -m "fix: reconcile realtime notification state"
```

Expected: build and diff check exit `0` before the commit.

---

### Task 3: Make SePay completion ownership atomic under concurrent IPNs

**Files:**
- Modify: `backend/src/Locker.Backend.Application/Interfaces/IPaymentRepository.cs`
- Modify: `backend/src/Locker.Backend.Infrastructure/Repositories/PaymentRepository.cs`
- Modify: `backend/src/Locker.Backend.Application/Features/Wallet/Commands/SepayProcessIpn/SepayProcessIpnCommand.cs`

**Interfaces:**
- Produces:

```csharp
Task<Payment?> TryCompletePendingAsync(
    Guid paymentId,
    string transactionId,
    DateTime paidAt,
    CancellationToken cancellationToken);
```

- The returned `Payment` is non-null only for the request that atomically changes `Pending` to `Completed`.

- [ ] **Step 1: Add the conditional transition contract**

Add `TryCompletePendingAsync` to `IPaymentRepository` with the exact signature above. Document that `null` means this caller did not own the transition.

- [ ] **Step 2: Implement one MongoDB compare-and-set operation**

In `PaymentRepository`, use `FindOneAndUpdateAsync` with:

```csharp
var filter = Builders<Payment>.Filter.And(
    Builders<Payment>.Filter.Eq(x => x.Id, paymentId),
    Builders<Payment>.Filter.Eq(x => x.Status, PaymentStatus.Pending));

var update = Builders<Payment>.Update
    .Set(x => x.Status, PaymentStatus.Completed)
    .Set(x => x.TransactionId, transactionId)
    .Set(x => x.PaidAt, paidAt);
```

Use `ReturnDocument.After`. Do not use `GenericRepository.UpdateAsync` for this transition.

- [ ] **Step 3: Grant side-effect ownership only to the winning IPN**

In the SePay handler, retain all signature/type/method/amount validations. Replace the mutable payment update with:

```csharp
var paidAt = ParseSepayDate(ipn.Transaction.TransactionDate) ?? DateTime.UtcNow;
var completedPayment = await _paymentRepository.TryCompletePendingAsync(
    payment.Id,
    gatewayTransactionId,
    paidAt,
    cancellationToken);
```

If `completedPayment` is `null`, reload the payment:

- If its status is `Completed`, return `Payment already processed.` without creating a wallet transaction or notification.
- Otherwise return the existing non-pending failure response.

Use `completedPayment` for the wallet transaction and notification paths. Only the winning request may execute those side effects.

- [ ] **Step 4: Preserve recovery semantics explicitly**

Keep the existing `existingWalletTransaction` check, but move it after the successful conditional transition and re-query it using `completedPayment.Id`. This protects deployments that already contain a wallet transaction for that payment.

Do not add MongoDB multi-document transactions in this remediation. Record in the code review handoff that a process crash after the payment compare-and-set but before wallet-transaction creation still requires a future outbox/reconciliation design; this plan fixes concurrent duplicate delivery, which is the verified review defect.

- [ ] **Step 5: Verify concurrent behavior manually**

Prepare one valid pending local SePay payment and send the identical IPN payload concurrently from two PowerShell jobs or two REST clients using the configured local IPN secret. Expected database state:

- Payment is `Completed` once.
- Exactly one completed top-up `WalletTransaction` references the payment ID.
- Exactly one wallet success notification exists for the user.
- Both webhook calls return a handled result rather than producing a duplicate balance.

Do not include the webhook secret or raw token in captured evidence.

- [ ] **Step 6: Build and commit**

Because the backend may already be running and locking its normal output directory, first try the normal build; if locked, use an isolated output:

```powershell
dotnet build backend/src/Locker.Backend/Locker.Backend.csproj -m:1
dotnet build backend/src/Locker.Backend/Locker.Backend.csproj --no-restore -m:1 -p:OutDir=D:\GitHub\Locker\.tmp\signalr-remediation-build\
git diff --check
```

Only the necessary successful build is required. Clean up the exact temporary output directory after verification. Then commit:

```powershell
git add backend/src/Locker.Backend.Application/Interfaces/IPaymentRepository.cs backend/src/Locker.Backend.Infrastructure/Repositories/PaymentRepository.cs backend/src/Locker.Backend.Application/Features/Wallet/Commands/SepayProcessIpn/SepayProcessIpnCommand.cs
git commit -m "fix: claim SePay completion atomically"
```

---

### Task 4: Remove the remaining notification mock definitions

**Files:**
- Modify: `web/src/mocks/seed.ts`

**Interfaces:**
- Produces: no `SeedNotification`, `SEED_NOTIFICATIONS`, or `getNotificationsByUser` definitions anywhere in the web source.

- [ ] **Step 1: Confirm the definitions have no consumers**

Run:

```powershell
rg -n "SeedNotification|SEED_NOTIFICATIONS|getNotificationsByUser" web/src
```

Expected before deletion: matches only in `web/src/mocks/seed.ts`.

- [ ] **Step 2: Delete only the notification mock block**

Remove the notification interface, notification array, and `getNotificationsByUser` helper. Preserve unrelated locker, booking, user, and dashboard seed objects that are outside this feature.

- [ ] **Step 3: Verify and commit**

```powershell
rg -n "SeedNotification|SEED_NOTIFICATIONS|getNotificationsByUser" web/src
npm.cmd --prefix web run build
git diff --check
git add web/src/mocks/seed.ts
git commit -m "chore: remove notification mock data"
```

Expected: `rg` returns no matches; build and diff check succeed.

---

### Task 5: Final manual regression review

**Files:**
- No product files unless a verified defect requires a focused fix.

**Interfaces:**
- Consumes: all remediation commits.
- Produces: evidence that local realtime delivery, recovery, reconciliation, routing, persistence, and IPN idempotency work together.

- [ ] **Step 1: Run fresh static verification**

```powershell
dotnet build backend/src/Locker.Backend/Locker.Backend.csproj --no-restore -m:1 -p:OutDir=D:\GitHub\Locker\.tmp\signalr-final-build\
npm.cmd --prefix web run build
git diff --check
rg -n "SeedNotification|SEED_NOTIFICATIONS|getNotificationsByUser|notificationTitles|notificationMessages" backend/src web/src
git status --short
```

Expected: both builds and diff check exit `0`; the mock/seed scan has no notification matches; status is clean after removing the exact temporary build output.

- [ ] **Step 2: Verify authentication and recipient isolation**

With Admin and ordinary-user sessions open, confirm unauthenticated hub negotiation returns `401`, each connection joins only its JWT-derived user group, feedback reaches Admins only, delivery reaches the registered receiver only, and wallet completion reaches the wallet owner only.

- [ ] **Step 3: Verify local startup and reconnect sequences**

Test both orders:

1. Backend first, then Vite.
2. Vite first, backend started after at least one failed initial attempt.

Then briefly interrupt and restore backend connectivity. Expected: initial retry and automatic reconnect both recover without a page reload, and REST recovery produces no duplicate IDs.

- [ ] **Step 4: Verify REST/realtime race and read mutations**

Repeat the delayed-GET race from Task 2. Mark one and all notifications read, refresh, and confirm MongoDB read state persists. Force one mutation failure and confirm the list stays visible and the failed action can be repeated.

- [ ] **Step 5: Verify concurrent SePay replay**

Repeat the concurrent duplicate IPN scenario from Task 3 and inspect payment, wallet transaction, wallet balance, and notification counts. Do not accept sequential-only replay as evidence for this finding.

- [ ] **Step 6: Final code review and optional fix commit**

Review the complete remediation diff against:

- `docs/superpowers/specs/2026-08-14-realtime-notifications-signalr-design.md`
- `docs/superpowers/plans/2026-08-14-realtime-notifications-signalr.md`
- this remediation plan.

If review finds a defect, make one focused correction, rerun both builds and the relevant manual scenario, then commit it. Do not create an empty commit.
