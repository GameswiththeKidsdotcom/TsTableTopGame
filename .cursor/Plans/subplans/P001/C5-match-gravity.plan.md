# C5 – Match and Gravity

**Outcome**: Placements trigger clears; pieces fall; chain reactions. Depends on C4.

---

## Steps

| Step | Task | Validation |
|------|------|------------|
| 1 | Define fixtures (empty, single4H, single4V, chain, disconnectedHalf, topOut, simultaneousClear, fullBoard); docs/FIXTURES.md + Fixtures.swift | Fixtures documented |
| 2 | Match detection (4-in-a-row H/V) | Unit test with fixtures |
| 3 | Clear logic (remove matched, disconnect halves) | Unit test |
| 4 | Gravity (unsupported pieces fall) | Unit test |
| 5 | Resolution loop (clear → gravity → repeat until stable) | Unit test |
| 6 | Chain reaction handling; no invalid grid (orphans, overlaps) | Unit test |

---

## Validation

- Placements trigger clears; pieces fall
- Logic-test: resolution never produces invalid grid

---

## Rollback

Revert to C4; disable resolution.

---

## Confidence

| | Value | Note |
|---|-------|------|
| **Confidence (root cause)** | 90% | Match (4-in-a-row H/V), gravity, and resolution loop are specified; fixture set is named and documented. |
| **Confidence (solution path)** | 88% | Fixtures, detection, clear, gravity, loop, and chain step are sufficient. Gap: "disconnect halves" and orphan rules may need clarification during build; rollback clear. |
