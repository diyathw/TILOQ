---
description: Run a full iOS engineering review (architecture, code quality, security, accessibility) of the current diff
---

Review the current uncommitted changes (or, if `$ARGUMENTS` names a branch/PR/commit range, that target instead) in this repo.

1. Run `git status` and `git diff` (staged + unstaged) yourself first to know the exact scope — do not review the whole repo.
2. Dispatch in parallel, each scoped to only the changed files/lines:
   - `ios-architect` — architecture, boundaries, concurrency isolation.
   - `ios-reviewer` — general Swift/SwiftUI correctness, API design, performance, simplification.
   - `ios-security-reviewer` — only if the diff touches encryption, storage, settings sync, entitlements, privacy manifests, or adds any networking.
   - `ios-accessibility-reviewer` — only if the diff touches SwiftUI/UIKit view code.
3. Collect their findings yourself. Do not just concatenate agent output — deduplicate, drop anything not actually grounded in the diff, and rank by real severity (correctness/privacy first, style last).
4. Report a single prioritized list: file:line, the concrete failure scenario, and the smallest fix. End with a one-line verdict: ready to merge, or blocked with N must-fix items.

Do not modify code as part of this command unless the user explicitly asks you to apply the fixes after seeing the findings.
