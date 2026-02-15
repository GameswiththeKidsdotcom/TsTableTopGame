---
name: P005 M6 Power-up Anytime Gating
overview: Paid users can buy power-ups anytime; free users only during turn with in-game cash. Integrates with P004.
---

**Next hand off (cut & paste)**: **P005 M6 — Power-up gating.** [M6-powerup-gating.plan.md](.cursor/Plans/subplans/P005/M6-powerup-gating.plan.md). Investigator: validate M6 for 90%+ confidence. Builder: Gate power-up purchase availability on hasPremium. Paid: can buy anytime (with in-game cash). Free: only during turn when eligible (P004 standard).

---

## Outcome

| Tier | Power-up purchase |
|------|------------------|
| **Paid** | Can buy power-up **any time** (persistent button or no turn restriction) |
| **Free** | Only during own turn when cash >= cost (P004 standard flow) |

---

## Strategy (from main plan)

Paid unlock = "power-ups anytime". Free = turn-only with in-game cash.

---

## Steps

1. **P004 dependency**  
   - This chunk requires [P004 Power-up System](.cursor/Plans/subplans/P004/P004-power-up-planner-review.md) to be built.  
   - P004 defines: tryPurchasePowerUp, powerUpHeld, cash, turn flow.  
   - M6 adds entitlement gating on top.

2. **Define "anytime" for paid**  
   - **Option A**: Paid users see a persistent "Buy Power-up" in HUD/menu; can tap even when not their turn (purchases for next eligible use).  
   - **Option B**: Paid users can tap purchase during opponent's turn (queue for own turn).  
   - **Option C**: Paid users have no "must be your turn" check — only cash check.  
   - Recommendation: Option C — remove turn restriction for paid; free keeps full P004 rules (turn + cash).

3. **Implement gating in GameState or GameScene**  
   - Where tryPurchasePowerUp is called, add:  
     - If hasPremium: allow purchase when cash >= cost (ignore turn for "anytime" — e.g. allow from settings/menu, or allow during opponent turn)  
     - If !hasPremium: require current player's turn AND cash >= cost (P004 standard)  
   - Expose `canPurchasePowerUpAnytime: Bool` = hasPremium for UI to show/hide purchase affordance

4. **HUD/UI changes**  
   - Paid: Show purchase button whenever cash >= cost (even during AI/opponent turn?). Clarify UX.  
   - Free: Show purchase button only during own turn when cash >= cost.  
   - Simpler: Paid = purchase always visible when affordable; Free = purchase only during turn when affordable.

5. **Unit test**  
   - Free user, not their turn: tryPurchasePowerUp fails  
   - Paid user, not their turn: tryPurchasePowerUp succeeds (if cash OK)  
   - Both: cash insufficient → fail

---

## Dependencies

- M1 complete (IAPManager.hasPremium)
- P004 power-up system built (GameState.tryPurchasePowerUp, etc.)

---

## Technical Detail

- **Gate**: `IAPManager.shared.hasPremium` determines "anytime" vs "turn-only".  
- **GameState**: Add optional param or check inside tryPurchasePowerUp: `if !iapManager.hasPremium && !isCurrentPlayerTurn { return false }`  
- **Integration point**: [GameScene](TableTopGame/GameScene.swift) or [GameState](TableTopGame/Models/GameState.swift) — depends on P004 structure.

---

## Validation

- Logic-Test: Free, opponent turn, sufficient cash → purchase fails  
- Logic-Test: Paid, opponent turn, sufficient cash → purchase succeeds  
- Manual: Play as free vs paid; verify purchase button visibility/eligibility

---

## Rollback

Remove entitlement check from tryPurchasePowerUp; revert to P004-only behavior (turn + cash for all).

---

## Confidence

| | % |
|---|---|
| Confidence (root cause) | 90% |
| Confidence (solution path) | 85% |

**Note**: Depends on P004 design. "Anytime" UX (when exactly can paid user tap?) needs product decision. Investigator to align with P004 sub-plans.
