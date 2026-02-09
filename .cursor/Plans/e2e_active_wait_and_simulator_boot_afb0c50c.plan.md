# E2E Active Wait and Simulator Boot Plan

Per Master-Plan P001-E2E-WATCH. Active waits for menu and game HUD; script waits for Simulator boot before tests. Fixes watchable run so app and game are visible during E2E.

**Confidence:** Root cause 95%, Solution path 92%.

---

## Next hand off (cut & paste)

**Plan complete.** All chunks A1–C2 done. P001-E2E-WATCH marked complete in Master-Plan. No further hand offs for this plan.

## Second hand off (cut & paste) — Lane B

Prepare and push **P001-E2E-WATCH**: confirm all chunks (A1–C2) are done per this plan, then commit and push. Does not conflict with Lane A (no shared files; Lane A = C10 validation, Lane B = E2E-WATCH plan / git). Agent: optional (user or planner). Plan: this file. Expected outcome: E2E-WATCH changes pushed; Master-Plan can mark pushed if desired.

---

## Chunks

| Chunk | Outcome | Status |
|-------|---------|--------|
| **A1** | Menu wait: add menuReadyTimeout=60, remove sleep(3) before New Game tap, insert newGameButton.waitForExistence(timeout: 60) before tapping | **Done** |
| **A2** | Game HUD wait: add gameHudReadyTimeout constant, use for turn-label wait; replace post-tap sleep with active wait when slow | **Done** |
| **B1** | Script: Simulator boot wait before tests | **Done** |
| **B2** | Script: Integration with run-e2e-watchable.sh | **Done** |
| **C1** | Docs: E2E.md update | **Done** |
| **C2** | Master-Plan: P001-E2E-WATCH status | **Done** |

---

## A1 Implementation (completed)

- **File:** TableTopGameUITests/TableTopGameUITests.swift
- **Changes:**
  - Added `menuReadyTimeout: TimeInterval = 60` constant
  - Removed `sleep(3)` before New Game tap
  - Inserted `newGameButton.waitForExistence(timeout: menuReadyTimeout)` before tap
  - Menu appears before tap (active wait vs fixed sleep)

## A2 Implementation (completed)

- **File:** TableTopGameUITests/TableTopGameUITests.swift
- **Changes:**
  - Added `gameHudReadyTimeout: TimeInterval = 10` constant
  - Turn-label wait now uses `gameHudReadyTimeout` instead of hardcoded 5s
  - Removed post-tap `sleep(3)` block; turn-label wait is the active wait for HUD

## B1 Implementation (completed)

- **File:** scripts/wait-for-simulator.sh (new)
- **Changes:**
  - Accepts optional device name (default: "iPhone 16")
  - Resolves name to UDID via `xcrun simctl list devices available`
  - Uses `xcrun simctl bootstatus -b <udid>` to boot if needed and block until ready
  - Opens Simulator app and activates before waiting
  - Exits with "Simulator ready." when boot complete (Status=4294967295, isTerminal=YES)
- **Integration:** run-e2e-watchable.sh extracts device name from DEST and calls `./scripts/wait-for-simulator.sh "$DEVICE_NAME"` before xcodebuild test

## C1 Implementation (completed)

- **File:** docs/E2E.md
- **Changes:**
  - Added "Simulator boot wait" paragraph: mechanism (bootstatus -b), cold vs warm boot timing, integration with run script
  - Documents that E2E tests start only after Simulator is ready

## C2 Implementation (completed)

- **File:** .cursor/Plans/Master-Plan.md
- **Changes:** P001-E2E-WATCH row updated; Current state → Complete and ready for github push; hand offs cleared
