# C9 – AI Opponents

**Outcome**: 5 AI + 1 human play full game. Depends on C8.

---

## Steps

| Step | Task | Validation |
|------|------|------------|
| 1 | AIController interface (receive game state, return move) | Unit test with mock |
| 2 | Random AI (valid column + rotation) | Unit test |
| 3 | Greedy AI (prefer immediate matches) | Unit test |
| 4 | Integrate AI into turn loop with delay (~1–2 sec) | Manual test |
| 5 | Assign strategies to 5 AI players | Manual test |
| 6 | AI contract: full-board returns top-out (no crash); every move legal | Unit test |

---

## Validation

- 5 AI + 1 human play; AI moves automatically

---

## Rollback

Replace AI with human-controlled test mode.
