# P001-UI – UI-Test (E2E User Journeys, Layout, Contrast)

**Scope**: E2E user journeys, layout, contrast, iPhone/iPad viewports. C10 game-over flow including win, lose, and tie scenarios. Delegate UI-Test agent at C10.

---

## Platform

- v1: iOS & iPadOS only. Swift/SwiftUI/SpriteKit. XCUITest or manual validation; Playwright not applicable (native app).

---

## E2E User Journeys

| Journey | Steps | Validation |
|---------|-------|------------|
| **Launch → Menu** | Launch app | MenuView visible: "TableTopGame", New Game, Settings |
| **Menu → New Game** | Tap New Game | GameView with two boards, HUD, capsule |
| **Game → Game Over (win)** | Play until one player clears all viruses | GameOverOverlay: "Player X wins!", P1/P2 cash, Restart, Return to Menu |
| **Game → Game Over (lose)** | Play until one player top-outs (spawn blocked) | GameOverOverlay: winner text (opponent wins; loser sees "Player X wins!" where X ≠ self), cash, Restart, Return to Menu |
| **Game → Game Over (tie)** | Play until both top-out | GameOverOverlay: "Tie!", P1/P2 cash, Restart, Return to Menu |
| **Restart** | Tap Restart on overlay | New game starts; overlay dismisses |
| **Return to Menu** | Tap Return to Menu on overlay | MenuView visible |
| **Settings** | Menu → Settings | SettingsView sheet: Sound toggle, AI delay slider; Done |

---

## Lose-Scenario UI Coverage

| Scenario | UX Assertion |
|----------|--------------|
| **P0 top-outs (P0 loses)** | GameOverOverlay shows "Player 2 wins!" (P1 wins) |
| **P1 top-outs (P1 loses)** | GameOverOverlay shows "Player 1 wins!" (P0 wins) |
| **Both top-out (tie)** | GameOverOverlay shows "Tie!" |
| **Overlay layout** | Semi-transparent backdrop; winner/tie text legible; P1/P2 cash; Restart and Return to Menu buttons tappable |

---

## Viewports (Newest 3 per form factor)

| Form factor | Device / viewport | Notes |
|-------------|-------------------|-------|
| iPhone small | iPhone SE (3rd gen) 375×667 | Min width |
| iPhone standard | iPhone 15 393×659 | Mid-size |
| iPhone large | iPhone 15 Pro Max 430×932 | Max iPhone |
| iPad compact | iPad (gen 11) 656×944 | |
| iPad standard | iPad Pro 11 834×1194 | |
| iPad large | iPad (gen 7) 810×1080 | |

Test GameOverOverlay layout and contrast on smallest and largest viewport per form factor (iPhone, iPad).

---

## Layout and Contrast

- **GameOverOverlay**: White text on semi-transparent black (0.7 opacity). Verify legibility.
- **Buttons**: Restart (accent color), Return to Menu (gray); sufficient contrast.
- **HUD**: Black opacity 0.6; white text; verify on dark game background.

---

## Executable Chunks (Planner)

Each chunk maps to [C10-validation-chunks.plan.md](C10-validation-chunks.plan.md). Execute in order.

| Chunk | Outcome | Validation |
|-------|---------|------------|
| C10-V1 | Launch → Menu → New Game | MenuView; New Game → GameView |
| C10-V2 | Game Over (win) overlay | "Player X wins!", cash, Restart, Return to Menu |
| C10-V3 | Game Over (lose) overlay | P0 top-out → "Player 2 wins!"; P1 top-out → "Player 1 wins!" |
| C10-V4 | Game Over (tie) overlay | Both top-out → "Tie!" |
| C10-V5 | Restart, Return to Menu | Restart → new game; Return to Menu → MenuView |
| C10-V6 | Settings sheet | Sound toggle, AI delay slider, Done |
| C10-V8 | Viewport layout | iPhone SE, 15 Pro Max, iPad Pro 11 |
| C10-V9 | Layout and contrast | GameOverOverlay, buttons, HUD |

**C10 Validation Chunks (UI-Test scope)**: C10-V1 through C10-V6, C10-V8, C10-V9. UI-Test confirmed coverage for each. See [C10-validation-chunks.plan.md](C10-validation-chunks.plan.md).

---

## Cross-Reference

- **Logic-Test**: Lose-scenario logic tests (`testWinConditionCheckerResolveGameOverLoseScenario`, `testGameStateTopOutEliminatesPlayerAndOpponentWins`) validate state. UI-Test validates the displayed outcome.
- **C10**: Manual test or XCUITest for game-over flow.
