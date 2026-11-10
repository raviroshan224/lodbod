# Technical note: data flow, repositories and trade-offs

## 1. Data flow

```
 Widgets (screens)
   │ ref.watch(...)                          ▲ AsyncValue / Session
   ▼                                         │
 Riverpod providers & controllers ───────────┘
   │ authUserProvider ─┐
   │ profileProvider ──┴─► sessionProvider ──► router redirect (redirectFor)
   │ shipmentsProvider (live, per user) ← single source of truth
   │   ├─ shipmentSummaryProvider     dashboard tiles
   │   ├─ filteredShipmentsProvider   list: search + filter + sort
   │   ├─ shipmentByIdProvider(id)    details, tracking, confirmation
   │   ├─ requestLimitUsageProvider   limit meter / warnings
   │   └─ activityFeedProvider ◄── shipperBidsProvider   notifications, alerts
   │ bidsProvider(shipmentId)            bids, offer details
   │ CreateShipmentController            draft, steps, save/restore, submit
   │ ShipmentActionsController(id)       cancel, accept bid, simulated carrier events
   ▼
 Repository interfaces (data/repositories/repositories.dart)
   ▼
 Firebase implementations ── transactions ──► Firestore      Firebase Auth
                         ◄── snapshots() live streams          (sessions persist)
```

- **Reads are streams.** Every shipment-derived value comes from one
  per-user snapshot stream, passed through pure functions in `domain/`.
  After any write, Firestore pushes a new snapshot and every screen updates,
  with nothing to refresh by hand.
- **Writes are commands.** Controllers call repository methods that run
  Firestore transactions. Success is shown only after the server commits;
  buttons show progress and ignore repeat taps.
- **The session drives navigation.** Auth state and the profile document
  combine into one `Session` value. `redirectFor(session, location)` is a
  pure function, so routing and auth can't disagree, and it is unit-tested.
  Each tab keeps its own back stack (`StatefulShellRoute`). Detail screens
  live under their tab, but the posting flow (`/post-load`, `/posted/:id`)
  is top-level, so returning to a tab never reopens a finished flow.
- **Errors are typed.** Firebase Auth and Firestore errors map to
  `AppException`s with user-safe messages. Writes time out after 15 s, so a
  queued offline write never hangs the UI.

## 2. Repository design

Four interfaces describe business operations rather than CRUD:

- `AuthRepository`: sign in, create account, reset password, verify email,
  sign out.
- `AccountRepository`: profile, phone index, sample data, drafts,
  notifications-seen, feedback.
- `ShipmentRepository`: watch, create (limit + reference), cancel, carrier
  update.
- `BidRepository`: watch, accept (atomic, idempotent), simulate bids.

Models are plain Dart; Firestore mapping lives in `firestore_mappers.dart`.
Malformed documents are skipped and their ids logged, so one bad record
can't break a list. `data/providers.dart` is the only place that names
concrete classes.

## 3. Swapping in a REST backend

Implement the same interfaces (for example with `dio`):

- `createShipment` → `POST /shipments` with an `Idempotency-Key` equal to
  the request id.
- `acceptBid` → `POST /shipments/{id}/bids/{bidId}/accept`.
- `watchShipments` → SSE/WebSocket, or fetch plus refresh.

Map HTTP errors to the same exceptions: `409 LIMIT_REACHED` →
`RequestLimitReachedException`, `401` → sign-out, `5xx`/timeouts →
`NetworkException`. Then change the providers in `data/providers.dart`. No
screen changes, because screens only see `AsyncValue`s and `AppException`s.

## 4. Decisions and trade-offs

| Decision | Why | Cost / mitigation |
|---|---|---|
| Firebase Auth email/password + phone index | Real accounts, persisted sessions, real reset/verification emails; phone login as in the mockups. | The phone→email lookup is a public `get`; production replaces it with phone OTP. |
| Per-user security rules | Each shipper can only see their own data; role and email are immutable. | Bids are client-written in this build (simulation); production moves that to carriers. |
| Counter document for the limit | Transactions can't query; a counter makes check-and-increment atomic; rules cap it at 3. | It can drift, so it is re-derived at each sign-in. Production moves this server-side. |
| Client-generated shipment id as idempotency key | A retry after a lost response returns the original shipment. | A changed draft gets a new key (it's a different request). |
| Drafts on the account (`users/{uid}/drafts/current`) | Nothing typed is lost: survives closing, restarts and switching device. | One draft per user, which matches the single Post Load flow. |
| Simulated carrier marketplace | Lets a single user experience the whole lifecycle: bids arrive, booking, tracking, delivery. | Clearly labelled, idempotent, runs only while the app is open. |
| Activity feed derived, not stored | Can't disagree with shipments; unread state is one timestamp. | Feed size grows with history; production would page or store events. |
| Client-side expiry and sample refresh at sign-in | A request past its pickup must free its slot, and a demo account opened days later should still make sense. Both are idempotent, and sample data is only refreshed if untouched. | Only runs when the app opens; production moves expiry to a scheduled server job. |
| Custom design system | Consistent, denser, brand-specific UI like the reference mockups. | More widget code than stock Material. |

## 5. Discussion prep

- **Limit in production:** callable Cloud Function or API endpoint running
  the create transaction with the Admin SDK; rules deny direct writes; the
  request id is the idempotency key; a scheduled job handles expiry.
- **Accept fails or times out:** the transaction is all or nothing. The app
  says the offer "hasn't been accepted yet" and that retrying is safe; a
  retry of the same bid is a no-op if it already committed, and the live
  stream shows the truth.
- **Duplicates:** buttons and controllers block re-entry while in flight;
  creation is idempotent by id; a second, different accept is refused inside
  the transaction (Firestore retries the losing transaction, which then
  fails cleanly).
- **Pagination, tokens, offline:** cursor pagination on
  `shipperId, createdAt`; the Auth SDK refreshes tokens, and the session
  stream signs the user out if the token is revoked; the Firestore cache
  serves stale data offline while writes fail fast with a clear message.
- **Tests (118):** domain rules (limit, validation, filters agree with
  counts, activity feed, tracking); repositories on `fake_cloud_firestore`
  (limit, unique references, idempotent create/accept, duplicate refusal,
  lifecycle, owner-filtered queries); auth and account (registration
  rollback, phone sign-in, reset that reveals nothing, phone re-index,
  drafts, unread); widgets (login validation and sign-in, list filter and
  search); end-to-end journeys through the real router and screens (sign-out
  and phone login, accepting a bid, the limit block, disabled past times);
  and a layout sweep of every screen at 320×568 with ×1.3 text and 360×640
  with ×1.6 text. **Next:** emulator-backed tests of the security rules and
  golden tests for key screens.
