---
description: Check TILOQ's App Store / TestFlight readiness — versioning, privacy manifests, entitlements, and doc sync
---

Dispatch the `app-store-reviewer` agent to audit current App Store readiness. `$ARGUMENTS` may specify a focus (e.g. "versioning only", "privacy manifest only") — default to a full check.

Do these deterministic checks yourself first:

```sh
xcrun agvtool what-version
grep -n "MARKETING_VERSION\|CURRENT_PROJECT_VERSION\|PRODUCT_BUNDLE_IDENTIFIER" Tiloq.xcodeproj/project.pbxproj
grep -n "RequestsOpenAccess" KeyboardExtension/Info.plist
plutil -lint TiloqApp/TiloqApp.entitlements KeyboardExtension/TypeKeyboard.entitlements
plutil -lint TiloqApp/PrivacyInfo.xcprivacy KeyboardExtension/PrivacyInfo.xcprivacy
git status --short AppStore docs/PLAN.md
```

Then have `app-store-reviewer` cross-check `AppStore/metadata.md`, `review-notes.md`, `privacy.md`, `release-checklist.md`, and `docs/PLAN.md` against what's actually in the code and settings — not against what the docs merely claim.

Report as three lists: **Ready**, **Open gap** (exact file/setting to fix), **Needs your input** (URLs, legal/export-compliance answers, or anything requiring your Apple Developer account — never invent these). End with whether this build is upload-ready as-is.
