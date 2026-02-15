# Full Playthrough E2E Harness Plan

## Next hand off (cut & paste) — Lane A

**Done (2026-02-08).** P001-E2E full playthrough validation completed: full `xcodebuild test` (unit + UI) passed on iPhone 16; E2E-P8 viewport matrix documented as implemented. Master-Plan P001-E2E state set to **Testing complete**. No further hand off from this plan unless new E2E scope is added.

---

Per [.cursor/agents/e2e-harness.md](../../.cursor/agents/e2e-harness.md): design-only output (journey map, viewport matrix, user-usable objects, handoffs). Aligns with [ui-test.plan.md](ui-test.plan.md) and [C10-validation-chunks.plan.md](C10-validation-chunks.plan.md).

**Confidence (Investigator):** After corrections: root cause N/A (design); solution path 90%.

---

## Build chunks (Planner)

| Chunk | Outcome | Dependency |
|-------|---------|------------|
| **E2E-P1** | Add TableTopGameUITests UI test target; scheme runs app + UI tests; `xcodebuild test` runs both. | None |
| **E2E-P2** | Launch → Menu: launch app, assert "TableTopGame" and `newGameButton` visible. | E2E-P1 |
| **E2E-P3** | Menu → New Game: tap `newGameButton`, assert GameView (two boards, HUD). | E2E-P2 |
| **E2E-P4** | Board-tap helper: compute grid bounds from scene (same formula as GameScene); tap inside rect with relX/relY zones per FIXTURES.md. | E2E-P3 |
| **E2E-P5** | Play until game over: loop tap active board; wait until `restartButton` or win/tie title visible; timeout e.g. 180s. | E2E-P4 |
| **E2E-P6** | Overlay assertions: title, P1/P2 cash, Restart and Return to Menu hittable. | E2E-P5 |
| **E2E-P7a** | Restart path: tap `restartButton`, assert overlay gone, game visible. | E2E-P6 |
| **E2E-P7b** | Return to Menu path: tap `returnToMenuButton`, assert MenuView. | E2E-P6 |
| **E2E-P8** (optional) | Viewport matrix: overlay legibility on iPhone SE, 15 Pro Max, iPad Pro 11. | E2E-P7a/P7b |

**E2E-P8 status (2026-02-08):** Implemented. Overlay legibility asserted by `testC10V8GameOverOverlayLegibleOnViewports` (GameOver fixture win → title, P1/P2 cash, Restart/Return to Menu exist and hittable). CI viewport-matrix job (`.github/workflows/test.yml`) runs overlay fixture tests on iPhone SE (3rd gen), iPhone 15 Pro Max, and iPad Pro 11-inch (4th gen). Full playthrough primary device remains iPhone 15/16 per plan.

---

## 1. Journey map

**Entry:** Cold launch of TableTopGame (iOS Simulator or device).

**Exit:** Either (A) new game in progress (after Restart) or (B) MenuView visible (after Return to Menu).

**Primary full-playthrough journey:**

| Step     | Action                            | Success criteria |
| -------- | --------------------------------- | ---------------- |
| 1        | Launch app                        | App foreground; no crash. |
| 2        | Wait for Menu                     | Static text "TableTopGame" visible; button "New Game" visible. |
| 3        | Tap New Game                      | `accessibilityIdentifier("newGameButton")` tap; transition to game. |
| 4        | Wait for GameView                 | Two boards visible (SpriteView); HUD with "Player 1's turn" or "Player 2's turn"; no overlay. |
| 5        | Play until game over              | Repeatedly tap inside **active** board using [FIXTURES.md](../../docs/FIXTURES.md) zones. **Continue until GameOverOverlay is visible:** e.g. `restartButton` exists and is hittable, or static text "Player 1 wins!" / "Player 2 wins!" / "Tie!" is visible. (XCUITest cannot observe `stateDisplay.phase`.) |
| 6        | Assert overlay                    | GameOverOverlay visible: title ("Player 1 wins!", "Player 2 wins!", or "Tie!"); "P1: $N", "P2: $M"; `restartButton` and `returnToMenuButton` exist and are hittable. |
| 7a or 7b | Tap Restart **or** Return to Menu | 7a: tap `restartButton` → overlay dismisses, new game. 7b: tap `returnToMenuButton` → MenuView. |

**Assumptions:** Step 5 is non-deterministic in length. Single run = one outcome (win, lose, or tie). Optional later: test-only launch arg (e.g. `-GameOverFixture win`) for overlay-only assertion.

---

## 2. Viewport / device matrix

| Form factor     | Device / viewport           | Use in harness |
| --------------- | --------------------------- | --------------- |
| iPhone small    | iPhone SE (3rd gen) 375×667 | Viewport/layout (C10-V8); optional full playthrough. |
| iPhone standard | iPhone 15 393×659           | **Primary full playthrough.** |
| iPhone large    | iPhone 15 Pro Max 430×932   | Viewport/layout (C10-V8). |
| iPad compact    | iPad (gen 11) 656×944       | Optional. |
| iPad standard   | iPad Pro 11 834×1194        | Viewport/layout (C10-V8). |
| iPad large      | iPad (gen 7) 810×1080       | Optional. |

Implement full playthrough on **iPhone 15** first.

---

## 3. User-usable object list

| Screen / region | Object           | Selector / approach | Validation |
| ------------------- | ---------------- | ------------------- | ---------- |
| Menu                | App title        | Static text "TableTopGame" | Exists, visible. |
| Menu                | New Game         | `accessibilityIdentifier("newGameButton")` | Tap; then assert GameView. |
| Menu                | Settings         | `accessibilityIdentifier("settingsButton")` | Optional. |
| GameView            | Left board (P0)  | Coordinate-based inside grid bounds (see below). | Taps inside `leftGridFrame` when P0 active. |
| GameView            | Right board (P1) | Same, right grid bounds. | Taps inside `rightGridFrame` when P1 active. |
| GameView            | HUD              | Static text "Player X's turn" or "Game Over" | Optional. |
| GameOverOverlay     | Title            | Static text "Player 1 wins!" / "Player 2 wins!" / "Tie!" | Exact match. |
| GameOverOverlay     | Cash             | Static text "P1: $N", "P2: $M" | Optional. |
| GameOverOverlay     | Restart          | `accessibilityIdentifier("restartButton")` | Tap; assert overlay gone. |
| GameOverOverlay     | Return to Menu   | `accessibilityIdentifier("returnToMenuButton")` | Tap; assert MenuView. |

**Coordinate strategy for boards (Investigator correction):** The tappable area is **not** the full half of the scene; each grid is **centered** in its half. Use the **same layout formula as GameScene** ([GameScene.swift](../../TableTopGame/GameScene.swift) lines 139–153): `halfW = sceneWidth/2`, `cellSize = min(halfW/8, sceneHeight/16)`, `gridPixelW = 8*cellSize`, `gridPixelH = 16*cellSize`, `offsetY = (sceneHeight - gridPixelH)/2`, `leftGridLeft = (halfW - gridPixelW)/2`, `rightGridLeft = halfW + (halfW - gridPixelW)/2`. Taps must use coordinates **inside** these rects; within each rect use relX/relY per FIXTURES.md: left 25% = move left, right 25% = move right, top 20% = hard drop, else = rotate. Document this formula in the test (or shared doc) so viewport changes don’t silently break taps. Alternative: add a test-only API to expose grid frames.

---

## 4. Handoffs

- **ui-test:** Implement XCUITest target and full-playthrough test(s) per this harness (chunks E2E-P1–P7b).
- **logic-test:** If the harness is extended to assert move/state rules during play, invoke logic-test.
- **Investigator:** When implementing, invoke for 90%+ confidence and Master-Plan alignment.
- **infrastructure:** When adding UI test target and/or CI, invoke for test runner, simulator, timeouts, retries.

---

## 5. Risks and mitigation

| Risk | Mitigation |
|------|-------------|
| "Play until game over" long and flaky | One device (iPhone 15); consider test hook for overlay-only. |
| Board coordinates break on resolution | Use GameScene formula; document in test; viewport matrix. |
| Auto-drop and AI delay | Explicit waits; generous timeout (e.g. 180s) for step 5. |
| No UI test target yet | E2E-P1: add target first. |

---

## 6. Rollback

- If E2E too flaky: disable long playthrough in CI; keep Launch → Menu → New Game (and optional test-hook overlay).
- If coordinates break: fall back to manual gameplay; keep overlay and menu assertions automated.

---

## 7. Interface validation (watchable / RPA-style)

To validate that the interface works with real mouse/finger taps (visible in Simulator), use a watchable run:

- **Script**: `./scripts/run-e2e-watchable.sh` (or `--quick` for faster taps). Builds first, brings Simulator to foreground, then runs the test.
- **Xcode**: Product > Test, or run `testFullPlaythroughUntilGameOverSlow` from the Test Navigator. Xcode keeps Simulator visible.

See [docs/E2E.md](../../docs/E2E.md).

## 8. References

- [e2e-harness.md](../../.cursor/agents/e2e-harness.md), [ui-test.plan.md](ui-test.plan.md), [C10-validation-chunks.plan.md](C10-validation-chunks.plan.md)
- [FIXTURES.md](../../docs/FIXTURES.md) – tap zones (left 25%, right 25%, top 20%, middle rotate)
- [E2E.md](../../docs/E2E.md) – watchable run (RPA-style)
- [GameView.swift](../../TableTopGame/GameView.swift), [RootView.swift](../../TableTopGame/RootView.swift), [GameScene.swift](../../TableTopGame/GameScene.swift)
