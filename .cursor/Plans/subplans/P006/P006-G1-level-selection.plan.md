---
name: P006-G1 Level Selection
overview: Add level picker so player chooses difficulty; virus count follows min(4 + level × 2, 50).
todos: []
isProject: false
---

# P006-G1 – Level Selection UI

**Next hand off (cut & paste)**: **P006 G1 — Level selection** (Builder). [P006-G1-level-selection.plan.md](.cursor/Plans/subplans/P006/P006-G1-level-selection.plan.md). Implementation complete; run full test suite; manual validation (level 5 → 14 viruses; Restart same count). If validation fails, implement missing wiring per Steps table. Confirm no regressions before commit. No conflict with Lane A (P001-C7-Garbage touches AttackCalculator, tests).

**Lane B:** Safe to run in parallel with Lane A. P006 G1 touches SettingsManager, SettingsView, GameScene — disjoint from P001-C7-Garbage (AttackCalculator, tests).

**Builder scope:** Implementation appears complete (Steps 1–5 Done). Builder: run full test suite; perform manual validation (level 5 → 14 viruses; Restart same count). If any step fails validation, implement missing wiring per Steps table. Confirm no regressions before commit.

---

## Outcome

Player selects level (e.g. 0–10 or 0–23) before starting a game. Each new game uses that level for virus count: `min(4 + level × 2, 50)`.

---

## Steps

| Step | Task | Validation | Status |
|------|------|-------------|--------|
| 1 | Add `gameLevel: Int` to SettingsManager (key `gameLevel`, default 0); persist | Unit test: set 5, read back 5 | Done — `testSettingsManagerRoundTrip` |
| 2 | Add level picker to SettingsView (Stepper or Picker, range 0–10) | Manual: change level, kill app, relaunch; persists | Done — Stepper 0–10, `gameLevelStepper` |
| 3 | GameScene reads `SettingsManager.shared.gameLevel` in didMoveToView | Trace: level flows to GameState | Done — no GameView change; Scene reads at init |
| 4 | GameScene passes level to `GameState(level:)` | Unit test: `GameState(level: 5)` has 14 viruses per grid | Done — `testGameStateLevel5VirusCount` |
| 5 | Restart uses same level (from Settings) | Manual: restart game, same virus count | Done — startNewGame → new GameScene → reads fresh gameLevel |

**Builder validation:** Run full test suite; manual: set level 5 in Settings, New Game, verify ~14 viruses per grid; Restart, verify same count.

---

## Integration points

| Component | Change | Implementation |
|-----------|--------|----------------|
| SettingsManager | `gameLevel: Int` with UserDefaults | `gameLevelKey`, `defaultGameLevel = 0` |
| SettingsView | Stepper bound to gameLevel | `Section("Game")` Stepper 0–10, `accessibilityIdentifier("gameLevelStepper")` |
| GameView | No change; startNewGame() creates GameScene() | Scene reads level when presented |
| GameScene | `didMove(to:)` reads `SettingsManager.shared.gameLevel`; `GameState(level: level)` | Lines 68–69 |
| GameState | `init(level: Int = 0)` | Uses level for `makeInitialViruses(level:)` |

---

## Rollback

If regressions: (1) Remove gameLevel from SettingsManager and SettingsView; (2) GameScene.didMoveToView revert to `GameState(level: 0)`; (3) Run full test suite to confirm baseline.

---

## Validation strategy

- **Unit:** `testSettingsManagerRoundTrip` (gameLevel 5 round-trip), `testGameStateLevel5VirusCount` (14 viruses at level 5).
- **Manual:** Set level 5 in Settings → New Game → count viruses per grid (expect 14); Restart → same count.
- **Regression:** Run `xcodebuild test` before/after any change.

---

## Risks

- None identified; SettingsManager/GameScene patterns already established. No overlap with P002 (GravityEngine).

---

## Confidence

| | Value | Note |
|---|-------|------|
| **Confidence (root cause)** | 98% | SPEC states virus count per level; model correct |
| **Confidence (solution path)** | 95% | Steps 1–5; SettingsManager pattern established |
