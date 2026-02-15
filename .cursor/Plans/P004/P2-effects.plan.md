# P004 P2 — Power-up Effects

## Next hand off (cut & paste)

**P004 P2 — Effects.** Plan: [P004-power-up.plan.md](.cursor/Plans/P004-power-up.plan.md). Sub-plan: [P2-effects.plan.md](.cursor/Plans/P004/P2-effects.plan.md). Builder: Implement Clear Row, Send Garbage, Double Cash in `tryUsePowerUp` and `lockCapsule`/resolution. Unit tests per effect. Logic-Test checkpoint after P2.

---

## Outcome

All three power-up effects work. Clear Row clears lowest full row; Send Garbage adds 2 rows to opponent; Double Cash doubles virus cash on next lock.

## Steps

| Step | Task | Validation |
|------|------|------------|
| P2a | Clear Row: in tryUsePowerUp, if type == .clearRow, get lowestFullRow() for current grid; if non-nil: (1) grid.clearRow(row), (2) `while GravityEngine.apply(to: &grid) { }`, (3) resolveLoop; else consume with no-op | Unit test: full row cleared, no floating pieces |
| P2b | Send Garbage: if type == .sendGarbage, append 2 rows to pendingGarbage[opponent] via AttackCalculator.garbagePositions(count:2) | Unit test: opponent receives 2 rows |
| P2c | Double Cash: if type == .doubleCash, set doubleCashNextLockForPlayer[currentPlayerIndex] = true | Flag set |
| P2d | In beginResolution: set resolutionDoubleCash from doubleCashNextLockForPlayer[pid], clear doubleCashNextLockForPlayer[pid]. In advanceResolutionStep virus-cash block: if resolutionDoubleCash, add bonus. In finishResolution: clear resolutionDoubleCash | Unit test: 2 viruses cleared with flag → +4 cash |
| P2e | tryUsePowerUp: apply effect, set powerUpHeld[pid] = nil | Unit test: power-up consumed |

## Detailed design

**Clear Row** – `resolveLoop` only runs gravity when matches exist; after clearRow we have a hole with no matches, so it would exit without gravity and leave floating pieces. **Required:** (1) `grid.clearRow(row)`, (2) `while GravityEngine.apply(to: &grid) { }` to drop pieces until stable, (3) `resolveLoop(grid: &grid, virusPositions: &virusPositions, pid: pid)` to clear any resulting matches. If no full row, consume power-up but no grid change.

**Send Garbage** – `AttackCalculator.garbagePositions(count: 2, colors: [.red, .blue])` produces 2 rows. Each row is `[(col, color)]`. Append both to `pendingGarbage[opponent]`. Opponent must not be eliminated.

**Double Cash** – P002 uses `advanceResolutionStep`; cash is added per virus there. Add `resolutionDoubleCash: Bool` set from `doubleCashNextLockForPlayer[pid]` at `beginResolution`, cleared at `finishResolution`. When adding `cash[pid] += 1` for virus, if `resolutionDoubleCash` then `cash[pid] += 1` again. Clear `doubleCashNextLockForPlayer[pid]` at beginResolution.

**Integration:** GameState has `beginResolution`, `advanceResolutionStep`, `finishResolution`. Add `resolutionDoubleCash = doubleCashNextLockForPlayer[pid]` in beginResolution; clear `doubleCashNextLockForPlayer[pid]`. In the virus-cash block, add bonus when resolutionDoubleCash.

## Best route

1. Implement Clear Row first (clearRow, gravity loop, then resolveLoop).
2. Implement Send Garbage (reuses AttackCalculator).
3. Implement Double Cash (touch resolution path).
4. Wire tryUsePowerUp to dispatch by type and consume.

## Validation

- Logic-Test: purchase, use Clear Row on fixture with full row → row cleared, cash from viruses in cleared row.
- Send Garbage → opponent pendingGarbage.count += 2.
- Double Cash used, then lock with 2 virus clears → cash +4.
- Logic-Test invariant checklist: [P004-step2-test-and-infra.md](P004-step2-test-and-infra.md).

## Rollback

Revert tryUsePowerUp and resolution changes. P1 model remains.

## Confidence

| | Value | Note |
|---|-------|------|
| **Confidence (root cause)** | 92% | Effects are well-specified; P002 resolution flow verified in codebase |
| **Confidence (solution path)** | 92% | Gravity fix applied; Double Cash resolutionDoubleCash pattern clear |

## Step 5 Fidelity

| Agent | Status |
|-------|--------|
| Investigator | Chunk validated; Double Cash integration path documented |
| ui-test | Effects not UI-visible until P3; manual validation after P2 |
| logic-test | Invariants and edge cases in P004-step2-test-and-infra; Logic-Test checkpoint after P2 |
| infrastructure | Zero impact |
