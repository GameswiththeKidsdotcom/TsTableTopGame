# C10 – Menus and Polish

**Outcome**: Menu → game → game over → restart; settings persist. Depends on C9.

---

## Steps

| Step | Task | Validation |
|------|------|------------|
| 1 | Main menu (New Game, Settings); SettingsManager (UserDefaults: sound, AI delay) | Manual test |
| 2 | Game over screen (winner, stats) | Manual test |
| 3 | Restart / return to menu | Manual test |
| 4 | Logic-test E2E: seeded RNG; force single-player-left, tie, full game; restart clean | Integration test |
| 5 | Settings persist across sessions | Manual test: kill app, relaunch; confirm sound and AI delay values |
| 6 | Infrastructure: offline spec; no network calls; optional CI | Static/manual verification |

---

## Validation

- Complete flow: launch → game → game over → restart
- Settings persist across sessions
- Offline-only; no network calls (SPEC compliant)
- **Lose scenarios (UI)**: When P0 top-outs, overlay shows "Player 2 wins!"; when P1 top-outs, overlay shows "Player 1 wins!". Tie shows "Tie!". See [P001/ui-test.plan.md](ui-test.plan.md).

---

## Rollback

Launch directly into game. Remove MenuView; TableTopGameApp → ContentView; ContentView launches GameScene directly.

---

## Detailed Design

### App flow and state

- **Root coordinator**: `TableTopGameApp` shows a coordinator view that switches between `MenuView` and `GameView`. No navigation stack required; use `@State enum AppPhase { case menu, playing }` to drive the root. Alternative: `NavigationStack` with MenuView as root and `.fullScreenCover` for game.
- **MenuView**: Main menu with two buttons: **New Game**, **Settings**. New Game sets `AppPhase = .playing` and presents `GameView`. Settings presents `SettingsView` as a sheet.
- **SettingsView**: Sheet with toggles/sliders for (1) **Sound** (on/off), (2) **AI delay** (seconds, e.g. 0.5–3.0). Reads/writes via `SettingsManager`. Dismiss returns to MenuView.
- **GameView**: Wraps `ContentView`-style layout (SpriteView + HUD). Receives `onRestart` and `onReturnToMenu` callbacks. When `phase == .gameOver`, shows a **GameOverOverlay** on top with winner/stats, **Restart** and **Return to Menu** buttons.
- **GameOverOverlay**: Semi-transparent overlay with `Text(winner/stats)` and two buttons. Restart → call `onRestart`. Return to Menu → call `onReturnToMenu`.

### SettingsManager

- **Storage**: `UserDefaults` only (SPEC: persistence via UserDefaults).
- **Keys**: `"soundEnabled"` (Bool, default true), `"aiDelaySeconds"` (Double, default 1.5).
- **API**: `SettingsManager.shared.soundEnabled`, `aiDelaySeconds`; setters persist immediately. Use `@Published` or Combine if SwiftUI bindings needed.
- **Integration**: `GameScene` (or GameView) reads `SettingsManager.shared.aiDelaySeconds` and uses it for the AI turn delay. Currently hardcoded at 1.5 in `GameScene.aiDelay`.

### Game over and restart

- **Game over detection**: Already in place via `GameState.phase == .gameOver(winnerId:isTie:)`. HUD shows "Player X wins!" or "Tie!" inline; C10 adds a dedicated overlay with Restart/Return to Menu.
- **Restart**: Create a new `GameState(level: 0)`, new `GameScene` (or reset existing scene's `gameState` and re-layout). Ensure `stateDisplay` is updated. No persistence of in-progress games (SPEC: offline, no save/resume).
- **Return to Menu**: Set `AppPhase = .menu`; coordinator shows MenuView. GameView is dismissed; next New Game creates fresh GameView + GameScene.

### Integration points (components that change)

| Component | Change |
|-----------|--------|
| `TableTopGameApp` | Root becomes coordinator (MenuView \| GameView) instead of ContentView directly |
| `ContentView` | Becomes `GameView` or wrapped; adds GameOverOverlay, receives onRestart/onReturnToMenu |
| `GameScene` | Reads `SettingsManager.shared.aiDelaySeconds` instead of hardcoded 1.5; optional: `aiDelay` passed in init |
| **New** | `MenuView`, `SettingsView`, `SettingsManager`, `GameOverOverlay` |
| **New** | Coordinator view (e.g. `RootView` or extend `ContentView` to host menu/game switch) |

### E2E logic-test (Step 4) – seeded RNG

- **Current**: `GameState` uses `Int.random` and `PillColor.allCases.randomElement()` in `makeInitialViruses` and `refillCapsuleQueue`. No injection point.
- **Options**: (A) Inject `RandomNumberGenerator` into `GameState` init; (B) Add `GameState(level:virusesPerPlayer:capsuleQueue:)` init accepting fixtures. **Recommend B**: test-only init with pre-built virus positions and capsule queue. Production continues to use `GameState(level:)`. E2E tests use fixture-based init to force single-player-left, tie, full game, restart clean without changing production RNG.
- **Force scenarios**: Use fixtures (e.g. one player nearly empty, one full) or drive `GameState` to target phase via controlled moves. Logic-test plan: seeded/fixture-based init → assert phase and outcomes.

### Sound

- **v1**: Toggle stored in UserDefaults. No audio playback required for C10; stub for future. Validation: toggle persists across sessions.

---

## Best Routes Ahead of Building

### Recommended order

1. **SettingsManager** – Create `SettingsManager` (singleton or `@ObservableObject`) with UserDefaults keys for `soundEnabled` and `aiDelaySeconds`. Unit test: set/get values, verify persistence (or mock UserDefaults).
2. **MenuView** – Simple SwiftUI view with New Game and Settings. New Game sets coordinator state to `.playing`. Settings presents SettingsView as sheet.
3. **Coordinator/RootView** – Add `RootView` (or equivalent) with `@State AppPhase`; root shows MenuView when `.menu`, GameView when `.playing`. Wire TableTopGameApp → RootView.
4. **GameView** – Extract current ContentView body into GameView; add `onRestart` and `onReturnToMenu` callbacks. Pass callbacks from coordinator.
5. **GameOverOverlay** – Overlay on GameView when `phase == .gameOver`. Show winner/stats (from GameStateDisplay), Restart and Return to Menu buttons.
6. **Restart** – Implement `onRestart`: create new GameState, new GameScene (or reset), update stateDisplay. Wire to Restart button.
7. **Return to Menu** – Implement `onReturnToMenu`: set AppPhase = .menu. Wire to Return to Menu button.
8. **SettingsView** – Sheet with sound toggle and AI delay slider; bind to SettingsManager.
9. **GameScene aiDelay** – Replace hardcoded 1.5 with `SettingsManager.shared.aiDelaySeconds`. Pass into GameScene or read on each AI turn.
10. **Settings persist** – Manual test: change settings, kill app, relaunch; confirm values.
11. **Infrastructure** – Confirm no network calls; optional CI.

### Alternatives and trade-offs

| Choice | Alternative | Pros / Cons |
|--------|-------------|-------------|
| Coordinator with enum | NavigationStack | Enum: simpler, no nav stack. NavStack: standard iOS pattern, back gesture. Enum preferred for single-device game. |
| GameOverOverlay | Separate GameOverView | Overlay: stays in context, quick. Separate: cleaner separation. Overlay preferred. |
| Settings as sheet | Settings as push | Sheet: quick, dismiss easily. Push: standard. Sheet preferred. |
| Fixture-based GameState init | Injected RNG | Fixtures: no production change, test-only. Injected RNG: affects production. Fixtures preferred for E2E. |

### Dependencies

- C9 (AI): Complete. GameScene uses AIController; only change is aiDelay from SettingsManager.
- C8 (layout): Complete. GameView reuses ContentView layout (SpriteView + HUD).
- GameState, GamePhase, GameStateDisplay: No API changes except optional fixture init for tests.

### Risks and rollback

- **Risk**: Coordinator state can get out of sync (e.g. game over but overlay not showing). **Mitigation**: Single source of truth in GameStateDisplay.phase; overlay binds to it.
- **Risk**: SettingsManager read before UserDefaults ready. **Mitigation**: Lazy init; defaults provided.
- **Rollback**: Remove MenuView, RootView; TableTopGameApp → ContentView; ContentView launches GameScene directly. Restore hardcoded aiDelay in GameScene.

---

## Confidence

| | Value | Note |
|---|-------|------|
| **Confidence (root cause)** | 92% | Outcome clear: menu, game over, restart, settings persist, offline spec. Step 5/6 split removes scope blend. |
| **Confidence (solution path)** | 92% | Steps 1–6 single-purpose; task/validation aligned per step; rollback explicit. Detailed Design and Best Routes give builders sufficient technical detail without re-research. |
