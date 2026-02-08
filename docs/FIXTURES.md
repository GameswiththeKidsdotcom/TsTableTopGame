# Grid Fixtures for Match and Gravity Tests

Fixtures used by unit tests for C5 (Match and Gravity).

---

## How to move the pill (simulation)

When testing in the iOS Simulator or on device, the pill (capsule) is controlled by tap/click **inside the active player’s board** (the grid with the yellow highlight). Taps outside the active board are ignored.

| Tap/click location (within active board) | Action |
|------------------------------------------|--------|
| **Left 25% of board width** | Move pill **left** |
| **Right 25% of board width** | Move pill **right** |
| **Top 20% of board height** | **Hard drop** |
| **Else** (middle 50% width, below top band) | **Rotate** (clockwise) |

- **Simulator:** One mouse click = one tap. Click inside the highlighted board only.
- The pill also auto-drops every ~0.5 seconds.
- The two boards never overlap; each fits in its half of the screen.

| Fixture | Description |
|---------|-------------|
| empty | No pieces on grid |
| single4H | Single horizontal 4-in-a-row (same color) |
| single4V | Single vertical 4-in-a-row |
| chain | Match clears, gravity causes chain |
| disconnectedHalf | Clearing disconnects half of a pill |
| topOut | Board full to top (game over) |
| simultaneousClear | Multiple matches clear at once |
| fullBoard | All cells occupied |

---

## Coordinate System

- Origin: top-left
- Row 0: spawn row (top)
- Cols 0–7, Rows 0–15
- Row increases downward
