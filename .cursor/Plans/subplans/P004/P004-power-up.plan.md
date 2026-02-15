# P004 – Power-up System

## Next hand off (cut & paste) — Lane A

**P004 P1 — Model and stubs.** Plan: [P004-power-up.plan.md](.cursor/Plans/subplans/P004/P004-power-up.plan.md). Sub-plan: [P1-model.plan.md](.cursor/Plans/subplans/P004/P1-model.plan.md). Builder: Create `PowerUpType.swift`; add `powerUpHeld`, `doubleCashNextLockForPlayer` to GameState with `tryPurchasePowerUp`/`tryUsePowerUp` stubs; add `GridState.clearRow` and `lowestFullRow`. Unit test: purchase with sufficient cash succeeds and deducts. Investigator: validate P004 plan for 90%+ confidence before implementation. Expected: Model in place; purchase stub works; no UI yet.

---

## Scope

Power-ups: purchase with cash, hold 1 per player, three types (Clear Row, Send Garbage, Double Cash). AI uses same rules. Head-to-head: 2 players, 2 boards.

## Chunks

| Chunk | Outcome | Sub-plan |
|-------|---------|----------|
| P1 | Model and stubs | [P1-model.plan.md](P004/P1-model.plan.md) |
| P2 | Effects (Clear Row, Send Garbage, Double Cash) | [P2-effects.plan.md](P004/P2-effects.plan.md) |
| P3 | UI (HUD, purchase/use buttons) | [P3-ui.plan.md](P004/P3-ui.plan.md) |
| P4 | AI purchase/use | [P4-ai.plan.md](P004/P4-ai.plan.md) |
| P5 | Tests | [P5-tests.plan.md](P004/P5-tests.plan.md) |

## Planner / Blaster review summary

**Planner:** Chunk structure correct; P1–P5 decomposed with clear outcomes; cut-and-paste prompts present; test delegation (Logic-Test after P2, UI-Test after P3) documented.

**Blaster:** Head-to-head scope (2 players, 2 boards) satisfied. All sections ≥90% after Investigator fixes.

**Investigator fixes applied:**
- **P2 Clear Row:** `resolveLoop` exits when no matches; `clearRow` creates a gap with no matches. Added `while GravityEngine.apply(to: &grid) { }` before `resolveLoop`.
- **P1 tryUsePowerUp stub:** Stub consumes when held (clear powerUpHeld, return true); no effect. Enables P1 tests for consume path.
- **P4 AI:** One action per frame to avoid turn-skip; explicit order: use → purchase → move.

## Section confidence (Investigator Step 1)

| Section | Confidence (root cause) | Confidence (solution path) | Note |
|---------|-------------------------|----------------------------|------|
| Purchase flow | 95% | 92% | Cash exists; guards clear; deduct-and-assign is straightforward |
| Use flow | 92% | 90% | GridState/GameState integration points verified; P002 resolution flow requires Double Cash in advanceResolutionStep |
| UI wiring | 90% | 92% | GameView has scene; HUDOverlay needs scene param; GameScene exposes wrappers |
| AI integration | 90% | 88% | AISnapshot extensible; GreedyAI heuristic needs tuning |

**Gate: All sections ≥90%. Proceed to Step 2.**

## Rollback strategy

- P1–P5 are additive. Remove PowerUpType, GameState/GridState changes, UI wiring, AI extensions. Gate behind flag if partial rollback needed.
- If Double Cash breaks resolution: revert resolutionDoubleCash logic; keep Clear Row and Send Garbage.

## Validation strategy

- Unit: purchase guards, use effects, Double Cash doubles virus cash.
- Logic-Test: state invariants after P2.
- UI-Test: HUD buttons, purchase/use flow after P3.
- Manual: play vs AI; observe power-up use.

## Step 2: Test and infrastructure plans

See [P004-step2-test-and-infra.md](P004/P004-step2-test-and-infra.md):

- **UI-Test:** E2E purchase/use flow; accessibility identifiers (powerUpBuyClearRow, powerUpBuySendGarbage, powerUpBuyDoubleCash, powerUpUseButton); viewport matrix (iPhone SE, 15 Pro Max, iPad Pro 11).
- **Logic-Test:** Invariants (powerUpHeld at most one, cash non-negative, guards); edge cases (resolution, no full row, opponent eliminated).
- **Infrastructure:** Zero impact. No new persistence, env, or services. CI unchanged; add PowerUpTests to scheme.

## Step 3: Investigator reconcile

Plan updated to incorporate test and infra outcomes. P2 (Effects) and P3 (UI) sub-plans reference the test plan. P5 (Tests) notes infrastructure zero impact and scheme inclusion. No plan changes required; confidence unchanged (92% / 90%).

## Step 4: Planner chunking

Confirmed. P1–P5 sub-plans exist with full content, Confidence sections, and cut-and-paste prompts at top. Main plan is short index. Chunk dependency order: P1 → P2 → P3 | P4; P5 after P2 (logic) and P3 (UI).

## Step 5: Per-chunk fidelity

All chunks passed fidelity check. Fidelity table added to each sub-plan.

**Investigator fixes applied (2025):** P2 Clear Row — added gravity loop before resolveLoop (resolveLoop exits when no matches; clearRow creates hole with no matches). P1 tryUsePowerUp stub — clarified: consume when held, return true. P4 — documented one-action-per-frame pattern. All chunks now ≥90% confidence.
