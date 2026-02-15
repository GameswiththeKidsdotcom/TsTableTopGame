---
name: P006 Spec Gaps
overview: Close gaps between docs/SPEC.md and implementation: level selection UI, AI strength setting, ContentView cleanup. Single-device head-to-head scope. Reference: features-for-planner.md.
todos: []
isProject: false
---

# P006 – Spec Gap Features

**Next hand off (cut & paste)**: **G1** (Builder): Validate — run full test suite; manual level 5 → 14 viruses; Restart same count. Plan: [P006-G1-level-selection.plan.md](P006-G1-level-selection.plan.md). If pass, commit. Next: G2.

---

## Scope

Close gaps identified in spec vs implementation assessment:
1. **Level selection** — Player chooses level (0–23); virus count follows SPEC `min(4 + level × 2, 50)`.
2. **AI strength** — Player chooses Easy (RandomAI) or Hard (GreedyAI); persists in Settings.
3. **ContentView cleanup** — Remove or document legacy ContentView; single path via GameView.

**Blaster scope:** 2 players, 2 boards, 1 human vs 1 AI. Single-device, offline-only.

---

## Feature → Object Map

| Feature | Objects | Sub-plan |
|---------|---------|----------|
| Level selection UI | SettingsManager (level), MenuView or Settings, GameView, GameScene, GameState(level:) | G1 |
| AI strength | SettingsManager (aiStrength), SettingsView, GameScene (aiController init) | G2 |
| ContentView cleanup | ContentView, GameView #Preview | G3 |

---

## Chunks

| Chunk | Outcome | Sub-plan |
|-------|---------|----------|
| **G1** | Level picker; virus count per level in game | [P006-G1-level-selection.plan.md](P006-G1-level-selection.plan.md) |
| **G2** | AI strength picker (Easy/Hard); persists | [P006-G2-ai-strength.plan.md](P006-G2-ai-strength.plan.md) |
| **G3** | ContentView documented or removed | [P006-G3-contentview-cleanup.plan.md](P006-G3-contentview-cleanup.plan.md) |

**Dependency order:** G1 and G2 independent; G3 can run in parallel (no file overlap with G1/G2).

---

## Test checkpoints

- **G1:** Logic-Test or unit test: level N yields virusCount(N) viruses.
- **G2:** Manual: set Easy vs Hard; observe AI behavior.
- **G3:** Build passes; E2E unchanged.

---

## Confidence

| Chunk | Root cause | Solution path | Note |
|-------|------------|---------------|------|
| G1 | 98% | 95% | Model supports; UI + pass-through clear |
| G2 | 98% | 95% | Both AIs exist; Settings pattern established |
| G3 | 95% | 95% | Remove or document; trivial |
