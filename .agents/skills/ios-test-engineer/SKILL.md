---
name: ios-test-engineer
description: Enforces TILOQ's red/green/refactor workflow, writes Swift Testing cases, and identifies untested behavior, boundary cases, and regressions. Use whenever a behavior change or bug fix is being made, or when asked to add/check tests.
---

`AGENTS.md` mandates strict red → green → refactor for every behavior change and bug fix:

1. Add or update a focused Swift Testing case that fails for the right reason.
2. Run it and confirm the failure.
3. Implement the smallest production fix.
4. Run the focused test, then the full suite.
5. Refactor only while tests stay green.

Never skip step 2 (confirming the red state) — a test that was never observed failing does not prove it tests anything.

## How to run this

1. Run `git diff` to see what changed.
2. If this is an in-progress bug fix or behavior change and no failing test was written first, stop and follow red → green → refactor above before doing anything else.
3. Run the full suite:
   ```sh
   xcodebuild test \
     -project Tiloq.xcodeproj \
     -scheme TiloqApp \
     -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
   ```
4. If the diff changed keyboard input, selection replacement, AI fallback, settings propagation, encryption, or height/layout calculations and there is no regression test for it, add one now (see coverage priorities below) — don't just report the gap, close it, unless the fix is still undecided.
5. Report which test(s) were added/changed, confirm the red state was observed before the fix, and confirm the full suite is green after. Never report success by weakening an assertion or skipping a test.

## Framework and conventions

- Use **Swift Testing** (`@Test`, `#expect`, `arguments:` for parameterized cases) for new tests — this is what `TiloqTests/` already uses throughout (`KeyboardBehaviorTests.swift`, `TiloqTextEncryptionTests.swift`, `LocalAIRequestTests.swift`, `SetupGuideContentTests.swift`, `TypeCopyTests.swift`, `TiloqSettingsTests.swift`).
- Test **observable behavior**, not implementation details. Prefer calling the same static functions the app calls (`KeyboardBehavior.applying`, `KeyboardBehavior.preferredHeight`, `TiloqSettings.hasPlusAccess`, `TiloqTextEncryption` round trips) over reaching into private state.
- Tests must be deterministic — no arbitrary `sleep`, no reliance on real wall-clock time or live network/model calls. `LocalAIRequestTests` already shows the pattern for testing prompt construction and fallback behavior without a live model. When a function's behavior depends on something environment-driven (e.g. Debug vs. Release), give it an injectable parameter (see `hasPlusAccess(isDebugBuild:)`) rather than relying on the test target's own compile-time configuration.

## Coverage priorities (match `AGENTS.md`'s explicit list)

Keyboard input and every character-key path, selection replacement, cursor mode, repeating delete, AI fallback behavior (never fabricate text when the model is unavailable), settings propagation through the shared `TiloqSettings`/App Group defaults, encryption round trips including wrong-key/malformed/tampered messages, layout/height calculations (`KeyboardBehavior.preferredHeight` and friends), and subscription/entitlement gating (`TiloqSettings.hasPlusAccess`) — these have caused real regressions before (see git history around `resultPanelHeight`) and any change touching them needs a pinned test, not just a manual check.

## Rules you must not break

- Never weaken an assertion to make a failing test pass, and never delete a valid failing test to get to green — fix the production code or, if the test's expectation was actually wrong, say so explicitly and justify why before changing it.
- Never hard-code behavior specifically for a test's input.
- If a test is flaky, find and remove the nondeterminism; do not retry-loop around it.
- Blocker and High severity issues (per `docs/PLAN.md`'s priority scale: data loss, wrong text insertion, keyboard unusable, privacy violation, encryption failure) must get a regression test wherever technically possible — this is not optional polish.
