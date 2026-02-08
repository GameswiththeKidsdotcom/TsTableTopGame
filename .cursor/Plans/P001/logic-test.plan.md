# P001-LT – Logic-Test (User Move Validation)

**Scope**: Head-to-head (2 players). Moves, turns, phases, attack, elimination, win/tie. Ensure every allowed move is possible; no unreachable valid moves; state-machine consistency.

---

## Delegation

**Logic-Test agent** validates at checkpoints after C5, C6, C7, C8. See `.cursor/agents/logic-test.md`.

---

## Coverage by Phase

| Phase | Logic-Test Additions |
|-------|----------------------|
| C5 | Fixtures: top-out, simultaneous clear; no invalid grid |
| C6 | Turn-order; skip eliminated; single-player-left; win/tie |
| C7 - Perfected | Garbage targeting when eliminated; colors match |
| C8 | AI contract; top-out handled |

---

## Edge Cases (Must Cover)

Empty board, first turn, single-player-left (head-to-head: one winner), tie (both clear / last two top out), opponent eliminated, top-out, wall kick, chain 5+ clears, disconnected half, AI no valid move.

---

## Lose-Scenario Coverage

| Scenario | Test | Notes |
|----------|------|-------|
| WinConditionChecker: one eliminated → other wins | `testWinConditionCheckerResolveGameOverLoseScenario` | Explicit lose outcome; both directions (P0 loses, P1 loses) |
| GameState: top-out → elimination → opponent wins | `testGameStateTopOutEliminatesPlayerAndOpponentWins` | Uses `GameState(gridStatesForTest:)`; P0 topOut, P1 empty; asserts P1 wins |
| Fixture-based GameState init | `init(gridStatesForTest:capsuleQueueForTest:)` | Enables deterministic top-out and lose tests |

**UI-Test cross-reference**: E2E validation of lose scenarios (overlay shows "Player X wins!" when opponent loses) is in [P001/ui-test.plan.md](ui-test.plan.md).

**C10 Validation Chunks (Logic-Test scope)**: C10-V2 (win overlay), C10-V3 (lose overlay), C10-V4 (tie overlay), C10-V7 (settings persist), C10-V10 (Logic-test E2E). Logic-test confirmed coverage for each. See [C10-validation-chunks.plan.md](C10-validation-chunks.plan.md).

---

## Confidence

| | Value | Note |
|---|-------|------|
| **Confidence (root cause)** | 92% | Logic-test scope (moves, turns, attack, win/tie) and head-to-head scope are clear; delegation at C5–C8 checkpoints is explicit. |
| **Confidence (solution path)** | 88% | Coverage by phase and edge-case list are sufficient for checkpoints. Gap: no test implementation steps in this doc (delegation to Logic-Test agent); acceptable for plan slice. |
