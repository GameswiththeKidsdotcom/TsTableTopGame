# C6 – Turn Flow (2 Players First)

**Outcome**: Turns alternate; win/elimination trigger. Start with 2 players. Depends on C5.

---

## Steps

| Step | Task | Validation |
|------|------|------------|
| 1 | Turn order (Human=Player 0 first); spawn → place → resolve → effects → next | Unit test |
| 2 | Virus init; capsule queue (current + next 1–2) | Unit test |
| 3 | Win: first to clear; elimination: top-out; last standing | Unit test |
| 4 | Skip eliminated; single-player-left; win-on-clear; tie (cash tiebreaker, shared win) | Unit test |
| 5 | Logic-test: no dead-end (turn always advances or game ends) | Unit test |

---

## Validation

- 2-player game: turns alternate; win/elimination work

---

## Rollback

Single-player mode.
