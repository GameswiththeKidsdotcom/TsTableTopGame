# C4 – Playable Single Grid (Capsule Control)

**Outcome**: User can move, rotate, drop capsule; it locks. Depends on C3.

---

## Steps

| Step | Task | Validation |
|------|------|------------|
| 1 | Capsule rendering with rotation states | Visual check |
| 2 | Capsule spawn at top; horizontal movement (left/right) | Manual test |
| 3 | Rotation (CW/CCW) with wall kick (vertical→horizontal, blocked right, shift left 1) | Manual test |
| 4 | Soft drop, hard drop | Manual test |
| 5 | Collision and lock on landing | Manual test |
| 6 | Move validator: reject when blocked or OOB; rotation validator | Unit test |

---

## Validation

- User can move, rotate, drop; capsule locks
- No invalid grid state from allowed inputs

---

## Rollback

Disable input handlers; grid still renders.

---

## Confidence

| | Value | Note |
|---|-------|------|
| **Confidence (root cause)** | 90% | Capsule control, lock behavior, and wall kick (vertical→horizontal, blocked right, shift left 1) are well specified. |
| **Confidence (solution path)** | 88% | Move/rotate/drop and validators cover scope; wall kick explicit. Gap: lock timing (immediate vs delay) not stated; rollback clear. |
