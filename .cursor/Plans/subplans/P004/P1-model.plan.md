# P004 P1 — Model and Stubs

## Next hand off (cut & paste)

**P004 P1 — Model and stubs.** Plan: [P004-power-up.plan.md](.cursor/Plans/subplans/P004/P004-power-up.plan.md). Sub-plan: [P1-model.plan.md](.cursor/Plans/subplans/P004/P1-model.plan.md). Builder: Create `PowerUpType.swift`; add `powerUpHeld`, `doubleCashNextLockForPlayer` to GameState with `tryPurchasePowerUp`/`tryUsePowerUp` stubs; add `GridState.clearRow` and `lowestFullRow`. Unit test: purchase with sufficient cash succeeds and deducts. Investigator: validate P004 plan for 90%+ confidence before implementation. Expected: Model in place; purchase stub works; no UI yet.

---

## Outcome

Power-up model types and state in place; purchase stub works; GridState helpers exist. No UI.

## Steps

| Step | Task | Validation |
|------|------|------------|
| P1a | Create `PowerUpType.swift` with enum (clearRow, sendGarbage, doubleCash) and `var cost: Int` (3, 2, 2) | Compile; `PowerUpType.clearRow.cost == 3` |
| P1b | Add `powerUpHeld: [PowerUpType?]` (init `[nil, nil]`), `doubleCashNextLockForPlayer: [Bool]` (init `[false, false]`) to GameState | Compile; test init |
| P1c | Add `tryPurchasePowerUp(_ type: PowerUpType) -> Bool`: guard canAcceptInput, !powerUpHeld[pid], cash[pid] >= type.cost; else deduct, set powerUpHeld | Unit test: sufficient cash → true and deduct; insufficient → false |
| P1d | Add `tryUsePowerUp() -> Bool`: guard canAcceptInput; if powerUpHeld[pid] == nil return false; else clear powerUpHeld[pid] = nil, return true (stub: consume with no effect) | Unit test: no power-up → false; with power-up → true, consumed |
| P1e | Add `GridState.clearRow(_ row: Int)` – remove all cells in row | Unit test: row cleared |
| P1f | Add `GridState.lowestFullRow() -> Int?` – row 15 down to 0, first where all 8 cols occupied | Unit test: full row at 14 returns 14 |

## Detailed design

**PowerUpType** – Simple enum; `cost` as computed property. Costs: clearRow 3, sendGarbage 2, doubleCash 2.

**GameState** – `powerUpHeld` and `doubleCashNextLockForPlayer` are `private(set)`; init in `init(level:)` with other arrays. `tryPurchasePowerUp` must run only when `canAcceptInput` (not game over, not eliminated, not locked, not resolving per P002).

**GridState** – `clearRow` mutates `occupied`, removing all `GridPosition(col, row)` for that row. `lowestFullRow` iterates `row` from 15 down to 0, returns first row where `(0..<8).allSatisfy { occupied[GridPosition(col: $0, row: row)] != nil }`.

## Best route

1. Add PowerUpType.swift first (no deps).
2. Add GameState state and init.
3. Add tryPurchasePowerUp with full logic (not stub) – purchase is complete in P1.
4. Add tryUsePowerUp stub (guards only, clears powerUpHeld when called – optional for P1; can defer to P2).
5. Add GridState.clearRow and lowestFullRow.
6. Unit tests for purchase and GridState.

**Stub behavior:** When power-up held, consume it (clear powerUpHeld) and return true. No effect applied. Lets P1 tests cover the consume path; P2 adds real effects.

## Validation

- `tryPurchasePowerUp(.clearRow)` with cash 3 → true, cash[pid] 0, powerUpHeld[pid] == .clearRow
- `tryPurchasePowerUp(.clearRow)` with cash 2 → false
- `tryPurchasePowerUp(.sendGarbage)` when already holding → false
- `lowestFullRow()` on grid with full row 10 → 10
- `lowestFullRow()` on empty grid → nil

## Rollback

Remove PowerUpType.swift; revert GameState and GridState changes. No callers yet.

## Confidence

| | Value | Note |
|---|-------|------|
| **Confidence (root cause)** | 95% | New feature; no defect. Model is specified. |
| **Confidence (solution path)** | 92% | Steps and integration points clear. tryUsePowerUp stub scope is minor ambiguity. |

## Step 5 Fidelity

| Agent | Status |
|-------|--------|
| Investigator | Chunk validated; steps sufficient; rollback clear |
| ui-test | P1 has no UI; coverage deferred to P3 |
| logic-test | Purchase guards covered in P5 unit tests |
| infrastructure | Zero impact; no infra for model-only chunk |
