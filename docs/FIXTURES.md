# Grid Fixtures for Match and Gravity Tests

Fixtures used by unit tests for C5 (Match and Gravity).

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
