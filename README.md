# LODBOD Shipper

The LODBOD shipper app for Android. Shippers create an account, post loads,
compare carrier bids, book a carrier and follow every shipment to delivery.
Accounts use **Firebase Authentication**, data lives in **Cloud Firestore**,
and every screen updates live.

| | |
|---|---|
| Platform | Android (minSdk 24) |
| Flutter / Dart | Flutter **3.47.2** (stable) · Dart **3.13.2** |
| State management | Riverpod 3 (`flutter_riverpod` 3.5, no code generation) |
| Navigation | go_router 18: session-driven redirects, stateful tab shell |
| Backend | Firebase Auth (email + password) and Cloud Firestore, project `lodbod-ravi` |
| Design | Material 3 Expressive (Google's 2025–26 design language): tonal palette generated from LODBOD orange, rounded cards, pill buttons and segmented buttons, Android 16-style grouped lists, an icon-only bottom bar with a raised **Post load** button; Inter typeface |
| Tests | 161: business rules, Firestore repositories, live tracking, auth and account flows, end-to-end journeys through the real UI, small-screen layout checks |

Technical note (data flow, repositories, trade-offs, production notes):
[docs/TECHNICAL_NOTE.md](docs/TECHNICAL_NOTE.md). Screenshots are
[below](#screenshots).

---

## Try it

**Create an account** in the app (Create a shipper account → details →
verify email), or use the demo account. On a fresh Firebase project, register
it once with these details first (Firebase accounts can't be pre-seeded from
the app):

| | |
|---|---|
| Phone | `9800000001` (or email `aarav@example.com`) |
| Password | `Lodbod@123` |

A new account starts empty with a short welcome. Tap **Explore with sample
shipments** (also under **Account → Load sample shipments**) to load the
brief's sample data: LOD-1001 to LOD-1004 and three bids on LOD-1002.

### Core journey

1. **Log in.** Home shows *Mobile requests · 3 of 3 in use* (see
   [Assumptions](#assumptions)) and Active 2 · Awaiting bids 1 · Completed 1.
2. **Needs your action → 3 bids on LOD-1002.** Compare Himalayan Cargo,
   Swift Transport and Everest Freight Lines, sorted by newest, price,
   rating or speed. No offer is labelled "best".
3. Open an offer → **Accept for Rs. …** → confirm in the sheet. LOD-1002
   becomes *Confirmed*, the other offers show *Not selected*, and the carrier
   card appears with a call button and ETA.
4. **Post Load** (centre button): route → cargo → vehicle → review →
   **Post load**. At 3 of 3 the post is refused with the prescribed message,
   and everything you entered is kept.
5. Free a slot: open **LOD-1001 → ⋮ → Simulate: mark delivered**, or cancel a
   request.
6. **Post Load** again: your form is still there. Post it to get
   **LOD-1005**. About 20 seconds later carrier bids arrive with an in-app
   alert; accept one, then **Track shipment**.

---

## Features

| Area | What's there |
|---|---|
| **Splash & session** | Brand splash while the saved session is restored; you stay signed in across restarts until you sign out. |
| **Log in** | Google-style sign-in: large headline, one *Email or phone number* field (the app works out which), validation, show/hide password, loading state, clear errors, *Forgot password?*, and *Create account* / *Log in* actions pinned above the keyboard. |
| **Create account** | Two steps: shipper details (name, phone, email, optional company, password with strength meter, terms consent), then **verify email** (real verification email, resend with cooldown, "skip for now"). Duplicate phone or email is caught; an interrupted sign-up can be finished from *Finish setting up*. |
| **Forgot password** | Email or phone → Firebase password-reset email. The response is the same whether or not the account exists. |
| **Role check** | Only `shipper` accounts can use the app. Other roles are signed out with an explanation, and clients can't change their own role. |
| **Home** | Greeting, notifications bell with unread badge, request-limit card with *How it works*, Active / Awaiting bids / Completed tiles that open the filtered list, *Needs your action*, *On the road* (live progress), *Next pickup*, recent shipments, pull to refresh, skeleton loading, welcome for new accounts. |
| **Notifications** | Feed of bids, bookings, pickups and deliveries built from live data, grouped Today / Yesterday / Earlier; unread highlight; tap through to the shipment or offer. |
| **In-app alerts** | Toasts for new bids and delivery updates while the app is open, each with a *View* action; switch them on or off in Account. |
| **Shipments** | Search (reference, route words, cargo), status chips with counts, sort sheet (newest, pickup date, status), compact cards, empty states, pull to refresh. |
| **Shipment details** | Status, route with pickup and ETA, 5-step progress, a context card (finding carriers, *N carriers have bid*, carrier with call button, cancelled), details, pickup contact with call, activity log. The main action changes with status: *Compare bids*, *Track shipment*, *Post a similar load*. The ⋮ menu has copy reference, cancel, and labelled carrier simulations. |
| **Tracking** | Live over Firestore: a simulated driver reports the truck's position every 5 seconds and every device watching follows it (*Live · simulated driver · updated 3s ago*), with speed, live ETA, km remaining, *Arrived* at the destination and a *Simulate: fast-forward ×60* switch for demos. Stylised route map with checkpoints, carrier card with call, stop list. Without reports it falls back to a schedule estimate labelled *Simulated tracking*. |
| **Bids** | Load summary, sort chips, comparable offer cards (fare, delivery date, vehicle and a neutral *under / over your budget*). **Accept straight from a card** or open *Details* first; both use the same confirmation sheet, and the shipment and all bids update in one transaction. No offer is labelled "best". |
| **Post Load** | Four-step flow with a Material 3 step header (*Step 2 of 4 · Cargo details* and a segmented progress bar; tap a finished segment to go back), recent-city shortcuts, city suggestions, swap, date and time chips with pickers (times that have already passed today are disabled), summaries of completed steps with *Edit*, a review screen and a confirmation screen. **Save draft** stores the form on your account and it comes back next time, on any device. Closing never loses input. *Post a similar load* prefills from an earlier shipment. |
| **Three-request limit** | Enforced in the Firestore create transaction and in the security rules. The prescribed message appears in a sheet on refusal, and the form data is preserved. Usage appears on Home, Post Load, Review, Analytics and Account. |
| **Analytics** | Period switch (30 days / 90 days / all time), booked spend, loads posted / open / delivered (tonnes), bids, top routes, status breakdown. |
| **Account** | Profile & company (edit; phone change re-indexes sign-in), email verification status, request usage, alert switches, help center (FAQ), send feedback (stored in Firestore), Terms and Privacy pages, sample data, sign out (keeps your draft). |
| **Preferences** | **Language**: English or नेपाली, every screen and message translated (`lib/l10n/*.arb`, `flutter gen-l10n`). **Appearance**: System / Light / Dark with a full dark palette. **Notifications**: one master switch over bid and delivery alerts. Language and appearance are stored on the device; alerts on the account. |

Design: one component set used everywhere (cards, pills, pill tabs, choice
chips, list groups, bottom sheets, toasts, skeletons). The bottom bar shows
Home, Shipments, Analytics and Account as icons (labels are tooltips and
screen-reader names, and Shipments carries a count of offers waiting for a
decision) with Post Load raised in the centre; content scrolls under the
button. Typography is Inter.
Status always shows an icon and text, never colour alone. Touch targets are
44 px or larger, with semantic labels for screen readers, haptic feedback on
key actions, Android 14-style page transitions, and an adaptive launcher
icon.

---

## Setup

### Prerequisites

- Flutter 3.47.x (stable) with Dart 3.13. Check with `flutter --version`.
- Android SDK and an emulator or device (Android 7.0 / API 24+), JDK 17+.
- For iOS: Xcode and a simulator (iOS 15+).
- Optional: Firebase CLI for the local emulators or deploying rules.

### Firebase (one-time, in the console for project `lodbod-ravi`)

The app is already wired to the project (`android/app/google-services.json`
and the matching `lib/firebase_options.dart`).

1. **Authentication → Get started → Sign-in method → Email/Password →
   Enable.**
2. **Firestore Database → Create database** (if it doesn't exist).
3. **Firestore → Rules:** paste [`firestore.rules`](firestore.rules) →
   **Publish**, or run `firebase deploy --only firestore:rules --project lodbod-ravi`.
   Publish again whenever the file changes (live tracking added the
   `tracking` collection; until then tracking shows the schedule estimate).

No composite indexes are needed.

### Run

```bash
flutter pub get
flutter run                                  # against the live Firebase project
```

Fully local, no cloud project needed. The emulators also enforce
`firestore.rules`:

```bash
firebase emulators:start --only auth,firestore --project lodbod-ravi
flutter run --dart-define=USE_FIREBASE_EMULATORS=true   # Android emulator → 10.0.2.2, iOS simulator → 127.0.0.1
```

### Test, analyse, build

```bash
flutter analyze                 # no issues
flutter test                    # 161 tests
flutter build apk --release     # build/app/outputs/flutter-apk/app-release.apk
```

The release build is signed with the debug key, which is fine for
sideloading but not for the Play Store.

---

## Architecture

```
lib/
  main.dart, app.dart    start-up (Firebase, ProviderScope) and the MaterialApp
  routing/               router, auth redirect, tab shell
  core/                  feature-agnostic: errors/ and utils/ (pure Dart),
                         firebase/ (guard, error mapping, schema), theme/,
                         widgets/ (UI kit), constants/, platform/
  features/<feature>/    auth, account, shipments, bids, tracking,
                         create_shipment, dashboard, analytics, notifications
    domain/              models, repository contract, business rules (pure Dart)
    data/                Firebase repository + mapper; providers.dart wires it
    presentation/        screens, widgets and their Riverpod state
```

**Dependency rule:** feature-first clean architecture with three layers. Inside each feature, presentation → domain ← data; domain is pure Dart, with no Flutter or Firebase. A feature may use another feature's domain, state and widgets, but never its data internals (only `data/providers.dart`) or its screens (navigation goes through routes). core is feature-agnostic, and only data layers, core/firebase and start-up import Firebase. `test/architecture_test.dart` fails the build on any violation. Details: docs/TECHNICAL_NOTE.md §1.

**Session:** `authUserProvider` (Firebase auth state) and `profileProvider`
(`users/{uid}`) combine into one `Session` state: *loading*, *signed out*,
*needs profile*, *wrong role* or *ready*. The router's redirect is a pure
function of that state (`redirectFor`, unit-tested), so routing can't drift
from the real auth state.

**Single source of truth:** one live `shipmentsProvider` per user. Dashboard
counts, the filtered list, details, analytics, the activity feed and the
request meter are all derived from it.

### Firestore data model

```
users/{uid}                  name, company, phone, email, role:"shipper",
                             activeRequestCount (0..3), notificationsSeenAt,
                             bidAlerts, statusAlerts, createdAt
users/{uid}/drafts/current   saved Post Load draft
phoneIndex/{phone}           {uid, email}: phone sign-in lookup
shipments/{id}               reference "LOD-1005", shipperId, route, cargo, weight,
                             vehicle, pickupAt, status, budget, agreedFare, bidCount,
                             acceptedBidId, carrier name/phone/plate, etaAt,
                             contact, notes, timeline[], createdAt, updatedAt
bids/{id}                    shipmentId, shipperId, carrier, rating, trips, fare,
                             delivery days, vehicle, carrier phone/plate, status, note
tracking/{shipmentId}        latest position report: shipperId, progress (0..1),
                             speedKmh, speedFactor, etaAt, updatedAt,
                             tripStartedAt, source ("simulated")
meta/counters                nextShipmentNumber (unique references)
feedback/{id}                uid, topic, message, createdAt (write-only)
```

**Security rules** ([`firestore.rules`](firestore.rules)): every document is
readable and writable only by its owner (`request.auth.uid`). Role, email,
reference and route are immutable; the request counter is capped at 3; the
reference counter only moves forward; feedback is write-only; the phone index
supports single lookups but can't be listed.

### Critical operations (Firestore transactions)

- **Post a load:** reads the request counter and reference counter, refuses
  at 3, then writes the shipment, increments the counter and allocates
  `LOD-n`, all atomically. The document id is created once per draft and
  reused on retry, so a lost response never creates a duplicate.
- **Accept a bid:** confirms the shipment, stores the carrier, fare and ETA,
  accepts this bid and declines the others in one commit. Retrying the same
  bid is safe; a second, different bid is refused.
- **Cancel / carrier updates:** move the status, keep the counter in step,
  and reject stale transitions.

## Production enforcement

The client transaction plus rules prevent accidental or concurrent
over-posting. A tampered client could still skip the counter, so for
production:

1. Keep Firebase Auth. Add phone OTP so phone login no longer needs the
   `phoneIndex` lookup.
2. Move *post load* and *accept bid* into callable Cloud Functions (or the
   LODBOD API) that run the same transactions with the Admin SDK, using the
   client's request id as an idempotency key, and deny direct client writes to
   `shipments`, `bids` and the counter.
3. Carriers write bids and status updates from their own app or backend; a
   scheduled job expires stale requests.
4. Apply the limit to mobile-channel requests server-side.

---

## Assumptions

- **Limit counting** follows the brief: Awaiting bids, Confirmed, Scheduled
  and In transit count; Delivered, Cancelled and Expired don't. The sample
  data therefore starts at **3 of 3**, and the app makes the way out clear.
- **Sample dates are relative to when they're loaded** (LOD-1001 is always
  mid-route, LOD-1004 always a few days ahead). If the sample data is more
  than 3 hours old and still untouched, it refreshes with current dates at
  sign-in. Once you accept a bid, post a load or change a status, it's left
  alone.
- **Expiry:** a request still awaiting bids after its pickup time becomes
  *Expired* and frees its request slot; its bids can no longer be accepted.
  Production runs this as a server job; here the app does it at sign-in.
- **Carrier side is simulated** because this build has no carrier app or
  backend:
  - Bids arrive about 20 seconds after a load is posted. This runs only
    while the app is open and is idempotent.
  - Carrier status updates are available from the shipment's ⋮ menu,
    labelled *Simulate*.
  - Tracking is live over Firestore, but the driver is simulated: while a
    tracking screen is open, the app reports the truck's position to
    `tracking/{shipmentId}` every 5 seconds (one transaction, skipped if
    another device reported moments ago, so watchers never double up). The
    truck drives at a realistic speed, or ×60 with fast-forward, and stops
    at the destination; delivery is still confirmed from the ⋮ menu. With
    no fresh reports, the position is estimated from the schedule. In
    production the carrier's driver app would send real GPS positions to
    the same document through the backend.
- All carriers, phone numbers, fares and ratings are fictional.

## Known limitations

- Bids are written by the shipper's own client (simulation), so the rules
  allow owners to write them. Production moves this to the carrier side.
- No SMS OTP: the reference shows phone OTP, but this build verifies the
  account by email link (Firebase phone auth needs SHA keys and SMS
  billing). Phone number + password login works.
- No push notifications: alerts are in-app, while the app is open.
- Lists aren't paginated (production: index on `shipperId, createdAt` +
  cursors).
- iOS is simulator-only for now: no iOS app is registered in `lodbod-ravi` yet,
  so `lib/firebase_options.dart` uses a placeholder App ID and the Android
  client key. Register one and replace both values before shipping iOS.

---

## Screenshots

Rendered from the real app by its widget-test harness on a Pixel 7 frame
(412×915) over the brief's sample data, so every frame is reproducible:

```bash
flutter test test/docs_screenshots_test.dart --dart-define=SCREENSHOTS=true
```

| Splash | Log in | Create account | Forgot password |
|---|---|---|---|
| ![](docs/screenshots/01-splash.png) | ![](docs/screenshots/02-login.png) | ![](docs/screenshots/03-register.png) | ![](docs/screenshots/04-forgot-password.png) |
| **Welcome (new account)** | **Home** | **Notifications** | **Shipments** |
| ![](docs/screenshots/05-welcome.png) | ![](docs/screenshots/06-home.png) | ![](docs/screenshots/07-notifications.png) | ![](docs/screenshots/08-shipments.png) |
| **Shipment details** | **Compare & accept bids** | **Offer details** | **Accept sheet** |
| ![](docs/screenshots/09-details.png) | ![](docs/screenshots/10-bids.png) | ![](docs/screenshots/11-offer.png) | ![](docs/screenshots/12-accept-sheet.png) |
| **Booked** | **Tracking** | **Post Load: route** | **Post Load: cargo** |
| ![](docs/screenshots/13-booked.png) | ![](docs/screenshots/14-tracking.png) | ![](docs/screenshots/15-post-route.png) | ![](docs/screenshots/16-post-cargo.png) |
| **Post Load: vehicle** | **Review** | **Limit reached** | **Load posted** |
| ![](docs/screenshots/17-post-vehicle.png) | ![](docs/screenshots/18-review.png) | ![](docs/screenshots/19-limit.png) | ![](docs/screenshots/20-posted.png) |
| **Analytics** | **Account** | **Help center** | **Edit profile** |
| ![](docs/screenshots/21-analytics.png) | ![](docs/screenshots/22-account.png) | ![](docs/screenshots/23-help.png) | ![](docs/screenshots/24-edit-profile.png) |
| **Preferences (dark)** | **Home (dark)** | **Home (नेपाली)** | **Details (नेपाली)** |
| ![](docs/screenshots/25-preferences-dark.png) | ![](docs/screenshots/26-home-dark.png) | ![](docs/screenshots/27-home-nepali.png) | ![](docs/screenshots/28-details-nepali.png) |


---

## Third-party code and AI assistance

- Packages: `material_ui`, `flutter_riverpod`, `go_router`, `firebase_core`,
  `firebase_auth`, `cloud_firestore`, `url_launcher`; dev: `flutter_lints`,
  `fake_cloud_firestore`. Font: Inter (SIL Open Font License,
  `assets/fonts/OFL.txt`). No templates or copied snippets.
- AI assistance: built with the help of **Claude Code** (Anthropic's AI
  coding assistant) for scaffolding, UI iteration, tests and documentation.
- What I personally implemented and decided: <!-- fill in: e.g. the data
  model and Firestore layout, the request-limit and bid-acceptance rules,
  the architecture choices (Riverpod, go_router, repository interfaces),
  the Firebase project setup and security rules, the UX decisions, and
  manual testing on a device -->
