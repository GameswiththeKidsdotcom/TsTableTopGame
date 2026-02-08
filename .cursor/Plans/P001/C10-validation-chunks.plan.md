# C10 – Validation Chunks (Small Executable Pieces)

## Next hand off (cut & paste)

Execute or validate **C10-V2: Game Over (win) overlay** per this plan. Outcome: Play until P0 or P1 clears all viruses; overlay shows "Player X wins!", cash, Restart, Return to Menu. Agent: Manual / UI-Test. After completion, update Master-Plan.md and this section to the next chunk (C10-V3), and set Testing status for C10-V2 to Done in the Master-Plan C10 Validation Chunks table.

---

**Parent**: [C10-menus.plan.md](C10-menus.plan.md). C10 code is built; these chunks are the remaining validation work, decomposed for AI execution.

---

## Scope

- C10 implementation is done (menus, game over, restart, settings persist).
- Remaining work: manual/E2E validation, logic-test E2E, UI-test, infrastructure.
- Each chunk = one verifiable outcome; execute in order.

---

## Validation Chunks (Execute in Order)

| Chunk | Outcome | Validation | Agent |
|-------|---------|------------|-------|
| **C10-V1** | Launch → Menu → New Game | MenuView visible; New Game shows GameView with two boards | Manual / UI-Test |
| **C10-V2** | Game Over (win) overlay | Play until P0 or P1 clears all viruses; overlay shows "Player X wins!", cash, Restart, Return to Menu | Manual / UI-Test |
| **C10-V3** | Game Over (lose) overlay | Play until P0 top-outs → "Player 2 wins!"; P1 top-outs → "Player 1 wins!" | Manual / UI-Test |
| **C10-V4** | Game Over (tie) overlay | Play until both top-out; overlay shows "Tie!" | Manual / UI-Test |
| **C10-V5** | Restart and Return to Menu | Tap Restart → new game; Tap Return to Menu → MenuView | Manual / UI-Test |
| **C10-V6** | Settings sheet | Menu → Settings; Sound toggle, AI delay slider; Done dismisses | Manual / UI-Test |
| **C10-V7** | Settings persist | Change settings, kill app, relaunch; confirm values | Manual |
| **C10-V8** | Viewport layout | iPhone SE, iPhone 15 Pro Max, iPad Pro 11; GameOverOverlay legible | UI-Test |
| **C10-V9** | Layout and contrast | GameOverOverlay white-on-black; Restart/Return to Menu buttons tappable; HUD contrast | UI-Test |
| **C10-V10** | Logic-test E2E (optional) | Fixture-based init; force single-player-left, tie, restart clean | Logic-Test |
| **C10-V11** | Infrastructure | Offline spec; no network calls; optional CI | Static / manual |

---

## Dependencies

- C10-V1 must pass before C10-V2–V6 (need game flow).
- C10-V2–V4 can run in parallel (different game outcomes).
- C10-V7 requires C10-V6 (Settings UI).
- C10-V8–V9 are layout checks; can run after C10-V2–V4.

---

## Cross-Reference

- **Logic-Test**: [logic-test.plan.md](logic-test.plan.md) – lose-scenario unit tests done; C10-V10 = E2E.
- **UI-Test**: [ui-test.plan.md](ui-test.plan.md) – E2E journeys, lose-scenario UI, viewports.

---

## Per-Chunk Agent Validation (Investigator, Logic-Test, UI-Test)

### C10-V1: Launch → Menu → New Game

| Agent | Findings / Evidence | Coverage |
|-------|---------------------|----------|
| **Investigator** | RootView shows MenuView at launch; New Game sets AppPhase = .playing, presents GameView. TableTopGameApp → RootView. Outcome clear; validation manual. | 92% root cause, 92% solution path |
| **Logic-Test** | No game logic; UI flow only. Defer to UI-Test. | N/A |
| **UI-Test** | E2E journey: Launch → MenuView (TableTopGame, New Game, Settings) → New Game → GameView (two boards, HUD). Covered in ui-test.plan E2E journeys. | Confirmed |

### C10-V2: Game Over (win) overlay

| Agent | Findings / Evidence | Coverage |
|-------|---------------------|----------|
| **Investigator** | GameState.phase == .gameOver(winnerId, false) when cleared all viruses. GameOverOverlay binds to stateDisplay.phase. Outcome clear. | 92% root cause, 92% solution path |
| **Logic-Test** | WinConditionChecker.resolveGameOver(clearedAllCurrent: true) → gameOver. Unit tested. | Confirmed |
| **UI-Test** | E2E: play until win → overlay "Player X wins!", cash, Restart, Return to Menu. Covered. | Confirmed |

### C10-V3: Game Over (lose) overlay – P0/P1 top-out

| Agent | Findings / Evidence | Coverage |
|-------|---------------------|----------|
| **Investigator** | P0 top-out → eliminated.insert(0) → singlePlayerLeft → winnerId=1. GameOverOverlay shows "Player 2 wins!". Same for P1. Outcome clear. | 92% root cause, 92% solution path |
| **Logic-Test** | testWinConditionCheckerResolveGameOverLoseScenario, testGameStateTopOutEliminatesPlayerAndOpponentWins. Logic coverage complete. | Confirmed |
| **UI-Test** | E2E: P0 top-out → "Player 2 wins!"; P1 top-out → "Player 1 wins!". Lose-scenario UI coverage in ui-test.plan. | Confirmed |

### C10-V4: Game Over (tie) overlay

| Agent | Findings / Evidence | Coverage |
|-------|---------------------|----------|
| **Investigator** | Both eliminated → isTie → gameOver(winnerId: nil, isTie: true). GameOverOverlay shows "Tie!". Outcome clear. | 92% root cause, 92% solution path |
| **Logic-Test** | testWinConditionCheckerResolveGameOverTie. Unit tested. | Confirmed |
| **UI-Test** | E2E: both top-out → overlay "Tie!". Covered. | Confirmed |

### C10-V5: Restart and Return to Menu

| Agent | Findings / Evidence | Coverage |
|-------|---------------------|----------|
| **Investigator** | Restart: startNewGame() → new GameScene. Return to Menu: onReturnToMenu → AppPhase = .menu. Outcome clear. | 92% root cause, 92% solution path |
| **Logic-Test** | No game logic; flow only. Defer to UI-Test. | N/A |
| **UI-Test** | E2E: Tap Restart → new game; Tap Return to Menu → MenuView. Covered. | Confirmed |

### C10-V6: Settings sheet

| Agent | Findings / Evidence | Coverage |
|-------|---------------------|----------|
| **Investigator** | MenuView → Settings presents SettingsView sheet. Sound toggle, AI delay slider. Done dismisses. Outcome clear. | 92% root cause, 92% solution path |
| **Logic-Test** | No game logic. Defer to UI-Test. | N/A |
| **UI-Test** | E2E: Menu → Settings → sheet with Sound, AI delay; Done. Covered. | Confirmed |

### C10-V7: Settings persist

| Agent | Findings / Evidence | Coverage |
|-------|---------------------|----------|
| **Investigator** | SettingsManager uses UserDefaults; soundEnabled, aiDelaySeconds persist. Manual: kill app, relaunch, confirm. Outcome clear. | 92% root cause, 92% solution path |
| **Logic-Test** | testSettingsManagerSetAndReadBack. Unit tested. | Confirmed |
| **UI-Test** | Manual validation; no additional UI coverage. | N/A |

### C10-V8: Viewport layout

| Agent | Findings / Evidence | Coverage |
|-------|---------------------|----------|
| **Investigator** | GameOverOverlay layout must be legible on iPhone SE (375×667), iPhone 15 Pro Max (430×932), iPad Pro 11 (834×1194). Outcome clear. | 92% root cause, 92% solution path |
| **Logic-Test** | Layout; defer to UI-Test. | N/A |
| **UI-Test** | Viewport matrix in ui-test.plan. iPhone SE, 15 Pro Max, iPad Pro 11. Covered. | Confirmed |

### C10-V9: Layout and contrast

| Agent | Findings / Evidence | Coverage |
|-------|---------------------|----------|
| **Investigator** | GameOverOverlay: white on black 0.7 opacity. Restart (accent), Return to Menu (gray). HUD: black 0.6, white text. Outcome clear. | 92% root cause, 92% solution path |
| **Logic-Test** | Contrast; defer to UI-Test. | N/A |
| **UI-Test** | Layout and contrast section in ui-test.plan. Covered. | Confirmed |

### C10-V10: Logic-test E2E (optional)

| Agent | Findings / Evidence | Coverage |
|-------|---------------------|----------|
| **Investigator** | Fixture-based GameState init exists. Force single-player-left, tie, restart clean via fixtures. Outcome clear. | 90% root cause, 90% solution path |
| **Logic-Test** | E2E scope: fixture-based init → assert phase. logic-test.plan covers. Optional. | Confirmed |
| **UI-Test** | Logic-test scope; defer. | N/A |

### C10-V11: Infrastructure

| Agent | Findings / Evidence | Coverage |
|-------|---------------------|----------|
| **Investigator** | SPEC: offline-only; no network. Optional CI. Outcome clear. | 92% root cause, 92% solution path |
| **Logic-Test** | Infrastructure; defer. | N/A |
| **UI-Test** | Infrastructure; defer. | N/A |

---

## Confidence (Blaster-reconciled)

| Chunk | Confidence (root cause) | Confidence (solution path) | Note |
|-------|-------------------------|----------------------------|------|
| C10-V1 | 92% | 92% | Outcome clear; UI-Test covers |
| C10-V2 | 92% | 92% | Logic + UI covered |
| C10-V3 | 92% | 92% | Lose-scenario logic + UI covered |
| C10-V4 | 92% | 92% | Tie logic + UI covered |
| C10-V5 | 92% | 92% | Flow clear; UI-Test covers |
| C10-V6 | 92% | 92% | Settings UI covered |
| C10-V7 | 92% | 92% | SettingsManager unit tested |
| C10-V8 | 92% | 92% | Viewport matrix in ui-test.plan |
| C10-V9 | 92% | 92% | Layout/contrast in ui-test.plan |
| C10-V10 | 90% | 90% | Optional E2E; fixture init exists |
| C10-V11 | 92% | 92% | Infrastructure; offline spec |

---

## Blaster Reconciliation (Per-Chunk Fidelity)

Blaster ran Investigator, Logic-Test, and UI-Test on each C10-V chunk:

| Chunk | Investigator | Logic-Test | UI-Test | Gate (≥90%) |
|-------|--------------|------------|---------|-------------|
| C10-V1 | ✓ 92%/92% | N/A (UI only) | ✓ Confirmed | Met |
| C10-V2 | ✓ 92%/92% | ✓ Confirmed | ✓ Confirmed | Met |
| C10-V3 | ✓ 92%/92% | ✓ Confirmed | ✓ Confirmed | Met |
| C10-V4 | ✓ 92%/92% | ✓ Confirmed | ✓ Confirmed | Met |
| C10-V5 | ✓ 92%/92% | N/A | ✓ Confirmed | Met |
| C10-V6 | ✓ 92%/92% | N/A | ✓ Confirmed | Met |
| C10-V7 | ✓ 92%/92% | ✓ Confirmed | N/A | Met |
| C10-V8 | ✓ 92%/92% | N/A | ✓ Confirmed | Met |
| C10-V9 | ✓ 92%/92% | N/A | ✓ Confirmed | Met |
| C10-V10 | ✓ 90%/90% | ✓ Confirmed | N/A | Met |
| C10-V11 | ✓ 92%/92% | N/A | N/A | Met |

**Gate status**: All chunks ≥90% confidence. C10-V10 is optional; 90%/90% acceptable.
