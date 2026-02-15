# P004 Step 2: Test Plans and Infrastructure

Outputs from ui-test, logic-test, and infrastructure agents for P004 Power-up.

---

## UI-Test Plan

**Scope:** E2E purchase flow, HUD buttons, use flow. Head-to-head: 2 players, 2 boards.

**Context:** TableTopGame uses XCUITest (native iOS), not Playwright. Apply ui-test principles to XCUITest.

### User journeys

1. **Purchase flow:** Launch → New Game → play until cash ≥ 3 → tap "Clear Row (3$)" (or equivalent) → verify power-up held (HUD shows use button) → tap "Use" → verify row cleared on active grid.
2. **Disabled purchase:** When cash < cost, purchase buttons disabled or not tappable.
3. **Use flow:** When power-up held, tap "Use [PowerUpName]" → effect applied (row cleared, garbage sent, or double-cash flag set).

### Viewports

- iPhone SE (3rd gen) — 375×667
- iPhone 15 Pro Max — 430×932
- iPad Pro 11 — 834×1194

Use existing P001 viewport matrix. Power-up HUD must be legible and tappable on smallest viewport.

### Accessibility identifiers (add)

- `powerUpBuyClearRow`
- `powerUpBuySendGarbage`
- `powerUpBuyDoubleCash`
- `powerUpUseButton`

### Test cases

| Test | Journey | Assertion |
|------|---------|-----------|
| testPowerUpPurchaseFlow | Play until $3+, tap Buy Clear Row | powerUpUseButton visible or power-up state shown |
| testPowerUpUseFlow | With power-up held, tap Use | Grid state changes (row cleared) or cash doubles on next drop |
| testPowerUpButtonsDisabled | Cash = 0, no power-up | Buy buttons disabled or not present |
| testPowerUpLayout | iPhone SE | HUD buttons within bounds, no overflow |

### E2E integration

Existing `testFullPlaythroughUntilGameOver` or fixture-based game-over tests unchanged. Optional: add `testPowerUpPurchaseAndUse` to full playthrough if time allows; else manual validation sufficient for v1.

---

## Logic-Test Plan

**Scope:** Purchase guards, use effects, state invariants. Head-to-head: 2 players.

### Logic map

| Action | Rules | Code path |
|--------|-------|-----------|
| tryPurchasePowerUp | canAcceptInput; no power-up held; cash ≥ cost | GameState.tryPurchasePowerUp |
| tryUsePowerUp | canAcceptInput; power-up held | GameState.tryUsePowerUp |
| Clear Row | lowestFullRow exists; consume power-up | tryUsePowerUp → GridState.clearRow → resolveLoop |
| Send Garbage | opponent not eliminated; append 2 rows | tryUsePowerUp → pendingGarbage[opponent] |
| Double Cash | set flag; next lock doubles virus cash | tryUsePowerUp → flag; advanceResolutionStep doubles |

### Invariants to validate

1. **powerUpHeld:** At most one power-up per player; nil or single PowerUpType.
2. **cash:** Non-negative; deduct on purchase; virus clears add; Double Cash adds bonus.
3. **Purchase guards:** Purchase fails when canAcceptInput false, already holding, or cash < cost.
4. **Use guards:** Use fails when no power-up or canAcceptInput false.
5. **Double Cash scope:** Applies only to virus clears in the next lock for the activating player; flag cleared after resolution.

### Edge cases

- Purchase during resolution (canAcceptInput false) → must fail.
- Use Clear Row when no full row → consume with no-op (or document if refund).
- Use Send Garbage when opponent eliminated → must not append (opponent check).
- Double Cash used, then turn advances before lock → flag persists until that player's next lock.

### Test strategy

- Unit tests per invariant (see P5 sub-plan).
- Fixture-based: deterministic grid, purchase, use, assert state.
- Logic-Test agent validates after P2 that all invariants are covered.

---

## Infrastructure Plan

**Scope:** P004 Power-up feature. Offline-first, zero cost assumed.

### Findings

| Concern | Impact | Recommendation |
|---------|--------|----------------|
| Hosting | None | No server; client-only. Zero cost. |
| Persistence | Power-up state is ephemeral (per game session) | No new persistence. Cash and power-up held in GameState; lost on game end. |
| CI/CD | New unit tests (PowerUpTests) | Existing `xcodebuild test`; add PowerUpTests to scheme. No CI change. |
| App Store | No change | Power-ups are in-game mechanic; no new entitlements or metadata. |
| Scaling | N/A | Single-device; no multi-user. |

### Conclusion

**Zero infrastructure impact.** Power-ups are fully client-side, in-memory state. No new env vars, no new storage, no new services. CI runs existing test command; PowerUpTests included when added.

### Cost

**$0.** No infrastructure cost for P004.
