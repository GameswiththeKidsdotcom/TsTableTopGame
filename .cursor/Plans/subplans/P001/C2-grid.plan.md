# C2 – Grid on Screen

**Outcome**: Empty 8×16 grid renders in simulator. Depends on C1.

---

## Steps

| Step | Task | Validation |
|------|------|------------|
| 1 | Define PillColor (Red, Blue, Yellow); Grid (8×16); Capsule (4 orientations, bottom-left pivot); Virus; Player | Unit tests pass |
| 2 | Create GameScene with empty grid background | Visual check |
| 3 | Render grid cells (empty state) | Visual check |
| 4 | Integrate GameScene via SpriteView in ContentView | Simulator shows empty grid |

---

## Validation

- Unit tests pass for models
- Simulator shows 8×16 grid (outline or cells)

---

## Rollback

Remove SpriteView; fall back to C1 ContentView.

---

## Confidence

| | Value | Note |
|---|-------|------|
| **Confidence (root cause)** | 92% | Grid requirement and 8×16 spec are explicit in SPEC; outcome is unambiguous. |
| **Confidence (solution path)** | 90% | Steps 1–4 sufficient; step 1 bundles five models (PillColor, Grid, Capsule, Virus, Player) but scope is bounded; rollback clear. |
