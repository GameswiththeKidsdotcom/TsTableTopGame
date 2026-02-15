# Features for Planner – Elaborated

This document elaborates features for the **Planner agent** ([planner.md](../agents/planner.md)) to decompose into Master-Plan chunks. When invoked to create or refine plans, use this document for feature scope, feature → object maps, confidence, validation, and rollback. Invoke **Investigator** for 90%+ confidence before advancing plans to Validated. Delegate **Logic-Test** and **UI-Test** at appropriate checkpoints. It incorporates Investigator rigor (confidence, validation, rollback), ideation approaches where useful, and Blaster scope constraints.

**Scope:** TableTopGame – Dr. Mario–style head-to-head (2 players), single-device, offline-only. Blaster scope: 2 boards, 2 avatars, 1 human vs 1 AI; Human vs Human requires multi-device (out of scope for v1).

**Source:** Spec vs implementation gap assessment, [docs/SPEC.md](../../docs/SPEC.md), [blaster.md](../agents/blaster.md), [Investigator.md](../agents/Investigator.md), [ideation.md](../agents/ideation.md).

---

## P006 – Spec gap features (new plan)

### P006-G1: Level selection UI

| Aspect | Elaboration |
|--------|-------------|
| **Feature** | Player chooses game difficulty/level before starting; virus count follows `min(4 + level × 2, 50)`. |
| **User value** | More control; harder games with more viruses. |
| **Objects** | `GameState(level:)` exists; `virusCount(level:)` correct. Need: `SettingsManager` or game-start flow for level; `MenuView` or pre-game picker; `GameScene`/`GameView` to pass level into `GameState` init. |
| **Feature → object map** | Level picker UI → MenuView or New Game modal; level storage → SettingsManager (persist) or passed at game start (ephemeral); game init → GameView/GameScene passes level to `GameState(level:)`. |
| **Validation** | Unit test: level N yields `virusCount(N)` viruses per grid. Manual: pick level 5, start game, count viruses (expect 14). |
| **Rollback** | Keep `GameState(level: 0)` default; remove picker UI. |
| **Confidence (root cause)** | 98% — SPEC explicitly states virus count per level; model supports it. |
| **Confidence (solution path)** | 95% — UI + pass-through is straightforward. |

**Ideation (3 approaches):**

1. **Quick MVP:** Level picker on MenuView (stepper 0–10); stored in SettingsManager; passed to GameView → GameScene → GameState. Single place, persist.
2. **Scalable:** New Game modal with level + optional future options (AI strength); ephemeral per game.
3. **Innovative:** Level as "Difficulty" labels (Easy=0, Medium=5, Hard=10) with numeric under the hood.

**Recommendation:** Quick MVP. Smallest change; aligns with existing SettingsManager pattern.

---

### P006-G2: AI strength / difficulty

| Aspect | Elaboration |
|--------|-------------|
| **Feature** | Player chooses AI difficulty (Easy / Hard) when playing vs AI. Easy = RandomAI; Hard = GreedyAI. |
| **User value** | Accessibility for new players; challenge for experienced. |
| **Objects** | `RandomAI`, `GreedyAI` exist. Need: `SettingsManager.aiStrength` (e.g. enum Easy/Hard); `SettingsView` picker; `GameScene` reads setting and instantiates correct `AIController` at game start. |
| **Feature → object map** | AI strength setting → SettingsManager; UI → SettingsView (Picker or SegmentedControl); game setup → GameScene.didMoveToView reads `SettingsManager.shared.aiStrength` and sets `aiController = aiStrength == .easy ? RandomAI() : GreedyAI()`. |
| **Validation** | Unit test: SettingsManager round-trip. Manual: set Easy, play; observe random-like moves; set Hard, observe match-seeking. |
| **Rollback** | Remove aiStrength; GameScene reverts to `GreedyAI()`. |
| **Confidence (root cause)** | 98% — Both AI types exist; only wiring missing. |
| **Confidence (solution path)** | 95% — SettingsManager + GameScene init is clear. |

**Ideation (3 approaches):**

1. **Quick MVP:** SettingsManager `aiStrength: AIStrength` (enum); SettingsView Picker; GameScene reads at init. Persist.
2. **Scalable:** Add third tier (e.g. Medium = mix or delayed Greedy); extend enum.
3. **Innovative:** AI strength on New Game flow only (ephemeral per game) so Settings stay global (sound, delay) while game-specific (AI strength) is per session.

**Recommendation:** Quick MVP. Matches existing AI delay pattern in Settings.

---

### P006-G3: ContentView cleanup (legacy)

| Aspect | Elaboration |
|--------|-------------|
| **Feature** | Remove or document ContentView; ensure single path through GameView. |
| **User value** | Reduced confusion; no dead code. |
| **Objects** | `ContentView` (legacy); `GameView` (canonical); `RootView` uses GameView. TableTopGameApp → RootView. ContentView used only in `#Preview`. |
| **Feature → object map** | Cleanup → Delete ContentView or add comment "Preview only; production path is GameView via RootView." |
| **Validation** | Build passes; `#Preview` for GameView if ContentView removed; E2E unchanged. |
| **Rollback** | Restore ContentView from git. |
| **Confidence (root cause)** | 95% — ContentView is duplicate code path. |
| **Confidence (solution path)** | 95% — Remove or document is trivial. |

**Recommendation:** Add `// MARK: - Preview only; production uses GameView via RootView` and ensure GameView has its own `#Preview`. Defer delete to avoid breaking previews unless explicitly desired.

---

## P002 – Gravity animation (existing plan; elaboration)

| Aspect | Elaboration |
|--------|-------------|
| **Feature** | Pips drop visibly (animated) when matches cleared; cascades step-by-step. |
| **Objects** | GravityEngine (delta API), GameState (step-wise resolution), GameScene (cell cache + SKAction). See [P002-gravity-animation.plan.md](P002/P002-gravity-animation.plan.md). |
| **Blaster scope** | Same head-to-head; both grids animate. |
| **Validation** | Logic-Test after G2; UI-Test after G3. |
| **Confidence** | Root 95%; solution 90%. |

---

## P003 – AI animated drop (existing plan; elaboration)

| Aspect | Elaboration |
|--------|-------------|
| **Feature** | AI capsule drops row-by-row (visible) instead of instant. |
| **Objects** | GameState place-only API; GameScene two-phase AI (place then animate). See [P003-ai-animated-drop.plan.md](P003/P003-ai-animated-drop.plan.md). |
| **Blaster scope** | 1 AI opponent only. |
| **Validation** | Manual; watch AI board. |
| **Confidence** | Root 95%; solution 92%. |

---

## P004 – Power-up system (existing planner review; elaboration)

| Aspect | Elaboration |
|--------|-------------|
| **Feature** | Purchase with cash; hold 1; Clear Row, Send Garbage, Double Cash; AI same rules. |
| **Objects** | PowerUpType, GameState (powerUpHeld, tryPurchasePowerUp, tryUsePowerUp), GridState (clearRow, lowestFullRow), AISnapshot extended, HUDOverlay. See [P004-power-up-planner-review.md](P004/P004-power-up-planner-review.md). |
| **Blaster scope** | 2 players; both can use power-ups. |
| **Validation** | Logic-Test after P2; UI-Test after P3. |
| **Confidence** | Pending Investigator. |

---

## P005 – Monetization (existing plan; elaboration)

| Aspect | Elaboration |
|--------|-------------|
| **Feature** | StoreKit 2 IAP; free = ads after win; paid = no ads, power-up anytime (when P004 exists). |
| **Objects** | IAPManager, PaywallView, AdManager, StoreKit Configuration. See [P005-monetization.plan.md](P005/P005-monetization.plan.md). |
| **Blaster scope** | No change to head-to-head. |
| **Validation** | M4 StoreKit testing; manual Sandbox. |
| **Confidence** | Pending Investigator. |

---

## P001-C11 – App Store prep (existing; remaining chunks)

| Chunk | Outcome | Status |
|-------|---------|--------|
| A3 | ASC setup | Runbook ready; human executes |
| A4 | Screenshots | Pending |
| A5 | Upload/submit | Pending |

---

## Cross-cutting: validation strategy (Investigator)

For each new chunk:

1. **Root cause confidence ≥90%** before build.
2. **Solution path confidence ≥90%** with steps, rollback, validation.
3. **Logic-Test delegation** for game logic changes.
4. **UI-Test delegation** for UI/flow changes.
5. **Rollback** documented per chunk.

---

## Priority recommendation (Master-Plan alignment)

| Rank | Plan | Rationale |
|------|------|-----------|
| 1 | P002 G1 | Gravity delta API; blocks G2–G4. |
| 2 | P001-C11 A3–A5 | App Store compliance. |
| 3 | P006 G1+G2 | Spec gaps; small, high user value. |
| 4 | P003 | AI UX improvement. |
| 5 | P006 G3 | Low priority; code cleanup. |
| 6 | P004 | Power-ups; depends on product decision. |
| 7 | P005 | Monetization; depends on P001-C11, P004. |
