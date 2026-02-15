# P004 P4 — AI Power-up Integration

## Next hand off (cut & paste)

**P004 P4 — AI.** Plan: [P004-power-up.plan.md](.cursor/Plans/subplans/P004/P004-power-up.plan.md). Sub-plan: [P4-ai.plan.md](.cursor/Plans/subplans/P004/P4-ai.plan.md). Builder: Extend AISnapshot with cash, powerUpHeld, opponentEliminated; add usePowerUpBeforeMove and purchase logic to GreedyAI; GameScene AI turn calls use then purchase then move.

---

## Outcome

AI buys and uses power-ups with same rules as human. Purchase when cash sufficient and no power-up; use before move when beneficial.

## Steps

| Step | Task | Validation |
|------|------|------------|
| P4a | AISnapshot: add cash: Int, powerUpHeld: PowerUpType?, opponentEliminated: Bool | aiSnapshotForCurrentPlayer populates these |
| P4b | AIController: add `usePowerUpBeforeMove(for snapshot: AISnapshot) -> PowerUpType?` | Protocol extension |
| P4c | GreedyAI: implement usePowerUpBeforeMove – Clear Row if lowestFullRow != nil; Send Garbage if !opponentEliminated; Double Cash if best placement clears >= 2 viruses | Heuristic |
| P4d | GreedyAI: add purchase decision – if no power-up, cash >= 2: buy Clear Row if cash >= 3, else Send Garbage | Heuristic |
| P4e | GameScene update: when AI turn, (1) if power-up held and usePowerUpBeforeMove returns type, call tryUsePowerUp; (2) if no power-up and cash >= 2, call tryPurchasePowerUp for chosen type; (3) call move/applyAIMove | AI uses power-ups |

## Detailed design

**AISnapshot** – Add `cash: Int` (current player's cash), `powerUpHeld: PowerUpType?`, `opponentEliminated: Bool`. GameState.aiSnapshotForCurrentPlayer fills from cash[currentPlayerIndex], powerUpHeld[currentPlayerIndex], eliminated.contains(opponent).

**usePowerUpBeforeMove** – Returns the type to use, or nil. GreedyAI: if powerUpHeld == .clearRow and grid has lowestFullRow, return .clearRow; if .sendGarbage and !opponentEliminated, return .sendGarbage; if .doubleCash and PlacementScorer best score >= 2, return .doubleCash. Else nil.

**Purchase** – Before move, if powerUpHeld == nil and cash >= 2: if cash >= 3, tryPurchasePowerUp(.clearRow); else tryPurchasePowerUp(.sendGarbage). (Double Cash is situational; defer or add later.)

**GameScene order** – One logical action per frame to avoid turn-skip bugs: (1) guard canAcceptInput; (2) if power-up held and usePowerUpBeforeMove returns type → tryUsePowerUp, layoutGrid, return; (3) if no power-up and cash >= 2 → tryPurchasePowerUp, layoutGrid, return; (4) else applyAIMove. Re-check canAcceptInput on next frame.

## Best route

1. Extend AISnapshot and GameState.aiSnapshotForCurrentPlayer.
2. Add usePowerUpBeforeMove to protocol and GreedyAI.
3. Add purchase helper in GreedyAI or GameScene.
4. GameScene update loop: use, purchase, move.

## Validation

- Play vs AI; earn cash; observe AI buying when $2+.
- Observe AI using Clear Row when bottom row full.

## Rollback

Revert AISnapshot, AIController, GreedyAI, GameScene. AI falls back to current behavior.

## Confidence

| | Value | Note |
|---|-------|------|
| **Confidence (root cause)** | 90% | AI needs snapshot data and decision hooks |
| **Confidence (solution path)** | 90% | One action per frame pattern documented; heuristics tunable |

## Step 5 Fidelity

| Agent | Status |
|-------|--------|
| Investigator | Chunk validated; heuristic scope documented; turn-order risk noted |
| ui-test | Manual: play vs AI, observe power-up use |
| logic-test | AI uses same rules as human; invariants apply |
| infrastructure | Zero impact |
