# P001-RestartFix: Reset Button at Game Ending

## Next hand off (cut & paste)

**P001-RestartFix R1 — Complete.** Fix implemented and verified 2026-02-14. Full xcodebuild test passed (44 unit, 14 UI); `testGameOverFixtureRestart` and `testFullPlaythroughUntilGameOver` green. R2 (testGameOverRealGameRestart) optional for real-game path; manual validation sufficient. Ready for github push.

---

## Scope

Fix the Restart button at game ending, which does not work when the user reaches game over through normal play. Root cause identified by Investigator: SwiftUI SpriteView does not replace the presented SKScene when the `scene` parameter changes.

## Feature → Object Map

| Feature | Object | Dependency |
|---------|--------|------------|
| Restart at game over | GameView | GameOverOverlay, SpriteView, GameScene |
| Scene replacement | SpriteView | `.id()` modifier (SwiftUI) |
| State display | GameStateDisplay | GameScene.pushStateToDisplay |

## Investigator Findings (Validated)

- **Root cause:** SpriteView keeps the initial scene in memory and does not replace it when the scene parameter changes. [Stack Overflow reference](https://stackoverflow.com/questions/69610165/spriteview-doesnt-pause-scene-on-state-change).
- **Fixture tests pass** because `-GameOverFixture` uses GameOverFixtureView (different view hierarchy); they never exercise GameView's GameOverOverlay Restart path.
- **Fix:** Use `.id(sceneIdentity)` on SpriteView; change identity in `startNewGame()` so SwiftUI recreates SpriteView and presents the new scene.

## Confidence

| Statement | Confidence |
|-----------|------------|
| Root cause: SpriteView does not replace scene when parameter changes | 92% |
| Fixture path differs and passes for that reason | 95% |
| Fix: `.id()` modifier forces SpriteView recreation | 90% |

## Decomposed Steps

### R1: Implement `.id()` fix (Builder)

1. In [GameView.swift](TableTopGame/GameView.swift), add `@State private var sceneIdentity = UUID()`.
2. In `startNewGame()`, add `sceneIdentity = UUID()` (before or after `scene = s`).
3. Apply `.id(sceneIdentity)` to SpriteView: `SpriteView(scene: scene).id(sceneIdentity).ignoresSafeArea()`.
4. Run full test suite; confirm no regressions.

**Verification:** Manual: play until game over, tap Restart → new game starts. Or run UI test (R2).

### R2: Add UI test for real-game Restart path (UI-Test, optional)

Add `testGameOverRealGameRestart` in [TableTopGameUITests.swift](TableTopGameUITests/TableTopGameUITests.swift) that: launches without `-GameOverFixture`, plays until game over (or uses a deterministic fixture that still goes through GameView's overlay), taps Restart, asserts HUD turn label appears within timeout. Long timeout acceptable for real play path.

## Validation Strategy

- **Manual:** Play full game → game over → tap Restart → confirm new game.
- **Regression:** `testGameOverFixtureRestart`, `testFullPlaythroughUntilGameOver`, full unit suite must pass.

## Risks and Rollback

| Risk | Mitigation |
|------|------------|
| `.id()` causes view churn | Limit to SpriteView only |
| Test regressions | Run full suite before/after |

**Rollback:** Revert the three edits in GameView.swift.
