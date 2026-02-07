# Master Plan

This file is the **single source of truth** for plan navigation, priority, and status. All plans created by agents (e.g., Investigator, UI-Test, logic-test, infrastructure) must be registered here so that priority ordering and current state are visible in one place.

## Valid plan states

Use exactly one of these values in the **Current state** column:

| State | Meaning |
|-------|--------|
| **Pending analysis** | Plan not yet fully investigated; root cause or solution path unclear |
| **Validated** | Analysis complete; root cause and solution path documented with confidence scores |
| **Test plan ready** | Test strategy and cases defined; ready for test implementation or code work |
| **Code built** | Implementation done; not yet under test |
| **Testing in progress** | Tests running or in progress |
| **Testing complete** | All tests passed; no open defects from this plan |
| **Defects pending** | Testing found issues; fixes or re-test pending |
| **Complete and ready for github push** | All work verified; ready to commit and push |

## Plan matrix

**Priority rank**: 1 = highest priority, then 2, 3, … (descending from highest to lowest).

| Plan ID | Plan name | Priority rank | Description | Current state | Confidence (root cause) | Confidence (solution path) |
|---------|-----------|---------------|-------------|---------------|--------------------------|-----------------------------|
| P001 | TabletopGame Spec and Implementation | 1 | Dr. Mario–style 6-player puzzle game (Swift/SwiftUI/SpriteKit). Main plan: [.cursor/Plans/P001-tabletopgame.plan.md](.cursor/Plans/P001-tabletopgame.plan.md). Sub-plans: [.cursor/Plans/P001/](.cursor/Plans/P001/) (C1–C10, logic-test). Execute by build chunks for early iPhone simulator visibility. **Test checkpoints**: Logic-Test after C5–C8; UI-Test at C10. | Test plan ready | N/A | 90% |
| P001-LT | TabletopGame Logic-Test (user move validation) | 1 | Sub-plan of P001. See [.cursor/Plans/P001/logic-test.plan.md](.cursor/Plans/P001/logic-test.plan.md). Validate moves, turns, attack, elimination, win/tie. Delegate Logic-Test agent after C5, C6, C7, C8. | Test plan ready | N/A | 90% |

---

## P001 Build Chunk Progress (TabletopGame)

When executing P001, track progress by **Planner Build Chunks** (C1–C10). After each chunk, run in iPhone simulator and confirm the visible outcome before advancing.

| Chunk | Outcome | Status |
|-------|---------|--------|
| C1 | App launches, placeholder visible | Done |
| C2 | Empty grid renders | — |
| C3 | Viruses visible on grid | — |
| C4 | Capsule move/rotate/drop playable | — |
| C5 | Match + gravity work | — |
| C6 | Turn flow, win/elimination (2 players) | — |
| C7 | Attack + garbage | — |
| C8 | 6 boards + avatars | — |
| C9 | AI opponents | — |
| C10 | Menus, game over, restart; settings persist | — |
| C11 | App Store prep (optional) | — |

---

## Adding or updating plans

1. **When creating a new plan**: Add a row to the matrix with a unique Plan ID (e.g. `P001`, or a short slug like `auth-fix`), plan name, priority rank, description, current state, and confidence values (use `N/A` if not applicable, e.g. before analysis).
2. **When advancing a plan**: Update **Current state** (and confidence columns if they change).
3. **When reprioritizing**: Adjust **Priority rank** and reorder rows so rank 1 is at the top; keep the table sorted by priority rank ascending (1 first).

## Where plans live

- **Main plans**: `.cursor/Plans/<plan-id>-<short-name>.plan.md` (e.g. `P001-tabletopgame.plan.md`) — short index with links to sub-plans.
- **Sub-plans**: `.cursor/Plans/<plan-id>/<sub-id>-<short-name>.plan.md` (e.g. `P001/C1-bootstrap.plan.md`) — full steps, validation, rollback per chunk.
- **Comprehensive reference**: `.cursor/plans/tabletopgame_spec_and_implementation_cafdbc90.plan.md` — full spec, elaborations, Investigator gap analysis (load when sub-plan needs more context).
