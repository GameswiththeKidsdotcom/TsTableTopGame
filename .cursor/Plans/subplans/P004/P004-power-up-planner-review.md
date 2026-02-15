# Planner Review: Power-up System Plan

**Reviewed against:** [planner.md](.cursor/agents/planner.md)  
**Source plan:** power-up_system_2cc40fb5.plan.md (to become P004)

---

## 1. Scope

**Goal:** Add power-up system to TableTopGame. Players purchase with cash, hold 1 at a time, use three types (Clear Row, Send Garbage, Double Cash). AI uses same rules.

**Features:**
- Purchase power-up flow (cash → type selection)
- Use power-up flow (Clear Row, Send Garbage, Double Cash)
- Power-up HUD and buttons
- AI purchase/use decision logic

**Objects:**
- PowerUpType (enum, costs)
- GameState (powerUpHeld, doubleCashNextLockForPlayer, tryPurchasePowerUp, tryUsePowerUp, lockCapsule modification)
- GridState (clearRow, lowestFullRow)
- GameStateDisplay (power-up fields)
- AISnapshot + AIController (extended for power-up)
- GameView / HUDOverlay (purchase/use buttons)
- GameScene (expose purchase/use; AI power-up step)

---

## 2. Feature → Object Map

```
Purchase flow    → PowerUpType, GameState.tryPurchasePowerUp, GameStateDisplay, HUDOverlay, GameScene
Use flow         → GameState.tryUsePowerUp, GridState.clearRow/lowestFullRow, lockCapsule (double cash)
HUD UI           → GameStateDisplay, HUDOverlay, GameView, GameScene (wiring)
AI purchase/use  → AISnapshot, AIController, GreedyAI, GameScene update loop
```

**Dependency order:** P1 (model) → P2 (effects) → P3 (UI) | P4 (AI); P5 (tests) can run after P2 (logic tests) and P3 (UI tests).

---

## 3. Gaps vs Planner Criteria

| Criterion | Status | Required Change |
|-----------|--------|-----------------|
| Plan location | Gap | Plan file must live at `.cursor/Plans/subplans/P004/P004-power-up.plan.md` (P003 already used for AI animated drop) |
| Sub-plan structure | Gap | Split into sub-plan files under `.cursor/Plans/subplans/P004/`; main plan stays short index |
| Confidence section | Gap | Each sub-plan must have Confidence (root cause) and Confidence (solution path) |
| Next hand off prompt | Gap | Main plan and active sub-plan need cut-and-paste prompt at top |
| Investigator invocation | Gap | Before advancing to Validated, invoke Investigator for 90%+ confidence |
| Test checkpoint delegation | Gap | Explicitly delegate Logic-Test (after P2) and UI-Test (after P3) |
| GameView/GameScene wiring | Incomplete | Specify how HUD gets `gameState` ref: GameScene exposes `func tryPurchasePowerUp(_:)` and `func tryUsePowerUp() -> Bool`; GameView passes `scene` to HUDOverlay; HUD calls `scene?.tryPurchasePowerUp(type)` etc. |

---

## 4. Decomposed Steps (Per Chunk)

### P1: Model (Objects First)
- P1a: Create `PowerUpType.swift` with enum and `cost` property
- P1b: Add `powerUpHeld: [PowerUpType?]`, `doubleCashNextLockForPlayer: [Bool]` to GameState
- P1c: Add `tryPurchasePowerUp(_:) -> Bool` stub (guards only, no effect) and `tryUsePowerUp() -> Bool` stub (returns false if no power-up)
- P1d: Add `GridState.clearRow(_:)` and `lowestFullRow() -> Int?`
- **Validation:** Unit test: purchase with sufficient cash sets powerUpHeld; purchase with insufficient cash fails

### P2: Effects
- P2a: Implement Clear Row in tryUsePowerUp (lowestFullRow, clearRow, resolveLoop)
- P2b: Implement Send Garbage (2 rows to opponent via pendingGarbage)
- P2c: Implement Double Cash (set flag; in lockCapsule, double virus cash when flag set, clear flag)
- **Validation:** Unit tests per effect; Logic-Test checkpoint

### P3: UI
- P3a: Extend GameStateDisplay with powerUpHeld0, powerUpHeld1 (or powerUpHeld for current); GameScene pushStateToDisplay includes these
- P3b: GameScene exposes `func tryPurchasePowerUp(_ type: PowerUpType) -> Bool` and `func tryUsePowerUp() -> Bool` (forward to gameState)
- P3c: HUDOverlay takes optional `scene: GameScene?`; shows purchase buttons (when no power-up, cash >= cost) and use button (when power-up held)
- P3d: GameView passes `scene` to HUDOverlay; buttons call scene methods
- **Validation:** Manual or UI-Test: tap Buy Clear Row when $3+, verify power-up held; tap Use, verify row cleared

### P4: AI
- P4a: Extend AISnapshot with cash, powerUpHeld, opponentEliminated
- P4b: Add `usePowerUpBeforeMove(for:) -> PowerUpType?` to AIController; GreedyAI implements heuristic
- P4c: Add purchase step: if no power-up and cash >= 2, buy (Clear Row if >=3, else Send Garbage)
- P4d: GameScene AI turn: (1) use power-up if returns type, (2) purchase if no power-up and can afford, (3) applyAIMove
- **Validation:** Play vs AI; observe AI buying and using power-ups

### P5: Tests
- P5a: Unit tests for tryPurchasePowerUp (insufficient cash, sufficient cash, already holding)
- P5b: Unit tests for tryUsePowerUp (Clear Row, Send Garbage, Double Cash)
- P5c: Fixture-based integration test
- **Validation:** Logic-Test validates; xcodebuild test passes

---

## 5. Master-Plan Updates

**New matrix row:**

| Plan ID | Plan name | Priority rank | Description | Current state | Confidence (root cause) | Confidence (solution path) |
|---------|-----------|---------------|-------------|---------------|--------------------------|----------------------------|
| P004 | Power-up System | 6 | Purchase power-ups with cash; hold 1; Clear Row, Send Garbage, Double Cash. AI same rules. Plan: [.cursor/Plans/subplans/P004/P004-power-up.plan.md](.cursor/Plans/subplans/P004/P004-power-up.plan.md). Sub-plans: [.cursor/Plans/subplans/P004/](.cursor/Plans/subplans/P004/) (P1–P5). | Pending analysis | N/A | N/A |

**Plan file paths (create):**
- Main: `.cursor/Plans/subplans/P004/P004-power-up.plan.md` (short index)
- Sub-plans: `.cursor/Plans/subplans/P004/P1-model.plan.md`, `P2-effects.plan.md`, `P3-ui.plan.md`, `P4-ai.plan.md`, `P5-tests.plan.md`

---

## 6. Next Hand Off (Cut and Paste)

**Lane A:**

**P004 P1 — Model and stubs.** Plan: [.cursor/Plans/subplans/P004/P004-power-up.plan.md](.cursor/Plans/subplans/P004/P004-power-up.plan.md). Sub-plan: [.cursor/Plans/subplans/P004/P1-model.plan.md](.cursor/Plans/subplans/P004/P1-model.plan.md). Builder: Create `PowerUpType.swift`; add `powerUpHeld`, `doubleCashNextLockForPlayer` to GameState with `tryPurchasePowerUp`/`tryUsePowerUp` stubs; add `GridState.clearRow` and `lowestFullRow`. Unit test: purchase with sufficient cash succeeds and deducts. Investigator: validate P004 plan for 90%+ confidence before implementation. Expected: Model in place; purchase stub works; no UI yet.

**Lane B:** Empty (P004 does not conflict with P001-RestartFix; Lane B can run C11 A1 as current).

---

## 7. Checkpoint Delegation

- **After P2 (Effects):** Logic-Test agent validates purchase/use state invariants, Clear Row clears correctly, Send Garbage appends to opponent, Double Cash doubles next lock. Unit tests must pass.
- **After P3 (UI):** UI-Test agent validates HUD buttons, purchase flow in simulator, use flow. Manual or XCUITest.

---

## 8. Risks and Rollback

- **Risk:** GameView/GameScene wiring for purchase/use is ambiguous.  
  **Mitigation:** GameScene is the owner of gameState; expose thin wrappers. GameView holds `scene`; HUDOverlay receives `scene` and calls `scene?.tryPurchasePowerUp(type)` etc.
- **Risk:** AI purchase/use order could cause turn-skip bugs.  
  **Mitigation:** AI step: use power-up first (if applicable), then purchase (if applicable), then move. Use and purchase do not advance turn; only lockCapsule/advanceTurn does.
- **Rollback:** Feature is additive. Remove UI wiring and keep model; or gate behind a flag.

---

## 9. Summary of Required Plan Restructure

1. **Move plan to workspace:** `.cursor/Plans/subplans/P004/P004-power-up.plan.md` (main index only)
2. **Create sub-plan files** under `.cursor/Plans/subplans/P004/` with full content, Confidence section, and matching cut-and-paste prompt
3. **Add Confidence to each sub-plan:** Root cause N/A (new feature); Solution path 88–92% (per chunk; Investigator refines)
4. **Register P004 in Master-Plan** matrix with state Pending analysis
5. **Update Master-Plan next hand off** when P004 becomes active (or keep current Lane A until P001-RestartFix done)
