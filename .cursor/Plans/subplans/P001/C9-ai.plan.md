# C9 – AI Opponents

**Outcome**: 1 AI + 1 human play full game (head-to-head). Depends on C8.

---

## Steps

| Step | Task | Validation |
|------|------|------------|
| 1 | AIController interface (receive game state, return move) | Unit test with mock |
| 2 | Random AI (valid column + rotation) | Unit test |
| 3 | Greedy AI (prefer immediate matches — see Detailed Design) | Unit test |
| 4 | Integrate AI into turn loop with delay (~1–2 sec) | Manual test |
| 5 | Assign strategy to the single AI player (opponent) | Manual test |
| 6 | AI contract: full-board returns top-out (no crash); every move legal | Unit test |

---

## Validation

- 1 AI + 1 human play (head-to-head); AI moves automatically

**Test results (Tester)**: Full unit-test suite passed (44 tests, 0 failures). C9 tests: AIController mock, RandomAI, GreedyAI, contract (full-board → nil, every move legal), `testGameStateAiSnapshotAndApplyAIMove` (retry loop for rare spawn-blocked init). Baseline confirmed.

---

## Rollback

1. **Config rollback**: In game/player setup, set the opponent (e.g. Player 1) to human-controlled instead of AI. No removal of AIController code; both players use touch input.
2. **Code rollback**: If integration causes regressions, revert the integration point (e.g. remove AI branch in turn loop or coordinator) so that both players remain human-controlled until AI is re-integrated.

---

## Detailed Design

- **AIController interface**: Input = read-only snapshot of current player’s state: grid, capsule colors (left/right), list of valid (col, orientation) at spawn (row 0). Output = single move: (col, orientation). Valid placements: all (col, orientation) where `MoveValidator.canPlace(col: col, row: 0, orientation: orientation, in: grid)` is true (spawn row = 0, 8 cols, 4 orientations; wall kick not needed at spawn).
- **Integration point**: Caller (e.g. GameScene or a coordinator) checks `currentPlayerIndex == aiPlayerIndex`; when true, after ~1–2 s delay requests move from AIController, then applies it. Application: set capsule to (col, orientation) at spawn and perform hard-drop. Prefer a single `GameState` method e.g. `applyAIMove(col:orientation:)` that sets capsule at spawn to the given col/orientation (if valid) and calls the existing lock/resolve/advance flow (same as hardDrop path) so AI and human share the same resolution and turn-advance logic.
- **Greedy “prefer immediate matches”**: For each valid (col, orientation), simulate: place capsule at spawn with that col/orientation, run match+gravity resolution once (no garbage applied). Score = number of virus cells cleared in that resolution (or, if virus count not available in simulator, total match cells removed). Choose the placement with **maximum score**. Tie-break: deterministic (e.g. smallest column, then first orientation in a fixed order). This fully specifies the strategy for implementation and tests.

---

## Best Routes Ahead of Building

1. **Recommended order**: (1) Define AIController protocol and a snapshot type for “current grid + capsule + valid moves”; (2) Implement Random AI and unit test; (3) Implement Greedy (simulate placement + resolution, score by virus clears or match size, max + tie-break) and unit test; (4) Add AI contract tests (full board → top-out; every returned move legal); (5) In GameState (or coordinator), add `applyAIMove(col:orientation:)` and call it from the view/coordinator when `currentPlayerIndex == aiPlayerIndex`, with 1–2 s delay before requesting move; (6) Assign the single AI strategy to the opponent (e.g. Player 1) in game setup.
2. **Alternatives**: Drive AI by replaying tryMoveLeft/Right/tryRotate/hardDrop instead of one-shot apply — possible but more steps and harder to test; one-shot apply is preferred. Greedy could score by match count instead of virus clears if virus positions are not exposed in a simulator; document choice in implementation.
3. **Dependencies**: C8 (2 boards, avatars, turn flow) and existing MoveValidator, MatchResolver, GravityEngine, WinConditionChecker. No change to C7 attack/garbage logic beyond using the same lock path.

---

## Confidence

| | Value | Note |
|---|-------|------|
| **Confidence (root cause)** | 92% | Single AI opponent (1 human + 1 AI), AI contract (full-board → top-out, every move legal), and head-to-head scope are clearly stated and aligned with SPEC and Master-Plan. |
| **Confidence (solution path)** | 91% | AIController interface, Random, Greedy (specified: score by virus clears or match size, max + deterministic tie-break), integration via applyAIMove + delay, and contract steps are sufficient. Rollback is stepwise (config then code). Detailed Design and Best Routes give builders enough detail without re-research. Small residual: Greedy simulator may need a shared helper (e.g. on GameState or a dedicated type) for resolution scoring—acceptable to decide at implementation. |
