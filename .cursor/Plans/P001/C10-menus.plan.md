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

---

## Confidence

| | Value | Note |
|---|-------|------|
| **Confidence (root cause)** | 88% | Menu flow, game over, restart, and settings persistence are specified. Gap: step 5 mixes three concerns (Logic-test E2E, infrastructure, settings persist); scope blend. |
| **Confidence (solution path)** | 85% | Steps 1–4 cover menu, game over, restart, E2E. Gap: step 5 should be split (E2E, infra, persistence) for clearer validation; rollback clear. Re-invoke Investigator to split step 5 if desired. |
