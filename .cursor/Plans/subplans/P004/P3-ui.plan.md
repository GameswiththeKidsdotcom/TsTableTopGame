# P004 P3 — Power-up UI

## Next hand off (cut & paste)

**P004 P3 — UI.** Plan: [P004-power-up.plan.md](.cursor/Plans/subplans/P004/P004-power-up.plan.md). Sub-plan: [P3-ui.plan.md](.cursor/Plans/subplans/P004/P3-ui.plan.md). Builder: Extend GameStateDisplay with power-up fields; GameScene exposes tryPurchasePowerUp/tryUsePowerUp; HUDOverlay shows purchase and use buttons. UI-Test checkpoint after P3.

---

## Outcome

HUD shows purchase buttons (when no power-up, cash sufficient) and use button (when power-up held). Taps invoke GameScene methods.

## Steps

| Step | Task | Validation |
|------|------|------------|
| P3a | GameStateDisplay: add powerUpHeld0, powerUpHeld1 (PowerUpType?). GameScene pushStateToDisplay includes these | Display updates |
| P3b | GameScene: add `func tryPurchasePowerUp(_ type: PowerUpType) -> Bool` and `func tryUsePowerUp() -> Bool` forwarding to gameState | Callable from outside |
| P3c | HUDOverlay: add `scene: GameScene?`; when display.phase != .gameOver and scene != nil, show purchase buttons (disabled if cash < cost or power-up held) and use button (when power-up held) | Manual: buttons appear, tap works |
| P3d | GameView: pass `scene` to HUDOverlay | HUD receives scene |

## Detailed design

**GameStateDisplay** – Add `@Published var powerUpHeld0: PowerUpType?` and `powerUpHeld1`. Update in `update(...)` from gameState (need GameScene to pass these; GameScene gets from gameState).

**GameScene** – `pushStateToDisplay` currently gets cash, nextCapsule, phase. Add `powerUpHeld0: gameState.powerUpHeld[0]`, `powerUpHeld1: gameState.powerUpHeld[1]`. GameStateDisplay needs new update overload or extra params. Check current signature: `update(currentPlayerIndex:cash:nextCapsule:phase)`. Add `powerUpHeld: [PowerUpType?]` or `powerUpHeld0`, `powerUpHeld1`.

**HUDOverlay** – `init(display: GameStateDisplay, scene: GameScene?)`. When `scene != nil` and not game over: if current player has no power-up, show "Clear Row (3$)", "Send Garbage (2$)", "Double Cash (2$)" — disable if cash < cost. If current player has power-up, show "Use [PowerUpName]". On tap, call `scene?.tryPurchasePowerUp(.clearRow)` or `scene?.tryUsePowerUp()`.

**GameView** – `HUDOverlay(display: stateDisplay, scene: scene)`. Scene is in scope in body.

## Best route

1. Extend GameStateDisplay and GameScene pushStateToDisplay.
2. Add GameScene tryPurchasePowerUp and tryUsePowerUp.
3. Add scene param to HUDOverlay; add buttons conditionally.
4. GameView passes scene.

## Validation

- Manual: tap Buy Clear Row with $3+ → power-up held; tap Use → effect (after P2).
- UI-Test: Add accessibility identifiers: `powerUpBuyClearRow`, `powerUpBuySendGarbage`, `powerUpBuyDoubleCash`, `powerUpUseButton`. XCUITest can tap. See [P004-step2-test-and-infra.md](P004-step2-test-and-infra.md).

## Rollback

Remove HUD buttons; revert GameStateDisplay and HUDOverlay params. GameScene wrappers harmless.

## Confidence

| | Value | Note |
|---|-------|------|
| **Confidence (root cause)** | 90% | UI needs are clear; GameView/scene pattern exists |
| **Confidence (solution path)** | 92% | Wiring is explicit; HUD layout may need refinement for small screens |

## Step 5 Fidelity

| Agent | Status |
|-------|--------|
| Investigator | Chunk validated; scene param and button wiring clear |
| ui-test | E2E purchase/use flow, accessibility ids, viewport matrix in P004-step2-test-and-infra |
| logic-test | UI invokes logic; no new logic in P3 |
| infrastructure | Zero impact |
