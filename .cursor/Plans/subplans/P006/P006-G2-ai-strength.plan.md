---
name: P006-G2 AI Strength
overview: Add AI difficulty setting (Easy=RandomAI, Hard=GreedyAI); persist in Settings.
todos: []
isProject: false
---

# P006-G2 – AI Strength Setting

**Next hand off (cut & paste)**: **P006 G2 — AI strength.** Builder: Add `AIStrength` enum (easy, hard) and `aiStrength` to SettingsManager; add Picker to SettingsView; GameScene reads `SettingsManager.shared.aiStrength` in didMoveToView and sets `aiController = aiStrength == .easy ? RandomAI() : GreedyAI()`. Unit test: SettingsManager round-trip. Manual: Easy yields random-like moves; Hard yields match-seeking. Investigator: validate for 90%+ confidence. Plan: [P006-G2-ai-strength.plan.md](P006-G2-ai-strength.plan.md).

---

## Outcome

Player selects AI difficulty (Easy / Hard) in Settings. Easy uses RandomAI; Hard uses GreedyAI. Setting persists across sessions.

---

## Steps

| Step | Task | Validation |
|------|------|-------------|
| 1 | Create `AIStrength` enum (easy, hard) in AIController.swift or new file | Compile |
| 2 | Add `aiStrength: AIStrength` to SettingsManager (key `aiStrength`, default .hard) | Unit test: set .easy, read .easy |
| 3 | Add Picker or SegmentedControl to SettingsView under AI section | Manual: change, persist |
| 4 | GameScene.didMoveToView: `aiController = SettingsManager.shared.aiStrength == .easy ? RandomAI() : GreedyAI()` | Manual: Easy = random moves; Hard = greedy |
| 5 | GameView startNewGame() recreates scene; scene reads fresh setting | Restart game with new setting applied |

---

## Integration points

| Component | Change |
|-----------|--------|
| AIController (or new) | `enum AIStrength { case easy, hard }` |
| SettingsManager | `aiStrength: AIStrength` with UserDefaults; RawRepresentable if needed |
| SettingsView | Picker("AI difficulty", selection: $settings.aiStrength) |
| GameScene | Replace `aiController = GreedyAI()` with conditional from SettingsManager |

---

## Rollback

Remove aiStrength; GameScene reverts to `aiController = GreedyAI()`.

---

## Confidence

| | Value | Note |
|---|-------|------|
| **Confidence (root cause)** | 98% | RandomAI and GreedyAI exist; only wiring missing |
| **Confidence (solution path)** | 95% | Matches aiDelaySeconds pattern |
