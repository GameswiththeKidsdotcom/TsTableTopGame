# C7 – Attack and Garbage (C7 - Perfected)

**Outcome**: Clears send garbage to opponent; cash updates. Depends on C6.

---

## Detailed Design

### Attack Calculation

| Concept | Design | Source |
|---------|--------|--------|
| **Cash** | 1 cash per virus cleared; no chain bonus | SPEC (docs/SPEC.md) |
| **Attack input** | Count of clears per resolution; chains = gravity-induced extra matches in same resolution loop | C5 MatchResolver + GravityEngine |
| **Combo vs any-clear** | **v1 choice: Any clear sends garbage** (simpler). NES sends only on combos; we defer combo-only to v2. | Design decision |

### Row-Major Clear Ordering (Attack Registers)

When multiple matches clear in one resolution batch, order determines garbage colors. **Dr. Mario NES** ([wiki.drmar.io Mechanics](https://wiki.drmar.io/index.php?title=Mechanics_(NES)#Trash)):

- **Horizontal clears first**: English reading order (left→right, top→bottom).
- **Vertical clears second**: Mongolian reading order (top→bottom, left→right).

This defines "attack registers" (4 color slots). Colors from clears fill slots 1–4 in that order; excess clears discarded.

### Garbage Column Patterns (Dr. Mario NES Reference)

Trash patterns for 2, 3, or 4 garbage cells ([Trash section](https://wiki.drmar.io/index.php?title=Mechanics_(NES)#Trash)):

| Pending | Pattern | Column offset |
|---------|---------|---------------|
| 2 | `x---x---` (or variants) | frameCounter mod 4 |
| 3 | `x-x-x---` (or variants) | frameCounter mod 4 |
| 4 | `x-x-x-x-` or `-x-x-x-x` | frameCounter mod 2 |

**v1 simplification**: Use fixed patterns (e.g. 2-trash at cols 0,4; 3-trash at 0,2,4; 4-trash alternating) without frame-dependent offset for predictability and testability. Defer NES frame-dependent offset to v2 if desired.

### Garbage Properties

- **Insertion**: Top of grid (row 0); pushes existing content down; garbage is indestructible until matched (4-in-a-row).
- **Targeting**: Single opponent (head-to-head); SPEC: "Garbage targets the single opponent."
- **Elimination**: When opponent top-outs from garbage (or any cause), game ends; C6 handles skip-eliminated and win-on-clear.

### Data Model

| Object | Responsibility |
|--------|----------------|
| `AttackCalculator` | Input: set of cleared positions + colors. Output: virus count (cash), garbage count, garbage colors (from attack registers), garbage positions (from pattern). |
| `GarbageRow` / `GarbageBlock` | Immutable row of colored cells; inserted at top of `GridState`. |
| `Player` / `GameState` | Per-player cash; pending garbage queue (count + colors); opponent id for targeting. |

---

## Best Routes Ahead of Building

### Route A: Full NES Fidelity (High complexity)

1. Attack registers (4 slots); row-major clear ordering.
2. Frame-counter–based column offset for trash patterns.
3. Combo-only garbage (trash only when 2+ clears in one resolution).

**Pros**: Authentic Dr. Mario feel. **Cons**: More code, harder tests, frame-dependent behavior.

### Route B: Simplified v1 (Recommended)

1. **Cash**: Count viruses in `MatchResolver.findMatches` cleared set; 1 per virus.
2. **Garbage**: Any resolution that clears ≥1 match sends garbage. Formula: `garbageCount = min(clearedMatchCount, 4)`.
3. **Colors**: Use row-major ordering over cleared matches to fill up to 4 attack registers.
4. **Pattern**: Fixed patterns (no frame offset): 2 trash → cols 0,4; 3 → 0,2,4; 4 → 0,2,4,6.
5. **Targeting**: Opponent = `(currentPlayerId + 1) % 2` for head-to-head.

**Pros**: Testable, predictable, aligns with SPEC. **Cons**: Slightly less NES-authentic.

### Route C: Minimal (Fastest path)

1. Cash = virus count from clears.
2. Garbage = 1 row per clear (no patterns); single neutral color.
3. Target opponent only.

**Pros**: Fastest to ship. **Cons**: Weak gameplay feel; poor alignment with Dr. Mario.

**Recommendation**: **Route B** for C7 build. Enables Logic-Test coverage and SPEC alignment while keeping scope manageable.

---

## Integration Points

| Component | Change |
|-----------|--------|
| `GravityEngine.resolve` | After each resolution batch: call `AttackCalculator.compute(clearedPositions, clearedColors)` → enqueue garbage for opponent. |
| `GameState` / turn flow (C6) | Per-player `cash`, `pendingGarbage`; apply garbage at "Trash phase" (after clear+gravity, before next pill). |
| `GridState` | `insertGarbageRow(_ row: [(col: Int, color: PillColor)])` — shift content down, place garbage at row 0. |
| `GameScene` | (C8) Two boards; garbage targets opponent board only. |

---

## Steps

| Step | Task | Validation |
|------|------|-------------|
| 1 | Attack calc: virus count → cash (1 per virus); clear count → garbage count (min 4); row-major colors → attack registers | Unit test |
| 2 | Garbage generation: fixed patterns (2/3/4 trash); colors from registers | Unit test |
| 3 | Garbage targeting: opponent = (currentPlayer+1)%2; never to eliminated | Unit test |
| 4 | Garbage insertion at row 0; indestructible until 4-in-a-row | Unit test |
| 5 | Logic-test: garbage never to eliminated; colors match | Unit test |

---

## Validation

- Clears send garbage to opponent; cash increments.
- Garbage appears at top of opponent grid; can be cleared by matching.
- **garbagePositions contract**: For count 1..4, returns non-empty with correct column set (LT-C7-1). **1-clear integration**: Opponent receives visible garbage (LT-C7-2).

---

## Rollback

Disable attack resolution: `AttackCalculator` returns zero garbage; cash still computed but not persisted. Revert `GravityEngine` and `GameState` wiring.

---

## Risks

| Risk | Mitigation |
|------|------------|
| Garbage insertion causes top-out loop | C6 elimination/top-out already handles; garbage is just another board fill. |
| Resolution order differs from NES | Row-major ordering documented; unit tests lock behavior. |
| Two boards not yet present (C8) | C7 can target "opponent grid" abstractly; C8 wires to second board. |

---

## Confidence

| | Value | Note |
|---|-------|------|
| **Confidence (root cause)** | 95% | Attack/garbage, head-to-head targeting, and Dr. Mario column/row-major details explicitly referenced from SPEC and wiki.drmar.io. Design choices (Route B, v1 simplifications) documented. |
| **Confidence (solution path)** | 95% | Steps 1–5, integration points, data model, and Route B recommendation provide sufficient detail for build. Rollback and risks documented. |
