---
name: ios-security-review
description: Privacy and security audit of TILOQ against OWASP MASVS — encryption, storage, entitlements, logging, and third-party data flow. Use before merging any change touching encryption, storage, settings sync, privacy manifests, entitlements, or networking, and periodically as a standing audit.
---

Use **OWASP MASVS** as the baseline. TILOQ's entire product promise is local-first privacy (`AGENTS.md`, "Privacy and security invariants") — treat any regression here as a blocker, not a nit.

## How to run this audit

Do these deterministic checks first so you're not relying on reading the diff alone:

```sh
grep -rn "URLSession\|URLRequest\|Alamofire" TiloqApp Shared KeyboardExtension
grep -rn "UserDefaults.standard" TiloqApp Shared KeyboardExtension
plutil -lint TiloqApp/TiloqApp.entitlements KeyboardExtension/TypeKeyboard.entitlements
plutil -lint TiloqApp/PrivacyInfo.xcprivacy KeyboardExtension/PrivacyInfo.xcprivacy
grep -n "RequestsOpenAccess" KeyboardExtension/Info.plist
```

Any networking call found outside test code is an automatic blocker — surface it immediately rather than waiting for the full report. Then apply the full checklist below to the actual diff. Report findings ranked by severity using `docs/PLAN.md`'s scale (Blocker = privacy violation or encryption failure; High = broken core guarantee; Medium/Low below that). If nothing regresses, say so plainly — don't manufacture findings.

## Non-negotiables (from `AGENTS.md` — verify, don't just trust the diff)

- No writing, encryption keys, keyboard settings, backdrops, or clipboard contents ever transmitted to a server. There should be zero production network calls anywhere in `TiloqApp`, `Shared`, or `KeyboardExtension`.
- No analytics, tracking, advertising, or crash-reporting SDK without explicit approval and an updated privacy manifest.
- Apple Intelligence unavailable/failed generation must preserve the user's source text — never fabricate or fall back to demo copy. Check `LocalAIRequest.fallback`/`.resolved` and callers stay behavior-preserving.
- Clipboard reads/writes only after an explicit user action (a tap), never on a timer, background task, or app-foreground hook.
- Encryption: local CryptoKit AES-GCM only, user-entered key text, no accounts/recovery services/Keychain requirement/enterprise key management unless explicitly requested. Malformed, non-canonical, wrong-key, and tampered messages must fail closed (`TiloqTextEncryptionTests` pins this — check new code doesn't weaken it).
- `RequestsOpenAccess` must stay `false` in the keyboard extension's `Info.plist`; the keyboard must remain functional without Full Access.
- The App Group relationship (`com.tiloq.app`, `com.tiloq.app.keyboard`, `group.com.tiloq.app`) must not be silently changed — any identifier/entitlement migration must be intentional and complete across both targets.
- Subscription/entitlement code (`SubscriptionManager`, `TiloqSettings.hasPlusAccess`) must never require an account or send purchase/usage data anywhere beyond Apple's own StoreKit — the whole point of TestFlight/Debug auto-unlock is to keep testers out of the paywall, not to open a new data-collection surface.

## OWASP MASVS checklist to apply

- **Storage**: no sensitive data (encryption key text, decrypted message content) in logs, `UserDefaults` outside the App Group's intended settings keys, plaintext files, or crash metadata. `TiloqEncryptionKeyStore` and `TiloqSettings` are the only sanctioned storage paths — flag anything bypassing them.
- **Cryptography**: CryptoKit only, never a hand-rolled algorithm. Check key derivation, nonce/IV handling, and authentication-tag verification haven't been weakened (`TiloqTextEncryption.swift`).
- **Network**: TILOQ should have *zero* production network calls. Any new one is a scope violation requiring explicit user sign-off, not a code-review nit.
- **Platform interaction**: entitlements and privacy manifest (`PrivacyInfo.xcprivacy` in both `TiloqApp` and `KeyboardExtension`) must stay accurate to what the code actually does — check required-reason API usage matches a real, approved use, never invented to pass App Store checks.
- **Authentication/authorization**: TILOQ has no server-side auth, but locally: does entering the wrong decryption key ever leak partial plaintext, timing information, or a different error path than "wrong key"? Check `TiloqTextEncryptionTests/wrongKeyFails`-style guarantees hold for new code paths.
- **Least privilege**: before any new entitlement or Info.plist permission key, confirm the feature genuinely requires it — don't accept a permission add "just in case."
