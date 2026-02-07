# C7 – Attack and Garbage

**Outcome**: Clears send garbage to opponent; cash updates. Depends on C6.

---

## Steps

| Step | Task | Validation |
|------|------|------------|
| 1 | Attack calc (virus clears, chains); cash = 1 per virus | Unit test |
| 2 | Garbage generation (count, colors, Dr. Mario column patterns); attack registers row-major | Unit test |
| 3 | Garbage targeting: next player clockwise; when target eliminated, next non-eliminated; when all eliminated, discard | Unit test |
| 4 | Garbage insertion at top; indestructible until matched | Unit test |
| 5 | Logic-test: garbage never to eliminated; colors match | Unit test |

---

## Validation

- Clears send garbage to opponent; cash increments

---

## Rollback

Disable attack resolution.
