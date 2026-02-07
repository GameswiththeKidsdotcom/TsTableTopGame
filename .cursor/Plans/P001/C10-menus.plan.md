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
| 5 | Infrastructure: offline spec; optional CI; no network calls | Settings persist |

---

## Validation

- Complete flow: launch → game → game over → restart
- Settings persist across sessions

---

## Rollback

Launch directly into game.
