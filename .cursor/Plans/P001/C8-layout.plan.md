# C8 – Head-to-Head Layout and Avatars (2 Boards)

**Outcome**: Two grids (head-to-head); two avatars; HUD. Always 2 players. Depends on C7.

---

## Detailed Design

### Layout Choice

| Option | Use case | Pros | Cons |
|--------|----------|------|------|
| **Side-by-side** | iPhone landscape, iPad | Mirrors Dr. Mario vs; symmetric; each grid same aspect | Narrow per-grid on small portrait |
| **Top-down** | iPhone portrait | Vertical space; familiar stacking | Less symmetric; narrower columns |
| **Adaptive** | All devices | Best fit per orientation | More logic; deferred to v2 |

**v1 recommendation**: **Side-by-side** on iPhone and iPad. SPEC: "both boards (2 players) on one screen" (docs/SPEC.md). Dr. Mario 2P uses side-by-side bottles. Use `.environment(\.horizontalSizeClass, ...)` or `GeometryReader` to detect orientation; on portrait, optionally stack (top-down) if side-by-side is too cramped.

### Viewport and Sizing

- **Available space**: Full screen minus safe area. Split horizontally for side-by-side: left half = P0, right half = P1.
- **Per-grid size**: Each grid is 8×16 cells. Maintain cell aspect ≈1 (square) or allow slight stretch. `cellSize = min(availableWidth/8, availableHeight/16)` per grid.
- **Rotation**: Support both portrait and landscape. No lock—layout adapts.

### Data Model and Integration

| Component | Current | C8 Change |
|-----------|---------|-----------|
| `GameState` | `gridStates[0]`, `gridStates[1]`; `currentPlayerIndex`; `cash`; `nextCapsuleInQueue()` | Already has 2 grids. Expose `gridState(forPlayer:)` if needed. |
| `GameScene` | Single `gridNode`; `currentGridState()` | Two grid regions (left/right); render both `gridStates[0]` and `gridStates[1]`. Input routes to `currentPlayerIndex`. |
| `ContentView` | Single `SpriteView(scene: scene)` | Wrap scene; add HUD overlay (SwiftUI) or extend scene. |

### Avatars

- Two colored squares (e.g. Player 0 = blue, Player 1 = orange) adjacent to each grid.
- Position: Left of P0 grid; right of P1 grid (or above/below per layout).

### Active Player Highlight

- Border, glow, or background tint on the active player's grid. `currentPlayerIndex` from GameState drives highlight.

### HUD

- **Turn indicator**: "Player 1" / "Player 2" or "Your turn".
- **Cash**: `cash[0]`, `cash[1]` from GameState.
- **Next capsule**: `nextCapsuleInQueue()` — show 1–2 pill previews.

---

## Best Routes Ahead of Building

### Route A: Side-by-Side (Recommended)

1. Split GameScene width in half; render P0 grid left, P1 grid right.
2. Add avatar nodes left of P0, right of P1.
3. Highlight active grid (border/tint) from `currentPlayerIndex`.
4. Add HUD overlay (SwiftUI) over SpriteView: turn, cash, next capsule.

**Pros**: Aligns with Dr. Mario; symmetric; simple. **Cons**: Portrait may feel cramped on small iPhones.

### Route B: Top-Down

1. Split GameScene height; P0 grid top, P1 grid bottom.
2. Avatars above each grid.
3. Same highlight and HUD as Route A.

**Pros**: Better for portrait. **Cons**: Less conventional for vs puzzle.

### Route C: Adaptive

1. Use `GeometryReader`; if `width > height` use side-by-side, else top-down.
2. Same avatar/HUD/highlight logic.

**Pros**: Best UX per orientation. **Cons**: More branches; defer to v2 if time-constrained.

**Recommendation**: **Route A** for C8 build. Validates full head-to-head view; can add adaptive layout in C10 or post-v1.

---

## Integration Points

| Component | Change |
|-----------|--------|
| `GameScene` | Two grid regions; `layoutGrid()` draws both `gridStates[0]` and `gridStates[1]`; touch routing unchanged (current player only). |
| `ContentView` | Optional HUD overlay (VStack/HStack with turn, cash, next capsule) above or beside SpriteView. |
| `GameState` | No structural change; already exposes both grids, currentPlayerIndex, cash, nextCapsuleInQueue. |

---

## Steps

| Step | Task | Validation |
|------|------|-------------|
| 1 | Layout 2 grids side-by-side; split viewport; render both gridStates | Visual check |
| 2 | Player avatars (2 colored squares) next to grids | Visual check |
| 3 | Active player highlight (border/tint on current grid) | Visual check |
| 4 | HUD: turn indicator, cash, next capsule | Visual check |

---

## Validation

- Full tabletop view on screen; 2 boards visible (head-to-head).
- Input affects only current player's grid.

---

## Rollback

Revert to single-board or minimal 2-grid placeholder. Stub HUD so it compiles but shows placeholder text.

---

## Risks

| Risk | Mitigation |
|------|------------|
| Portrait cramped | Route A acceptable for v1; document as known limitation; add adaptive in C10 if needed. |
| Touch targets too small | Cell size = min(halfW/8, h/16) so boards never overlap; on very small screens cells may be < 32pt. Touch zones scoped to active board only. |
| HUD obscures grid | Position HUD at top/bottom or sides; keep grids primary. |

### Known limitations (v1)

- **Portrait cramped:** Side-by-side layout may feel tight on small iPhones in portrait. Adaptive layout (top-down in portrait) deferred to C10 or post-v1.
- **Layout:** Cell size is `min(halfW/8, h/16)` so each grid fits in its half (no overlap). No minimum 32pt; on narrow screens cells may be smaller. Touch input is accepted only inside the active player's grid; left/right/top/middle zones (25%/25%/20%/center) are within that board. In-HUD instructions describe pill controls (see docs/FIXTURES.md).

---

## Confidence

| | Value | Note |
|---|-------|------|
| **Confidence (root cause)** | 92% | Head-to-head layout (2 boards, 2 avatars, HUD) is specified; SPEC and scope aligned. |
| **Confidence (solution path)** | 92% | Layout choice (side-by-side) and sizing approach documented; Route A recommended; integration points and rollback clear. Gap closed from 85%. |

---

## Test run (Tester)

| Date | Command | Result | Note |
|------|---------|--------|------|
| 2026-02-07 | `xcodebuild -scheme TableTopGame -destination 'platform=iOS Simulator,name=iPhone 16' build test` | All tests passed | Full suite; no regressions. |
| 2026-02-07 | Manual visual check (simulator) | Confirmed | User confirmed basics working: 2 boards, avatars, highlight, HUD, input on current player. |
| 2026-02-07 | Remaining tasks | Done | Enforced cell size ≥ 32pt in GameScene; documented known limitations (portrait cramped, touch/clip note). All tests passed. |
| 2026-02-07 | Pill UX + overlap | Done | In-HUD pill instructions; touch zones scoped to active board (25%/25%/20%/center); cell size = min(halfW/8,h/16) so boards never overlap. Doc updated (FIXTURES.md). Changes committed and pushed to GitHub. |
