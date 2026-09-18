# TILOQ Paywall & Subscription Plan

Status: **planning only — nothing in this document is implemented yet.**

## Goal

Introduce a single, low-friction subscription ("TILOQ Plus") that unlocks a small set of delight/bonus features, while keeping the core writing experience free forever. No accounts, no server, no ads — consistent with `AGENTS.md`'s privacy invariants. StoreKit ties the entitlement to the user's Apple ID/device; TILOQ still never talks to a server of its own.

## What's free vs. paid

| Feature | Tier |
|---|---|
| Rewrite, Grammar, Improve (on-device AI) | **Free forever** |
| Typing, suggestions, cursor mode, all core keyboard behavior | **Free forever** |
| Encryption (AES-GCM, shared key text) | **Free** — confirmed |
| Built-in backdrop styles (None, Carbon, Aurora, Midnight) | **Free** — confirmed |
| Custom photo backdrop ("Choose Photo") | **Plus** |
| RGB per-key lighting | **Plus** |

Both scope questions are confirmed (2026-09-18): encryption stays free since it's a headline privacy feature, not a cosmetic extra; built-in gradient backdrops stay free, matching the common "basic themes free, custom content paid" pattern. Only two features are gated: **RGB lighting** and **custom photo backdrop**.

## Pricing & trial

- Single auto-renewable subscription, **$1.99/year**, with a **14-day free trial** (Apple's native "introductory offer" type on the subscription).
- No monthly tier, no lifetime/one-time tier, to keep the offering to one clear choice — matches the "few clear actions" product principle. (Can revisit later if data suggests otherwise.)
- Net revenue after Apple's cut (15% under the Small Business Program, which this account should qualify for as an individual developer under $1M/year) is ~$1.69/subscriber/year. Treat this as a sustainability/goodwill price, not a serious revenue driver — worth being explicit about which goal this serves.

## Architecture

**Key constraint:** keyboard extensions cannot reliably present StoreKit purchase UI or always call the full StoreKit API surface. The purchase flow must happen in `TiloqApp` (the container app); the keyboard extension only ever *reads* a cached entitlement flag.

- New `Shared/SubscriptionManager.swift` — an `actor`, mirroring the existing `LocalAIEngine` pattern:
  - Wraps StoreKit 2 (`Product`, `Transaction`, `Transaction.currentEntitlements`).
  - Listens for transaction updates (`Transaction.updates`) for the lifetime of the app.
  - On every entitlement change, writes a simple cached `Bool` (e.g. `TiloqSettings.isPlusSubscriberKey`) to the shared App Group `UserDefaults` — this is what both the app and the keyboard extension check synchronously, no network/StoreKit call needed from the extension.
  - StoreKit 2's on-device cryptographic verification (`VerificationResult`) is sufficient here; no server-side receipt validation is needed (and would violate the no-server privacy invariant anyway).
- Gating points (check the cached flag, not live StoreKit state):
  - `KeyboardAppearanceControls` — RGB toggle, "Choose Photo" backdrop option.
  - `TypeKeyboardView` — belt-and-suspenders check before actually rendering RGB/custom-photo behavior, in case the flag is stale or the feature was disabled after a subscription lapsed.
- A `PaywallView` (SwiftUI, `TiloqApp` only) shown when a free user taps a gated control: explains the offer, shows price + trial terms (required disclosure text — see Compliance below), Subscribe button, and a **Restore Purchases** button (Apple requires this for any paid unlock).
- Settings gets a small status row (matching the existing "ON DEVICE" status pattern): "TILOQ Plus — Trial (N days left)" / "Active" / "Free — Upgrade".

## Who gets Plus for free

Confirmed (2026-09-18): testers should never hit the paywall — only a real public App Store install should require payment. `TiloqSettings.hasPlusAccess` implements this:

- **Debug builds** (anyone building/running from Xcode) are unlocked by default, no setup needed. A `#if DEBUG`-only "Debug: Plus Unlocked" toggle in Settings defaults to on; turn it off to preview the locked, free experience while developing.
- **TestFlight builds** are unlocked automatically too, with no toggle to reach for — `SubscriptionManager` detects TestFlight at launch (a TestFlight install's App Store receipt file is always named `sandboxReceipt`, vs. `receipt` for a real purchase) and caches `true` into the same shared `isPlusSubscriberKey` the extension already reads. No code path distinguishes "tester" from "subscriber" past that point.
- **Public App Store installs** get none of the above — `hasPlusAccess` falls through to the real cached StoreKit entitlement, so payment is actually required once this ships.

## Testing strategy — no custom "skip paywall" backdoor needed

Apple already provides the right tools for every stage of testing; a hand-rolled bypass would be extra surface area for no benefit. All of this is already wired up in the repo, not just planned:

1. **Local/Simulator (fastest iteration):** `Tiloq.storekit` at the repo root defines the subscription product and its 14-day free-trial introductory offer for fully offline local testing. The shared `TiloqApp.xcscheme` already points its Run action at that file, so running from Xcode (Simulator or a physical device) activates it with no manual scheme setup. Xcode's Debug → StoreKit → Manage Transactions menu lets you simulate trial, renewal, expiration, and cancellation instantly instead of waiting real days. (Note: this local StoreKit environment only activates when Xcode itself launches the app through its debugger — installing a build via `devicectl`/`xcodebuild` from the command line does not trigger it.)
2. **Debug-only manual override:** see "Who gets Plus for free" above — defaults to unlocked, flip it off to eyeball the paywall UI itself.
3. **TestFlight / Sandbox (most realistic for real subscribers):** once a build reaches TestFlight, testers are auto-unlocked per above, but the underlying StoreKit Sandbox is still available for testing the *real* purchase/trial/renewal flow if needed (e.g. right before submitting, to confirm the paywall itself still works correctly for a hypothetical non-tester) — real flow, zero real charges. Apple also compresses sandbox trial/renewal durations dramatically (a 14-day trial renews every few minutes).
4. **Offer codes:** for giving specific reviewers free access without the trial mechanics, generate one-time or custom offer codes in App Store Connect — no extra app code needed.

## App Store Connect setup checklist (human-only — cannot be done from this repo)

- [ ] Create subscription group "TILOQ Plus".
- [ ] Create the auto-renewable subscription product (proposed ID: `com.tiloq.app.plus.annual`), $1.99/year.
- [ ] Configure the 14-day free trial as an introductory offer for new subscribers.
- [ ] Write the localized display name and description.
- [ ] Confirm Small Business Program enrollment (15% commission tier) is active for this developer account.

## UI/UX & compliance requirements

- Paywall screen must disclose, per App Store guidelines: subscription length, price, and that it auto-renews unless cancelled — plus links to Terms of Use and the existing Privacy Policy.
- Restore Purchases button is mandatory.
- No login/account of any kind — entitlement is tied to the Apple ID via StoreKit, consistent with the "no accounts" principle.
- `AppStore/metadata.md` and `review-notes.md` need updating once implemented, to describe the subscription for App Review (per `AGENTS.md`'s doc-sync rule) — do not invent the required legal/Terms-of-Use URL; that's a placeholder for the user to provide.
- Double-check whether `PrivacyInfo.xcprivacy` needs any additions for StoreKit usage (likely none beyond what's already there, but verify against the actual APIs used once implemented).

## Suggested rollout order

1. Decide the two open questions above (encryption gating scope, built-in backdrop styles).
2. Build `SubscriptionManager` + StoreKit Configuration file; wire up gating checks and the paywall screen; ship behind the debug override only — no real App Store Connect product needed yet.
3. Set up the real subscription product in App Store Connect once the UI is solid.
4. Test through TestFlight sandbox with real trial/renewal timing.
5. Update App Store metadata/review notes, then include in the next release build.

This work should land as its own milestone in `docs/PLAN.md` once decisions 1 and 2 are confirmed and implementation begins.
