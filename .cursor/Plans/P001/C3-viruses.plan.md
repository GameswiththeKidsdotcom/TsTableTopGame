# C3 – Viruses Visible

**Outcome**: Grid shows colored viruses. Depends on C2.

---

## Steps

| Step | Task | Validation |
|------|------|------------|
| 1 | Render viruses in grid cells (PillColor → cell color) | Visual check |
| 2 | Virus init: random placement, balanced colors (or hardcoded fixture for demo) | Simulator shows viruses |

---

## Validation

- Simulator shows grid with colored viruses (Red, Blue, Yellow)

---

## Rollback

Hide virus rendering; show empty grid.

---

## Confidence

| | Value | Note |
|---|-------|------|
| **Confidence (root cause)** | 88% | Virus display clear; virus init is "random or hardcoded fixture" — count/formula live in SPEC but not referenced here. Gap: tie step 2 to virus count formula. |
| **Confidence (solution path)** | 90% | Two steps (render + init) are sufficient to get viruses on grid; dependency on C2 explicit; rollback clear. |
