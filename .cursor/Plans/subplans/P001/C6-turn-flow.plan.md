# C6 – Turn Flow (2 Players First)

**Outcome**: Turns alternate; win/elimination trigger. Start with 2 players. Depends on C5.

---

## Steps

| Step | Task | Validation |
|------|------|------------|
| 1 | Turn order (Human=Player 0 first); spawn → place → resolve → effects → next | Unit test |
| 2 | Virus init; capsule queue (current + next 1–2) | Unit test |
| 3 | Win: first to clear; elimination: top-out; last standing | Unit test |
| 4a | Skip eliminated player when advancing turn | Unit test |
| 4b | Single player left → game over, winner | Unit test |
| 4c | Win-on-clear (first to clear all viruses) | Unit test |
| 4d | Tie (cash tiebreaker or shared win) | Unit test |
| 5 | Logic-test: no dead-end (turn always advances or game ends) | Unit test |

---

## Validation

- 2-player game: turns alternate; win/elimination work

---

## Rollback

Revert to C5: disable win/elimination and tie logic; turn loop alternates only, no game-end. Optionally stub WinConditionChecker so game never ends.

---

## Confidence

| | Value | Note |
|---|-------|------|
| **Confidence (root cause)** | 92% | Turn order (Player 0 first), win/elimination, and head-to-head flow are clear and aligned with SPEC. |
| **Confidence (solution path)** | 90% | Rollback is C6-scoped (revert to C5, stub WinConditionChecker). Step 4 split into 4a–4d (skip eliminated, single-player-left, win-on-clear, tie) for testability; steps 1–5 cover turn order and edge cases. |
