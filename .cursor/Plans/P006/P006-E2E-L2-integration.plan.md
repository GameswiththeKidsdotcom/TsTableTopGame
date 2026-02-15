---
name: P006-E2E-L2 runFullPlaythrough Integration
overview: Integrate SmarterTapStrategy into runFullPlaythrough with P0-only tap guard.
---

**Next hand off (cut & paste)**: **P006-E2E L2 — runFullPlaythrough integration.** Builder: In [TableTopGameUITests.swift](TableTopGameUITests/TableTopGameUITests.swift) `runFullPlaythrough`, add `guard player1Turn else { usleep(stepDelayUs); continue }`; add `var strategy = SmarterTapStrategy()` before loop; when player1Turn, use `strategy.nextZone()` and `BoardTapHelper.tapPoint(in: left, zone: zone)`. Run `testFullPlaythroughUntilGameOver`; must pass.

---

## Outcome

runFullPlaythrough uses smarter taps (left/right/drop) on P0's turn only; no tap on AI turn.

## Steps

1. Add `var strategy = SmarterTapStrategy()` before the while loop in runFullPlaythrough.
2. After `let player1Turn = app.staticTexts["Player 1's turn"].exists`, add `guard player1Turn else { usleep(stepDelayUs); continue }`.
3. Replace `let gridFrame = player1Turn ? left : right` and `zone: .rotate` with: `let gridFrame = left`, `let zone = strategy.nextZone()`, `BoardTapHelper.tapPoint(in: gridFrame, zone: zone)`.
4. Run testFullPlaythroughUntilGameOver; must reach game over within timeout.

## Validation

- testFullPlaythroughUntilGameOver passes.
- testFullPlaythroughUntilGameOverWithRestart passes.
- No regression: existing E2E tests still pass.

## Rollback

Revert to `zone: .rotate`; remove strategy and guard.

## Confidence

| | Value | Note |
|---|-------|------|
| Root cause | 95% | P0-only tap improves win rate vs AI; avoids wasting taps on AI turn |
| Solution path | 92% | Guard + strategy integration clear; depends on L1 |

## Per-chunk fidelity (Blaster)

| Agent | Finding |
|-------|---------|
| **Investigator** | P0-only guard and strategy integration are correct. Confidence 95/92. Steps 1–4 sufficient; rollback reverts to zone: .rotate. |
| **ui-test** | Full playthrough E2E journey unchanged; taps now varied on P0 turn. testFullPlaythroughUntilGameOver and testGameOverRealGameRestart coverage preserved. |
| **logic-test** | P0-only guard (`guard player1Turn else { usleep; continue }`) prevents tap on AI turn. Taps map to tryMoveLeft/Right, hardDrop, tryRotate; all valid. No state-machine regression. |
| **infrastructure** | runFullPlaythrough timeout (180s) and stepDelayMs unchanged. Simulator resource usage same as existing playthrough tests. |
