# P004 P5 — Power-up Tests

## Next hand off (cut & paste)

**P004 P5 — Tests.** Plan: [P004-power-up.plan.md](.cursor/Plans/subplans/P004/P004-power-up.plan.md). Sub-plan: [P5-tests.plan.md](.cursor/Plans/subplans/P004/P5-tests.plan.md). Builder: Unit tests for purchase, use effects, Double Cash. Fixture-based integration test. Logic-Test validation.

---

## Outcome

Full test coverage for power-up logic. xcodebuild test passes.

## Steps

| Step | Task | Validation |
|------|------|------------|
| P5a | Unit tests: tryPurchasePowerUp – insufficient cash fails; sufficient succeeds and deducts; already holding fails | Tests pass |
| P5b | Unit tests: tryUsePowerUp – no power-up fails; Clear Row clears; Send Garbage appends; Double Cash doubles | Tests pass |
| P5c | Fixture test: specific grid, purchase Clear Row, use it, verify row cleared and virus/cash | Test pass |
| P5d | Logic-Test: validate state invariants (powerUpHeld at most one, cash non-negative, etc.) | Logic-Test agent sign-off |

## Detailed design

**Test file** – `TableTopGameTests/PowerUpTests.swift` or extend existing GameStateTests.

**Fixtures** – Use existing fixture patterns (gridStatesForTest, capsuleQueueForTest) to create deterministic states. Build grid with full row at known position; purchase Clear Row; use; assert row cleared.

**Double Cash** – Fixture: set doubleCashNextLockForPlayer[0]=true via test init or reflective access; place capsule that clears 2 viruses; run lockCapsule/resolution; assert cash[0] increased by 4.

## Best route

1. Add PowerUpTests with purchase tests.
2. Add use-effect tests (may need GameState test init).
3. Add fixture-based integration test.

## Validation

- `xcodebuild test` passes.
- Logic-Test agent confirms coverage.
- Add PowerUpTests to Xcode test scheme. Infrastructure: zero impact; CI unchanged.

## Rollback

Remove PowerUpTests; no impact on production.

## Confidence

| | Value | Note |
|---|-------|------|
| **Confidence (root cause)** | 95% | Test strategy is standard |
| **Confidence (solution path)** | 92% | Fixtures may need GameState test init; existing patterns exist in codebase |

## Step 5 Fidelity

| Agent | Status |
|-------|--------|
| Investigator | Chunk validated; test cases align with P004-step2-test-and-infra |
| ui-test | Tests support UI-Test E2E; identifiers added in P3 |
| logic-test | Unit and fixture tests cover invariants |
| infrastructure | Add PowerUpTests to scheme; CI unchanged |
