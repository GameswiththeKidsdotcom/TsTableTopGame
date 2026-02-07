# TabletopGame Specification

Dr. Mario–style 6-player puzzle game. iOS & iPadOS v1. Single-device, offline-only.

---

## Targeting (Option B)

- **6-player targeting**: Garbage targets the next player clockwise.
- When target is eliminated, advance to next non-eliminated player clockwise.
- When all opponents are eliminated, garbage is discarded.

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
- Single-device play; all 6 boards on one screen.
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
