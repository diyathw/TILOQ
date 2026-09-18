---
description: Run TILOQ's test suite and assess/improve coverage for the current changes
---

Apply the `ios-test-engineer` agent's standard to the current uncommitted changes (or `$ARGUMENTS` if given).

1. Run `git diff` to see what changed.
2. If this is an in-progress bug fix or behavior change and no failing test was written first, stop and follow red → green → refactor: write the focused Swift Testing case, run it, confirm it fails for the right reason, then proceed.
3. Run the full suite:
   ```sh
   xcodebuild test \
     -project Tiloq.xcodeproj \
     -scheme TiloqApp \
     -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
   ```
4. If anything changed keyboard input, selection replacement, AI fallback, settings propagation, encryption, or height/layout calculations and there is no regression test for it, add one now (see `ios-test-engineer` for the exact list) — don't just report the gap, close it, unless the fix is still undecided.
5. Report: which test(s) were added/changed, confirmation the red state was observed, and the final pass/fail summary. Never report success by weakening an assertion or skipping a test.
