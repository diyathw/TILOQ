---
name: appstore-readiness
description: Checks TILOQ's App Store / TestFlight readiness — versioning, privacy manifests, entitlements, and AppStore/ documentation staying in sync with shipping behavior. Use before an archive/upload, when app-facing behavior or data handling changes, or when asked to check App Store readiness.
---

Cross-check the binary/config against `docs/PLAN.md`'s milestones and `AGENTS.md`'s "Documentation and App Store readiness" section, and against the actual project settings — never take a document's claim at face value if you can verify it against `Tiloq.xcodeproj/project.pbxproj` or the plist/entitlement files directly.

## How to run this check

Do these deterministic checks first:

```sh
xcrun agvtool what-version
grep -n "MARKETING_VERSION\|CURRENT_PROJECT_VERSION\|PRODUCT_BUNDLE_IDENTIFIER" Tiloq.xcodeproj/project.pbxproj
grep -n "RequestsOpenAccess" KeyboardExtension/Info.plist
plutil -lint TiloqApp/TiloqApp.entitlements KeyboardExtension/TypeKeyboard.entitlements
plutil -lint TiloqApp/PrivacyInfo.xcprivacy KeyboardExtension/PrivacyInfo.xcprivacy
git status --short AppStore docs/PLAN.md
```

Then cross-check `AppStore/metadata.md`, `review-notes.md`, `privacy.md`, `release-checklist.md`, and `docs/PLAN.md` against what's actually in the code and settings — not against what the docs merely claim. Report as three lists: **Ready**, **Open gap** (exact file/setting to fix), **Needs your input** (URLs, legal/export-compliance answers, or anything requiring the Apple Developer account — never invent these). End with whether this build is upload-ready as-is.

## Checks

**Versioning**
- `CURRENT_PROJECT_VERSION` must be identical across `TiloqApp` and `TiloqKeyboard`, Debug and Release, and must have been incremented for any change since the last upload (`xcrun agvtool what-version`). `MARKETING_VERSION` only changes when the user explicitly says so — do not bump it on your own inference.
- Every new binary uploaded to App Store Connect needs a strictly higher build number than the last, regardless of how minor the change is.

**Privacy manifest and entitlements**
- `TiloqApp/PrivacyInfo.xcprivacy` and `KeyboardExtension/PrivacyInfo.xcprivacy` must accurately reflect actual data collection/required-reason API usage — re-check them whenever data handling changes, not just at submission time.
- `KeyboardExtension`'s `Info.plist` must keep `RequestsOpenAccess = false` unless explicitly changed.
- Both targets must carry the `group.com.tiloq.app` App Group entitlement; validate every edited `.entitlements`/`.plist` with `plutil -lint`.

**Bundle identity**
- `com.tiloq.app` (app) and `com.tiloq.app.keyboard` (extension) bundle IDs, and the shared App Group, must stay consistent across both targets' build settings unless a deliberate, fully-coordinated migration is in progress.
- Icon, display name (`TILOQ`), and version/build numbers must be correct in both the app and archive.

**Subscription readiness** (added once TILOQ Plus shipped — see `docs/MONETIZATION.md`)
- Confirm whether the real `com.tiloq.app.plus.annual` subscription product has actually been created in App Store Connect yet; if not, that's an explicit open gap, not a "ready."
- The paywall's disclosure text (length, price, auto-renewal terms, link to Terms of Use/Privacy Policy) must stay accurate to whatever is actually configured in App Store Connect.
- Confirm `SubscriptionManager`'s TestFlight auto-unlock (`sandboxReceipt` detection) hasn't been broken by a refactor — a public App Store build must NOT auto-unlock.

**Documentation sync** (per `AGENTS.md` — do not invent content)
- `AppStore/metadata.md`, `review-notes.md`, `privacy.md`, `privacy-policy.html`, and `release-checklist.md` should reflect current shipping behavior. If a change affects any of them and they weren't updated, flag it — but never invent a public URL, support contact, legal classification, or App Store answer yourself; report the gap as an explicit placeholder/blocker instead.
- `docs/PLAN.md` milestones/checklist items should be checked off (or flagged as still open) consistently with what's actually been verified — don't mark something done that was only code-complete but not device-verified.
- Do not set export-compliance flags without explicit confirmation of the correct classification for the encryption implementation.

**Release process discipline**
- Archive must use Apple Distribution signing before App Store upload — Debug/"Sign to Run Locally" builds are for local iteration only.
- Never claim physical-device verification unless a build was actually installed and the relevant flow exercised on a real iPhone — Simulator verification (including stress-testing with `xcrun simctl ui <device> content_size ...`) is valuable but is not a substitute for that claim.
