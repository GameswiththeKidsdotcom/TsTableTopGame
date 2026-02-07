# C9 – AI Opponents

**Outcome**: 1 AI + 1 human play full game (head-to-head). Depends on C8.

---

## Steps

| Step | Task | Validation |
|------|------|------------|
| 1 | AIController interface (receive game state, return move) | Unit test with mock |
| 2 | Random AI (valid column + rotation) | Unit test |
| 3 | Greedy AI (prefer immediate matches) | Unit test |
| 4 | Integrate AI into turn loop with delay (~1–2 sec) | Manual test |
| 5 | Assign strategy to the single AI player (opponent) | Manual test |
| 6 | AI contract: full-board returns top-out (no crash); every move legal | Unit test |

---

## Validation

- 1 AI + 1 human play (head-to-head); AI moves automatically

---

## Rollback

Replace AI with human-controlled test mode.

---

## Confidence

| | Value | Note |
|---|-------|------|
| **Confidence (root cause)** | 90% | Single AI opponent (1 human + 1 AI) and AI contract (full-board → top-out, every move legal) are clear. |
| **Confidence (solution path)** | 88% | AIController interface, Random, Greedy, integration, and contract steps are sufficient. Gap: "prefer immediate matches" for Greedy is underspecified; refine during implementation if needed. |
