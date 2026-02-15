# P001-Dyld — TableTopGame.debug.dylib Launch Crash (Xcode 16)

## Next hand off (cut & paste)

**P001-Dyld — Commit to GitHub** (Builder, human). Plan: [P001-Dyld-dyld-crash.plan.md](.cursor/Plans/subplans/P001-Dyld/P001-Dyld-dyld-crash.plan.md). Fix applied 2026-02-15. Stage relevant files, commit with message including plan ID (e.g. `P001-Dyld: disable ENABLE_DEBUG_DYLIB`), push to `origin/main`. Update Master-Plan matrix row with push date.

---

## Overview

App crashes at launch with `Library not loaded: @rpath/TableTopGame.debug.dylib` when running UI tests (and likely direct launch). Root cause: Xcode 16 `ENABLE_DEBUG_DYLIB` builds app as stub + dylib; dylib not found. Fix: disable it for main app Debug config.

---

## Confidence (Investigator)

| Section | Confidence | Note |
|---------|------------|------|
| Root cause (ENABLE_DEBUG_DYLIB) | 95% | Apple DTS confirms; crash in dyld4::prepareSim before app code |
| Solution path (ENABLE_DEBUG_DYLIB = NO) | 95% | Documented workaround; no impact on @testable |
| Validation strategy | 95% | Clean build, direct launch, unit tests, UI tests |
| Rollback | 95% | Remove line; clean build; escalate if needed |

All sections meet ≥95% gate. Chunk Dyld-1 marked **Perfected**.

---

## Root Cause

**Crash:** `SIGABRT` in dyld: `Library not loaded: @rpath/TableTopGame.debug.dylib` (no such file).

**Cause:** Xcode 16 `ENABLE_DEBUG_DYLIB` splits the app into a stub executable + `<ProductName>.debug.dylib`. The dylib is not produced or not embedded; dyld fails at launch.

**Evidence:** Apple Developer Forums [thread 764503](https://developer.apple.com/forums/thread/764503); DTS Engineer: "Disabling ENABLE_DEBUG_DYLIB helps."

---

## Build Chunk (Planner)

| Chunk | Task | Validation |
|-------|------|------------|
| **Dyld-1 - Perfected** | Add `ENABLE_DEBUG_DYLIB = NO` to TableTopGame Debug config | Clean build; app launch; unit + UI tests pass |

---

## Solution (technical detail)

**File:** `TableTopGame.xcodeproj/project.pbxproj`

**Location:** Build configuration `A10000000000000000000013 /* Debug */` for TableTopGame target (around line 490).

**Change:** Add inside `buildSettings` dictionary, after `ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;`:

```
ENABLE_DEBUG_DYLIB = NO;
```

**Scope:** Main app target only. Unit and UI test targets unchanged.

---

## Validation Strategy

1. Clean build: `Cmd+Shift+K`, then `Cmd+B`
2. Direct launch: Run app on iOS Simulator (Debug scheme)
3. Unit tests: Run TableTopGameTests
4. UI tests: Run TableTopGameUITests (app launches as test host; no dyld crash)

---

## Rollback

Remove `ENABLE_DEBUG_DYLIB = NO` from project.pbxproj; clean build; rerun tests. Escalate if re-enabling is required (investigate dylib build/embed).

---

## Risks

- **Low:** Documented workaround; no known impact on @testable or ENABLE_TESTABILITY
- **Medium:** Future Xcode may fix upstream; override remains harmless

---

## UI-Test (validation)

- **Scope:** E2E/UI tests must run after fix (currently blocked by crash at app launch)
- **Validation:** TableTopGameUITests suite passes; app launches in test host without dyld error

---

## Logic-Test (minimal)

- **Scope:** N/A — build configuration change; no game logic, moves, or state-machine impact
- **Note:** Unit tests (TableTopGameTests) still run; no @testable impact

---

## Infrastructure (minimal)

- **Scope:** Fix unblocks CI UI tests; no hosting, persistence, or deployment changes
- **Note:** Zero cost; no infra changes required
