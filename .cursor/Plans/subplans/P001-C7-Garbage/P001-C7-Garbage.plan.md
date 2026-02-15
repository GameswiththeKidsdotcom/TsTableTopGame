# P001-C7-Garbage — Garbage count=1 Empty Row Fix

## Next hand off (cut & paste) — Lane A

**Chunk A1 — Fix** (Builder). Implement the fix and LT-C7-1 test. Plan: [P001-C7-Garbage.plan.md](.cursor/Plans/subplans/P001-C7-Garbage/P001-C7-Garbage.plan.md). Add `case 1: cols = [0, 4]` to `AttackCalculator.garbagePositions`; add unit test `testAttackCalculatorGarbagePositionsCount1`. Run full test suite. Logic-Test agent validates LT-C7-1.

---

## Overview

When a player clears exactly 1 match, `AttackCalculator.garbagePositions(count: 1)` returns `[]` (no `case 1`). Opponent receives invisible garbage—empty row insert—shifting content and losing row 15. Fix: add `case 1: cols = [0, 4]` to use minimum 2-cell pattern.

---

## Confidence (Investigator)

| Section | Confidence | Note |
|---------|------------|------|
| Root cause (garbagePositions count=1 → []) | 95% | Code path traced; `default: return []` for count 1 confirmed |
| Solution path (add case 1 → [0,4]) | 95% | Aligns with C7 design; minimal change |
| No other code paths affected | 92% | LT-C7-1 contract test validates count 1..4; LT-C7-2 integration validates end-to-end |
| LT-C7-2 assertion strategy | 93% | Assert via `gridState(forPlayer: 1)` after P1 lock; no access to private `pendingGarbage` needed |

All sections meet >90% gate.

---

## Findings / Evidence

### Root Cause

`AttackCalculator.garbagePositions` has cases 2, 3, 4 only. For `count == 1`, falls through to `default: return []`. Flow: P0 clears 1 match → `garbageCount = 1` → `garbagePositions(1)` → `[]` → `pendingGarbage[1].append([])` → on P1 lock, `insertGarbageRow([])` shifts grid, adds nothing, loses row 15.

### Solution

Add `case 1: cols = [0, 4]` (same as case 2; minimum garbage per C7).

---

## Build Chunks (Planner)

| Chunk | Task | Validation |
|-------|------|-------------|
| **A1** | Fix: Add `case 1: cols = [0, 4]` to `AttackCalculator.garbagePositions` | Unit test passes |
| **A2** | LT-C7-1: Contract test—for count 1..4, `garbagePositions(count, colors)` non-empty, correct cols | `testAttackCalculatorGarbagePositionsCount1` + extend for 1,3 |
| **A3** | LT-C7-2: Integration test—1-clear → P1 receives visible garbage | `testOneClearSendsVisibleGarbageToOpponent` |
| **A4** | Fidelity updates: logic-test.plan.md C7 row; C7-attack.plan.md Validation; manual checklist | Documents updated |

**Dependencies**: A2 and A3 can run in parallel after A1. A4 after A2–A3.

---

## LT-C7-2 Assertion Strategy (Logic-Test)

`pendingGarbage` is private. Assert via **public API**: `gridState(forPlayer: 1)` after P1 locks.

**Fixture**:

1. P0 grid: 2 red at (2,5), (3,5). P1 grid: empty.
2. Capsule queue: [(.red, .red)].
3. Run: P0 tryMoveLeft (×3) → col 0; hardDrop → locks at row 5.
4. Resolution: 1 match clears; garbage enqueued to P1.
5. advanceTurn → P1 spawns.
6. P1 hardDrop → locks (empty grid).
7. On P1 lock, `insertGarbageRow` runs; P1 grid gets cells at (0,0), (4,0).
8. **Assert**: `gridState(forPlayer: 1).color(at: 0, row: 0) != nil` and `color(at: 4, row: 0) != nil`.

**Technical detail**: Use `GameState(gridStatesForTest: [grid0, grid1], capsuleQueueForTest: [(.red, .red)])`, `runResolutionSynchronously = true`. Build grid0 with `grid0.set(.red, at: 2, row: 5); grid0.set(.red, at: 3, row: 5)`. Execute moves programmatically; after P1 lock, assert via `gridState(forPlayer: 1)`.

---

## UI-Test / E2E Additions

| ID | Scope | Approach |
|----|-------|----------|
| UI-C7-2 | Manual checklist | Add to C10 or validation doc: "P0 clears 1 match; P1 sees 2 garbage blocks (cols 0,4); no invisible row-shift." |
| UI-C7-1 | Fixture journey (P2) | Requires test-only launch arg (e.g. `-GameOverFixture garbage1`); defer until infra supports |

**Handoff**: Manual checklist (UI-C7-2) is P1. Fixture journey is P2 post-fix.

---

## Infrastructure (Infrastructure agent)

**Scope**: Minimal—regression fix + new unit/integration tests.

**Findings**:

- **CI**: No changes. Existing `xcodebuild test` runs TableTopGameTests; new tests (LT-C7-1, LT-C7-2) run in same suite.
- **Test hooks**: Not required for this fix. LT-C7-2 uses public GameState API and fixture init.
- **Harness**: No E2E or UI harness changes for Chunks A1–A3. UI-C7-1 (fixture journey) would need launch arg; defer.

**Recommendation**: Zero infra changes for A1–A3. Document UI-C7-2 in manual validation checklist.

---

## Risks and Rollback

| Risk | Mitigation |
|------|------------|
| Existing tests fail | `testAttackCalculatorVirusCountAndGarbage` asserts `garbageCount` only; remains green |
| LT-C7-2 fixture fragile | Use deterministic gridStatesForTest + capsuleQueueForTest |
| Game balance change | Per C7, 1 clear → min 2 cells; intended behavior |

**Rollback**: Revert `case 1` in AttackCalculator; revert LT-C7-1, LT-C7-2 tests.

---

## Master-Plan Updates

Add matrix row:

| Plan ID | Plan name | Priority | Description | Current state |
|---------|-----------|----------|-------------|---------------|
| P001-C7-Garbage | Garbage count=1 empty row fix | 1 (regression) | garbagePositions(1)→[]; fix case 1→[0,4]; LT-C7-1 contract, LT-C7-2 integration; Blaster fidelity update | Validated |

---

## Checkpoint Delegation

- **Logic-Test**: Implement LT-C7-1 (contract) and LT-C7-2 (integration); validate assertion strategy.
- **UI-Test**: Add UI-C7-2 to manual validation checklist.
- **Tester**: Run full test suite after A1–A3; confirm no regressions.
