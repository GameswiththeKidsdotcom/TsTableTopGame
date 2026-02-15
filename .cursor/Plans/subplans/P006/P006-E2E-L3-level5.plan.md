---
name: P006-E2E-L3 Level 5 Playthrough
overview: Add testFullPlaythroughLevel5 that sets level 5 in Settings then runs full playthrough.
---

**Next hand off (cut & paste)**: **P006-E2E L3 — Level 5 playthrough.** Builder: Add `testFullPlaythroughLevel5()` in [TableTopGameUITests.swift](TableTopGameUITests/TableTopGameUITests.swift): launch → Settings → set level 5 via gameLevelStepper → Done → New Game → run full playthrough (240s timeout). Assert game over (any outcome). Run test; passes.

---

## Outcome

E2E test that plays through a level 5 game with smarter taps; validates level selection + gameplay flow.

## Steps

1. Add `testFullPlaythroughLevel5()`.
2. app.launch()
3. Tap settingsButton; wait for gameLevelStepper.
4. Increment stepper 5 times (or tap + button 5 times) to set level 5.
5. Assert "Difficulty: Level 5" visible.
6. Tap settingsDoneButton.
7. Tap newGameButton.
8. Call runFullPlaythrough logic with totalTimeout: 240 (or extract shared helper).
9. Assert game over (restartButton or win/lose/tie text).
10. Run test; may take up to 240s.

## Validation

- testFullPlaythroughLevel5 passes (reaches game over within 240s).
- Level 0 test (testFullPlaythroughUntilGameOver) still passes as smoke.

## Rollback

Remove testFullPlaythroughLevel5.

## Confidence

| | Value |
|---|-------|
| Root cause | 95% |
| Solution path | 92% — stepper API verified; fallback documented |

## Detailed Design (Investigator)

**Stepper interaction for level 5:**
- Primary: `app.steppers["gameLevelStepper"].buttons["Increment"].tap()` called 5 times (from default 0 to 5). XCUITest exposes stepper sub-buttons as "Increment"/"Decrement" (or "Add"/"Reduce" in some locales).
- Risk: SwiftUI Stepper has a reported XCTest bug where increment/decrement buttons may not be hittable (`kAXErrorCannotComplete`). If primary fails: (1) verify `gameLevelStepper` exists and `buttons["Increment"]` exists; (2) try `buttons["Add"]` for alternate locale; (3) fallback: add `.accessibilityIdentifier("gameLevelIncrement")` to a custom Stepper wrapper, or swap to Picker (more testable) if blocker persists.
- Assert: "Difficulty: Level 5" staticText confirms value before Done.

## Per-chunk fidelity (Blaster)

| Agent | Finding |
|-------|---------|
| **Investigator** | Level 5 flow is clear. Stepper: use `stepper.buttons["Increment"].tap()` 5x; fallback documented (SwiftUI XCTest bug). Confidence 95/92. |
| **ui-test** | Extends E2E to level-selection journey (Settings → gameLevelStepper → level 5 → New Game → play). Covers P006 G1 + playthrough. Viewport: iPhone 16. |
| **logic-test** | Level 5 virus count (14) unit-tested in testGameStateLevel5VirusCount. E2E asserts game-over only; no new game logic. |
| **infrastructure** | 240s timeout; consider nightly or parallel run for CI. Zero cost; local simulator. |
