---
name: P006-E2E-L1 SmarterTapStrategy
overview: Add SmarterTapStrategy struct and testSmarterTapStrategySequence.
---

**Next hand off (cut & paste)**: **P006-E2E L1 — SmarterTapStrategy struct.** Builder: Add `SmarterTapStrategy` to [TableTopGameUITests.swift](TableTopGameUITests/TableTopGameUITests.swift); add `testSmarterTapStrategySequence()` that iterates `nextZone()` 20 times and asserts sequence contains `.moveLeft`, `.moveRight`, `.hardDrop`. Run UI tests; L1 passes.

---

## Outcome

SmarterTapStrategy struct exists; unit test proves it produces left/right/drop (not just rotate).

## Steps

1. Add `SmarterTapStrategy` struct (see main plan section 3.1) after BoardTapHelper in TableTopGameUITests.swift.
2. Add `testSmarterTapStrategySequence()`: create strategy, loop 20 times calling `nextZone()`, collect zones; assert `contains(.moveLeft)`, `contains(.moveRight)`, `contains(.hardDrop)`.
3. Run `xcodebuild test -only-testing:TableTopGameUITests/testSmarterTapStrategySequence`.

## Validation

- testSmarterTapStrategySequence passes.
- Strategy produces at least one of each zone type in 20 calls.

## Rollback

Remove struct and test.

## Confidence

| | Value | Note |
|---|-------|------|
| Root cause | 95% | Zone variety improves playthrough win rate; SPEC-aligned |
| Solution path | 92% | Struct + test self-contained; no game-state deps |

## Per-chunk fidelity (Blaster)

| Agent | Finding |
|-------|---------|
| **Investigator** | Struct and test are self-contained; no game-state dependency. Confidence 95/92. Steps 1–3 sufficient; rollback clear. |
| **ui-test** | testSmarterTapStrategySequence validates zone variety; zones map to BoardTapHelper.tapPoint. No E2E journey change in L1. |
| **logic-test** | Zone types (moveLeft, moveRight, hardDrop, rotate) map to valid BoardTapHelper zones. No game logic. No move/state regression. |
| **infrastructure** | Pure struct; no infra. No CI, hosting, or resource changes. |
