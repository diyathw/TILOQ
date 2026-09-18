---
name: ios-code-review
description: Full Swift/SwiftUI code review for a TILOQ diff — correctness, API design, performance, simplification, and cross-checks against the ios-security-review and ios-accessibility-review skills when relevant. Use on any non-trivial Swift change before considering it done, or when asked to review code.
---

Read `AGENTS.md` first for product-specific invariants (privacy, keyboard behavior, TDD). This skill covers general Swift/SwiftUI code quality; load `ios-security-review` too if the diff touches encryption, storage, settings sync, entitlements, privacy manifests, or networking, `ios-accessibility-review` if it touches SwiftUI/UIKit view code, and `ios-architect` for structural/concurrency-boundary questions.

## How to run this review

1. Run `git status` and `git diff` (staged + unstaged) yourself first to know the exact scope — review only the changed files/lines, not the whole repo, unless told otherwise.
2. Apply the checklist below to that diff.
3. Rank findings by actual severity (a real bug outranks a style nit) and report a single prioritized list: file:line, the concrete failure scenario, and the smallest fix. End with a one-line verdict: ready to merge, or blocked with N must-fix items.
4. Do not modify code as part of this review unless explicitly asked to apply the fixes after reporting findings.

## Priorities

Correctness first, then maintainability, testability, performance, simplicity. Optimize for the smallest clean diff that meets the actual requirement — do not add speculative flexibility, comments that restate the code, or defensive checks for states that cannot occur.

## What to flag

**Correctness**
- Force unwraps (`!`), `try!`, `as!`, implicitly-unwrapped optionals — each must have an obvious, local invariant proving safety, or it's a defect. `fatalError` used as ordinary error handling is a defect.
- Exhaustiveness: `switch` over an app-defined `enum` should not silently drop a case via `default` unless that's genuinely intended and obvious.
- Off-by-one / boundary handling in string, index, and range logic (this codebase does a lot of text-cursor and selection math — check it precisely).

**Swift API design**
- Names read clearly at the call site (Swift API Design Guidelines) — flag ambiguous booleans, abbreviations, or parameter labels that don't read as English at the call site.
- Prefer `let` over `var`, value types over reference types, explicit access control (this codebase uses `private`/`fileprivate` consistently — keep it that way).
- Typed/thrown errors when a caller genuinely needs to distinguish failure cases; don't introduce `throws` where a caller only ever ignores or force-handles the error.

**Performance**
- SwiftUI view bodies doing real work on every recomputation (parsing, formatting, filtering) instead of caching or moving it to a static/pure helper.
- Retain cycles in closures capturing `self` inside `Task`/completion handlers without `[weak self]` where the lifetime isn't obviously bounded.
- Unbounded caches, repeated `UserDefaults`/`AppStorage` reads that could be hoisted.

**Simplicity / reuse**
- Duplicated logic that already exists in `Shared/` (`KeyboardBehavior`, `KeyboardSuggestionEngine`, etc.) — point at the existing helper instead of a second implementation.
- Abstractions introduced for a single call site with no test or substitution benefit.
- Comments that explain *what* instead of a non-obvious *why*.

**Warnings**
- Never treat suppressing a compiler or Swift 6 concurrency warning as an acceptable fix. Flag `@unchecked Sendable`, `nonisolated(unsafe)`, or blanket `@preconcurrency` unless the comment next to it justifies exactly why it's safe.
