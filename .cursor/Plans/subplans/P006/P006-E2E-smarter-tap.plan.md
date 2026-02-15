---
name: P006-E2E Smarter Tap Strategy
overview: Option A: smarter tap strategy for E2E full playthrough. Column-sweep (left/right/drop); P0-only tap. Goal: improve win rate vs GreedyAI at level 5.
---

# P006-E2E – Smarter Tap Strategy

**Next hand off (cut & paste)**: **P006-E2E L1 — SmarterTapStrategy struct.** [P006-E2E-L1-strategy.plan.md](P006-E2E-L1-strategy.plan.md). Builder: Add `SmarterTapStrategy` to TableTopGameUITests; add `testSmarterTapStrategySequence()` asserting zone variety (moveLeft, moveRight, hardDrop). Validation: test passes.

---

## Chunks

| Chunk | Outcome | Sub-plan |
|-------|---------|----------|
| **E2E-L1** | SmarterTapStrategy struct + testSmarterTapStrategySequence | [P006-E2E-L1-strategy.plan.md](P006-E2E-L1-strategy.plan.md) |
| **E2E-L2** | runFullPlaythrough: guard player1Turn, use strategy (P0-only tap) | [P006-E2E-L2-integration.plan.md](P006-E2E-L2-integration.plan.md) |
| **E2E-L3** | testFullPlaythroughLevel5 (Settings → level 5 → playthrough, 240s) | [P006-E2E-L3-level5.plan.md](P006-E2E-L3-level5.plan.md) |

**Planner confirmation:** Chunks L1, L2, L3 are digestible for AI execution. Order: L1 (struct, no deps) → L2 (integrates L1 into runFullPlaythrough) → L3 (adds level-selection journey; depends on L2). Head-to-head scope (2 players, 2 boards) assumed.

---

## Confidence

| | Value |
|---|-------|
| Root cause | 95% |
| Solution path | 92% |

See [e2e_smarter_tap_strategy](.cursor/plans/e2e_smarter_tap_strategy_30bdb130.plan.md) for full design.

---

## Test Plan (ui-test)

| Journey | Steps | Viewport | Validation |
|---------|-------|----------|------------|
| Level 5 playthrough (L3) | Launch → Settings → gameLevelStepper +5 → Done → New Game → runFullPlaythrough | iPhone 16 / current simulator | Game over (restartButton or win/lose/tie) |
| P0-only smarter taps (L2) | New Game → play loop with SmarterTapStrategy on P0 turn only | Same | Game over within 180–240s |
| Strategy sequence (L1) | testSmarterTapStrategySequence: 20× nextZone() | N/A (unit-style) | Contains moveLeft, moveRight, hardDrop |

XCUITest; no Playwright. Reuse existing testSettingsSheet, testFullPlaythroughUntilGameOver patterns.

---

## Logic-Test Coverage

| Scope | Validated | Notes |
|-------|-----------|-------|
| SmarterTapStrategy zones | moveLeft, moveRight, hardDrop, rotate map to BoardTapHelper.tapPoint | All zones produce valid CGPoint in grid frame |
| P0-only guard | No tap when `!player1Turn` | usleep(stepDelayUs); continue; prevents AI-turn tap |
| Level 5 virus count | 14 per grid (virusCount(level:5)) | Unit test testGameStateLevel5VirusCount |
| Game-over assertions | restartButton, win/lose/tie text | Existing testFullPlaythroughUntilGameOver |

---

## Infrastructure (infrastructure)

| Concern | Recommendation |
|---------|----------------|
| CI execution time | testFullPlaythroughLevel5 ~240s; run in parallel with faster tests; consider nightly only for long E2E |
| Simulator resources | Single simulator; no hosting; zero cost |
| Stability | menuReadyTimeout 60s, gameHudReadyTimeout 10s; existing waits sufficient |
| Offline | All tests run locally; no network |

---

## Reconciliation (Investigator)

Plan updated to incorporate test-plan (ui-test), logic-test, and infrastructure outcomes. Chunk sub-plans (L1, L2, L3) already reference these concerns. L3 Detailed Design added for stepper API; fallback documented.
