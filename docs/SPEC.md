# TabletopGame Specification

Dr. Mario–style head-to-head (2-player) puzzle game. iOS & iPadOS v1. Single-device, offline-only.

---

## Targeting (Option B)

- **Head-to-head targeting**: Garbage targets the single opponent.
- When the opponent is eliminated, the game ends (winner).
- When all viruses are cleared (win condition), garbage is irrelevant for that game.

---

## Cash

- **1 cash per virus** cleared.
- **No chain bonus** — only virus clears contribute to cash.

---

## Coordinate System

- **Origin**: Top-left.
- **Row 0**: Spawn row (capsule appears here).
- **Columns**: 0–7 (8 columns total).
- **Rows**: 0–15 (16 rows total).
- **Grid size**: 8×16 cells.

---

## Offline-Only

- No network calls.
- Single-device play; both boards (2 players) on one screen.
- Persistence via UserDefaults only.

---

## Virus Count Formula

Per level (or game start):

```
virusCount = min(4 + level × 2, 50)
```

- Base: 4 viruses.
- Per level: +2 viruses.
- Cap: 50 viruses maximum.
- Colors: Red, Blue, Yellow — balanced distribution.

---

## Platform

- v1: iOS & iPadOS only.
- Swift/SwiftUI/SpriteKit.
- Android/web = v2 (out of scope).
