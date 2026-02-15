---
name: P006-G1 Level Selection
overview: Add level picker so player chooses difficulty; virus count follows min(4 + level × 2, 50).
todos: []
isProject: false
---

# P006-G1 – Level Selection UI

**Next hand off (cut & paste)**: **P006 G1 — Level selection UI.** Builder: Add level picker to MenuView or Settings; store in SettingsManager under key `gameLevel` (Int, default 0); GameView reads level on startNewGame(), passes to GameScene; GameScene passes to `GameState(level:)`. Unit test: `GameState(level: 5)` yields 14 viruses per grid (`virusCount(5)=14`). Investigator: validate for 90%+ confidence. Plan: [P006-G1-level-selection.plan.md](P006-G1-level-selection.plan.md).

---

## Outcome

Player selects level (e.g. 0–10 or 0–23) before starting a game. Each new game uses that level for virus count: `min(4 + level × 2, 50)`.

---

## Steps

| Step | Task | Validation |
|------|------|-------------|
| 1 | Add `gameLevel: Int` to SettingsManager (key `gameLevel`, default 0); persist | Unit test: set 5, read back 5 |
| 2 | Add level picker to SettingsView (Stepper or Picker, range 0–10 or 0–23) | Manual: change level, kill app, relaunch; persists |
| 3 | GameView reads `SettingsManager.shared.gameLevel` in startNewGame() | Trace: level flows to GameState |
| 4 | GameScene receives level (init param or from GameView); passes to `GameState(level:)` | Unit test: `GameState(level: 5)` has 14 viruses per grid |
| 5 | Restart uses same level (from Settings) | Manual: restart game, same virus count |

---

## Integration points

| Component | Change |
|-----------|--------|
| SettingsManager | `gameLevel: Int` with UserDefaults |
| SettingsView | Stepper or Picker bound to gameLevel |
| GameView | Pass level to GameScene (or Scene reads SettingsManager) |
| GameScene | `init(level: Int)` or read from SettingsManager; `GameState(level: level)` |
| GameState | No change; already has `init(level:)` |

---

## Rollback

Remove gameLevel from SettingsManager and UI; GameScene reverts to `GameState(level: 0)`.

---

## Confidence

| | Value | Note |
|---|-------|------|
| **Confidence (root cause)** | 98% | SPEC states virus count per level; model correct |
| **Confidence (solution path)** | 95% | Steps 1–5; SettingsManager pattern established |
