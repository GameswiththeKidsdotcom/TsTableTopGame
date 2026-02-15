---
name: AI Animated Drop
overview: Make AI moves visible by having the AI's capsule drop row-by-row (like the human's auto-drop) instead of hard-dropping instantly. Uses the same drop interval as the human player so the user sees the AI moving pieces slowly down the grid.
todos: []
isProject: false
---

## Next hand off (cut & paste)

**P003 A1 — GameState place-only API.** Plan: [P003-ai-animated-drop.plan.md](.cursor/Plans/subplans/P003/P003-ai-animated-drop.plan.md). Builder: In [GameState.swift](TableTopGame/Models/GameState.swift), add `animateDrop: Bool = false` parameter to `applyAIMove(col:orientation:)`. When `animateDrop == true`, set capsule at spawn only (no `hardDrop()`). Default preserves existing tests. Run `xcodebuild test` before and after. Expected: `testGameStateAiSnapshotAndApplyAIMove` and all C9 tests pass. Then proceed to A2 (GameScene two-phase AI).

---

# P003: AI Animated Drop

## Scope

- **Feature**: User sees the AI moving pieces (capsule dropping row-by-row) instead of instant hard-drop.
- **Objects**: `GameState.applyAIMove`, `GameScene.update` (AI block + drop loop).

## Feature → object map

| Feature | Objects | Dependency |
|---------|---------|-------------|
| AI visible drop | GameState (place-only API) | None |
| AI visible drop | GameScene (two-phase AI, shared drop loop) | GameState A1 |

---

## Findings / Evidence

### Current Flow (root cause)

1. **AI turn in** [GameScene.swift](TableTopGame/GameScene.swift) (lines 75-85): When `currentPlayerIndex == 1`, after `aiDelay` seconds the scene calls `gameState.applyAIMove(col:orientation:)` and then **returns early** from `update()`.
2. **applyAIMove in** [GameState.swift](TableTopGame/Models/GameState.swift) (lines 356-365): Sets capsule at spawn `(col, orientation)`, then immediately calls `hardDrop()` which runs a `while` loop moving the capsule to the bottom and calling `lockCapsule()` — all in one frame.
3. **Human drop flow**: The drop loop (lines 88-93) uses `dropAccumulator` and `dropInterval` (0.5s) to call `tryMoveDown()` once per tick — visible row-by-row movement.
4. **Result**: AI capsule never appears at intermediate rows; it jumps from spawn to locked in a single frame.

### Confidence

- **Root cause**: 95% — AI uses `hardDrop()` and `update()` returns before the drop loop runs.
- **Solution path**: 92% — Reuse existing `tryMoveDown()` + `dropInterval`; no new animation infra needed.

---

## Decomposed chunks

### Chunk A1: GameState — Place-only API

**File**: [GameState.swift](TableTopGame/Models/GameState.swift)

Add optional parameter to `applyAIMove`:

```swift
/// Apply AI-chosen move. When animateDrop is true, only places at spawn; caller drives drop via tryMoveDown.
func applyAIMove(col: Int, orientation: CapsuleOrientation, animateDrop: Bool = false) {
    guard canAcceptInput else { return }
    let grid = gridStates[currentPlayerIndex]
    guard MoveValidator.canPlace(col: col, row: Self.spawnRow, orientation: orientation, in: grid) else { return }
    capsuleCol = col
    capsuleRow = Self.spawnRow
    capsuleOrientation = orientation
    if !animateDrop {
        hardDrop()
    }
}
```

- Default `animateDrop: false` preserves existing test behavior.
- **Verification**: `testGameStateAiSnapshotAndApplyAIMove` and C9 tests pass unchanged.

### Chunk A2: GameScene — Two-phase AI + shared drop loop

**File**: [GameScene.swift](TableTopGame/GameScene.swift)

1. Add `private var aiCapsulePlacedThisTurn = false`.
2. Reset when `currentPlayerIndex == 0`: `aiCapsulePlacedThisTurn = false`.
3. Replace AI block (lines 75-86):
   - **Phase 1 (place)**: When `!aiCapsulePlacedThisTurn`, wait `aiDelay`, then call `applyAIMove(col:orientation:animateDrop: true)`, set `aiCapsulePlacedThisTurn = true`, reset `dropAccumulator = 0`, `layoutGrid()`.
   - **Phase 2 (drop)**: When `aiCapsulePlacedThisTurn`, do **not** return; fall through to drop loop.
4. **Verification**: Manual — AI capsule visible at top, drops row-by-row every ~0.5s.

---

## Technical details

| Item | Detail |
|------|--------|
| Drop speed | Same as human: `dropInterval = 0.5` s. Future: optional `SettingsManager.aiDropSeconds`. |
| `canAcceptInput` | Unchanged; `false` during lock/resolution, so no race. |
| Resolution | `lockCapsule()` runs when `tryMoveDown` can't move; same as human path. |

---

## Validation

1. **Unit**: `xcodebuild test` — C9 tests must pass.
2. **Manual**: Start game, wait for AI turn; observe capsule at top, then dropping row-by-row.
3. **E2E**: Full playthrough (if enabled) completes; AI turns longer but within timeouts.

---

## Risks and rollback

| Risk | Mitigation |
|------|------------|
| E2E timeout if AI turns slow | 0.5s/row; ~8 rows × 0.5s ≈ 4s max per capsule. E2E typically skips full playthrough. |
| `aiCapsulePlacedThisTurn` drift | Reset on human turn. |
| AI has no valid move | Unchanged; pre-existing. |

**Rollback**: Revert GameScene and GameState; restore original `applyAIMove`. Git revert.

---

## Relationship to P002

P002 = gravity animation (post-match). P003 = AI capsule drop (during turn). Independent; either can ship first.
