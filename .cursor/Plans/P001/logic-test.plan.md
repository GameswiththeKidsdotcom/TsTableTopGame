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
| C7 | Garbage targeting when eliminated; colors match |
| C8 | AI contract; top-out handled |

---

## Edge Cases (Must Cover)

Empty board, first turn, single-player-left (head-to-head: one winner), tie (both clear / last two top out), opponent eliminated, top-out, wall kick, chain 5+ clears, disconnected half, AI no valid move.
