# TILOQ Repository Instructions

These instructions apply to the entire repository.

## Product intent

TILOQ is a focused iPhone custom keyboard and companion app. The core flow is:

> Select text → tap Rewrite, Grammar, Improve, or Encrypt → review → Insert.

Keep the product fast, tactile, private, and dramatically simpler than a chatbot or full writing suite. Preserve the premium dark industrial design, restrained accents, native iOS behavior, and accessible controls.

## Non-negotiable technical constraints

- Build a pure Apple app with Swift, SwiftUI, UIKit where required by the keyboard extension, Foundation Models, and CryptoKit.
- Keep this as an Xcode project. Do not add React Native, Expo, Vite, JavaScript runtimes, web app scaffolding, or cross-platform UI frameworks.
- Target iPhone and iOS 26 or later unless the user explicitly changes the deployment target.
- Use Apple's on-device Foundation Models framework for Rewrite, Grammar, and Improve. Do not add remote AI services or API keys.
- Do not add third-party dependencies without explicit approval and a concrete need.
- The keyboard must remain functional without Full Access. Keep `RequestsOpenAccess` set to `false`.
- Preserve the App Group relationship between `com.tiloq.app`, `com.tiloq.app.keyboard`, and `group.com.tiloq.app` unless all identifiers and entitlements are intentionally migrated together.

## Privacy and security invariants

- Never transmit writing, encryption keys, keyboard settings, backdrops, or clipboard contents to a server.
- Never add analytics, tracking, advertising, telemetry, or crash-reporting SDKs without explicit approval and updated privacy disclosures.
- If Apple Intelligence is unavailable or generation fails, preserve the user's source text. Never insert demo copy or fabricated text as a fallback.
- Clipboard reads and writes must happen only after an explicit user action.
- Encryption uses local CryptoKit AES-GCM and user-entered key text. Keep it simple; do not introduce accounts, recovery services, Keychain requirements, or enterprise key management unless requested.
- Reject malformed, non-canonical, wrong-key, and tampered encrypted messages safely.
- Keep privacy manifests accurate in both the app and keyboard extension. Update App Store privacy documentation whenever data handling changes.
- Never commit certificates, provisioning profiles, private keys, secrets, personal keyboard backdrops, DerivedData, archives, or exported `.ipa` files.

## Keyboard behavior invariants

- Preserve working space, return, shift, caps lock, numbers, symbols, globe switching, cursor mode, alternate characters, suggestions, key previews, and repeating delete.
- Character keys must be disabled while cursor mode is active.
- Keep a visible globe/next-keyboard control in the keyboard extension.
- Avoid keyboard-height regressions and cropping. Test both result-panel and normal states, including the number row.
- AI settings in the companion app must actually control the keyboard toolbar through shared App Group defaults.
- The default rewrite tone must propagate to the keyboard.
- Keep touch targets accessible and provide meaningful VoiceOver labels and hints.
- Respect Reduce Motion and the haptics setting.

## Swift and SwiftUI conventions

- Prefer modern Swift concurrency, value types, and SwiftUI APIs available on the deployment target.
- Keep UIKit limited to extension capabilities SwiftUI cannot provide cleanly, such as `UIInputViewController` and text-document proxy integration.
- Keep views small and extract reusable controls when a view becomes difficult to understand.
- Use semantic colors and Dynamic Type-friendly text. Avoid hard-coded layouts that only fit one iPhone size.
- Prefer value-based `NavigationStack` destinations for new navigation.
- Avoid force unwraps, `fatalError`, swallowed errors, and global mutable state.
- Treat strict-concurrency warnings as issues to resolve rather than suppress.
- When available, use the `swiftui-pro` skill for SwiftUI changes and `swift-testing-pro` for test work.

## Test-driven development

Use red → green → refactor for behavior changes and bug fixes:

1. Add or update a focused test that fails for the right reason.
2. Run it and confirm the failure.
3. Implement the smallest production fix.
4. Run the focused test, then the full suite.
5. Refactor only while tests remain green.

Use Swift Testing for unit and behavior tests. Add regression coverage for every fixed bug, especially keyboard input, selection replacement, AI fallbacks, settings propagation, encryption, and layout calculations.

Do not weaken an assertion simply to make a failing test pass. If a test is flaky, identify and remove the nondeterminism.

## Build and verification

Open `Tiloq.xcodeproj` and use the `TiloqApp` scheme.

Run the full test suite with an installed simulator:

```sh
xcodebuild test \
  -project Tiloq.xcodeproj \
  -scheme TiloqApp \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

For release-sensitive changes, also create a generic iOS Release archive and verify:

- both privacy manifests are embedded;
- the keyboard has `RequestsOpenAccess = false`;
- the app and extension carry the expected App Group entitlement;
- version, build number, bundle identifiers, icon, and display name are correct;
- the archive uses Apple Distribution signing before App Store upload.

Do not claim device verification unless the build was installed and the relevant flow was exercised on a physical iPhone.

## Xcode project maintenance

- When adding or moving source/resource files, update `Tiloq.xcodeproj/project.pbxproj` and the correct target membership.
- Shared keyboard files generally compile into both `TiloqApp` and `TypeKeyboard`; confirm membership deliberately.
- App-only settings, setup, and decryption views belong to `TiloqApp` only.
- Extension metadata and its privacy manifest belong to `TypeKeyboard` only.
- Validate edited plist, entitlement, and privacy-manifest files with `plutil -lint`.
- Keep Xcode user state and generated build products untracked.

## Documentation and App Store readiness

- Keep `README.md` accurate when requirements, setup, architecture, or major features change.
- Keep `AppStore/metadata.md`, `review-notes.md`, `privacy.md`, `privacy-policy.html`, and `release-checklist.md` synchronized with shipping behavior.
- Do not invent public URLs, support contacts, legal classifications, or App Store answers. Leave an explicit placeholder or report the blocker.
- Do not set export-compliance flags without confirming the correct classification for the encryption implementation.

## Change discipline

- Inspect existing code and tests before editing.
- Preserve unrelated user changes and avoid destructive Git operations.
- Prefer small, reviewable patches over broad rewrites.
- Explain any product-level assumption that changes behavior or scope.
- Before committing, run `git diff --check`, inspect the staged diff, and check for secrets or generated artifacts.
- Use clear imperative commit messages and never force-push unless explicitly requested.
