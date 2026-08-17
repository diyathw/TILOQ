# TILOQ Product and Release Plan

Last updated: August 17, 2026

## Product direction

TILOQ is a private, tactile iPhone keyboard for a small number of fast writing actions:

> Select text → Rewrite, Grammar, Improve, or Encrypt → review → Insert.

The product should remain simpler than a chatbot or full writing suite. New work must strengthen typing quality, reliability, privacy, or the focused editing flow.

## Product principles

1. **Local first** — writing transformations use Apple Intelligence on the device.
2. **Keyboard first** — normal typing must remain reliable even when AI is unavailable.
3. **Few clear actions** — avoid dashboards, chat interfaces, prompt controls, and feature clutter.
4. **Tactile and native** — use Apple platform conventions, responsive controls, haptics, and restrained visual effects.
5. **Private by default** — no accounts, writing server, analytics, advertising, or required Full Access.
6. **Safe replacement** — never replace user writing with demo copy, stale results, or unverified output.

## Current status

### Completed

- [x] Pure Swift and SwiftUI companion app
- [x] Native iOS custom keyboard extension
- [x] Rewrite, Grammar, and Improve toolbar actions
- [x] On-device Foundation Models integration
- [x] Local-model availability states and safe source-preserving fallback
- [x] Insert and Copy result workflow
- [x] Rewrite tone selector
- [x] Letters, number shortcut row, numbers, and symbols
- [x] Space, return, shift, caps lock, repeating delete, and globe switching
- [x] Cursor mode with character keys disabled while active
- [x] Suggestions, auto-capitalization, auto-correction behavior, period shortcut, alternate characters, and key previews
- [x] Haptics, tactile key animation, glass surfaces, RGB animation, and local backdrops
- [x] Optional AES-GCM text encryption with user-entered key text
- [x] Encryption preview with Insert and Copy
- [x] Separate decryption tab
- [x] Setup guide and in-app keyboard demo
- [x] Companion settings synchronized with the keyboard through the App Group
- [x] In-app privacy policy and privacy manifests for both targets
- [x] Swift Testing coverage for keyboard behavior, local AI, setup, and encryption
- [x] App Store metadata, review notes, privacy answers, policy template, and release checklist
- [x] Release archive built and release candidate installed on a physical iPhone
- [x] GitHub repository, README, and Codex repository instructions

### Current release candidate

- Version: `1.0`
- Build: `1`
- App bundle: `com.tiloq.app`
- Keyboard bundle: `com.tiloq.app.keyboard`
- App Group: `group.com.tiloq.app`
- Deployment target: iOS 26
- Distribution state: development-signed device build; Apple Distribution signing is still required for upload

## Milestone 1 — Device hardening

Goal: prove that TILOQ behaves like a dependable daily keyboard before TestFlight.

- [ ] Test on the smallest and largest supported iPhone displays
- [ ] Test portrait and supported system presentation sizes for cropping
- [ ] Exercise every key in Messages, Mail, Notes, and Safari
- [ ] Verify selected-text replacement in multiple third-party host apps
- [ ] Verify space-bar typing and cursor-mode gestures repeatedly
- [ ] Verify repeating delete across long words and sentences
- [ ] Test keyboard switching with the globe key
- [ ] Test all Apple Intelligence availability states on physical devices
- [ ] Test Rewrite tones against short, long, multiline, and Unicode text
- [ ] Test encryption round trips between two devices
- [ ] Test wrong keys, malformed messages, modified messages, and lost-key messaging
- [ ] Test VoiceOver, Dynamic Type, Reduce Motion, dark appearance, and increased contrast
- [ ] Confirm custom backdrops remain local and render without memory pressure

Exit criteria:

- No blocker or high-severity keyboard bugs remain.
- No reproducible cropping, missed space input, or delete-repeat failure remains.
- Full automated test suite passes.
- Core flows pass on a physical Apple Intelligence-compatible iPhone.

## Milestone 2 — App Store assets and account setup

Goal: make the project upload-ready without placeholders.

- [ ] Confirm individual Apple Developer Program enrollment for Diyath Wickramaratne and accept current agreements
- [ ] Register or verify both App IDs and the shared App Group
- [ ] Create an Apple Distribution certificate
- [ ] Create App Store provisioning profiles for the app and keyboard extension
- [ ] Create the TILOQ record in App Store Connect
- [ ] Host `AppStore/privacy-policy.html` at a public HTTPS URL
- [ ] Provide a working public Support URL
- [ ] Replace remaining placeholders in App Store documents
- [ ] Complete age-rating and content-rights questions
- [ ] Complete Apple's encryption export-compliance questionnaire accurately
- [ ] Reconfirm App Privacy answers against the final source and binary
- [ ] Capture final screenshots on an Apple Intelligence-ready device
- [ ] Verify the final 1024 × 1024 App Store icon

Exit criteria:

- Metadata contains no placeholders.
- Public Privacy Policy and Support URLs work without authentication.
- Distribution signing succeeds for both targets.
- App Store Connect accepts the archive validation.

## Milestone 3 — TestFlight

Goal: validate the distribution build outside the local development environment.

- [ ] Increment the build number
- [ ] Archive with Release configuration and Apple Distribution signing
- [ ] Validate and upload the archive
- [ ] Complete processing and export-compliance information in App Store Connect
- [ ] Add internal testers
- [ ] Run the complete device-hardening checklist against the TestFlight build
- [ ] Collect only deliberate human feedback; do not add analytics for the first release
- [ ] Fix blocker and high-severity issues using regression tests
- [ ] Upload a new build for every binary change

Exit criteria:

- TestFlight installation, app launch, keyboard setup, typing, local AI, and encryption pass.
- No blocker or high-severity issue remains open.
- Store screenshots and description match the tested binary.

## Milestone 4 — App Review and launch

Goal: submit an accurate, reviewable 1.0 release.

- [ ] Paste the prepared metadata and reviewer notes into App Store Connect
- [ ] Provide a responsive review contact
- [ ] Explain keyboard setup, no-Full-Access behavior, Apple Intelligence requirements, and encryption testing
- [ ] Select the approved TestFlight build for release
- [ ] Submit for review
- [ ] Respond to reviewer questions with exact reproduction steps
- [ ] Do not change product behavior while a build is in review without preparing a new build
- [ ] Choose manual or scheduled release after approval
- [ ] Verify the public product page immediately after launch

Exit criteria:

- TILOQ 1.0 is available on the App Store.
- Privacy, support, screenshots, and product description match shipping behavior.

## Milestone 5 — Post-launch quality

Prioritize reliability over feature count.

### Consider for 1.0.x

- Crash and user-reported bug fixes without adding tracking SDKs
- Keyboard layout and performance corrections
- Accessibility improvements
- Clearer setup or Apple Intelligence availability messaging
- App Store metadata refinements

### Consider for 1.1 only after 1.0 is stable

- Additional locally supported writing languages
- Carefully chosen new rewrite tones
- Better on-device suggestion quality
- More restrained RGB patterns and backdrop controls
- Optional import/export of non-sensitive appearance settings

Every proposed feature must answer:

1. Does it make the select → improve → insert flow faster or clearer?
2. Does it preserve on-device privacy?
3. Can it work without Full Access?
4. Can it be explained in one short sentence?
5. Can it be tested reliably?

If not, it does not belong in TILOQ yet.

## Explicit non-goals

- Chatbot or conversation history
- Cloud AI or remote writing processing
- Accounts, social profiles, or cross-device key recovery
- Analytics dashboards, usage statistics, advertising, or tracking
- Required Full Access
- Enterprise encryption or identity verification
- Android, React Native, Expo, Vite, or web-app versions
- Large collections of AI tools or advanced prompt settings

## Issue priority

- **Blocker** — data loss, wrong text insertion, keyboard unusable, privacy violation, encryption failure, launch failure, or App Store rejection
- **High** — broken core key, repeatable cropping, incorrect selection replacement, serious accessibility failure, or common AI action failure
- **Medium** — degraded secondary keyboard behavior, confusing settings, visual defects, or uncommon compatibility problems
- **Low** — polish, optional animation changes, copy refinements, and future ideas

Blocker and High issues must receive a regression test where technically possible.

## Definition of done

A change is complete only when:

- behavior matches the focused product intent;
- a failing test was added first for behavior changes or bug fixes;
- focused and full tests pass;
- app and keyboard target membership is correct;
- privacy and security invariants remain true;
- relevant physical-device behavior is checked for keyboard-sensitive changes;
- README, this plan, and App Store documents are updated when affected;
- no secrets, user data, Xcode user state, archives, or generated build products are committed.
