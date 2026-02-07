# P001 – TabletopGame Spec and Implementation

**Scope**: Dr. Mario–style 6-player puzzle game (Swift/SwiftUI/SpriteKit). iOS & iPadOS v1. Single-device, offline-only.

**Confidence**: 90% (Investigator validated). Platform: v1 iOS/iPadOS only; Android/web = v2.

---

## Feature → Object Map

| Feature | Objects | Chunk |
|---------|---------|-------|
| App shell | TableTopGameApp, ContentView | C1 |
| Grid display | GameScene, GridNode, Grid, SpriteView | C2 |
| Virus display | Virus, PillColor, cell rendering | C3 |
| Capsule control | Capsule, CapsuleNode, input handlers | C4 |
| Match and gravity | MatchResolver, GravityEngine | C5 |
| Turn flow | GameState, WinConditionChecker | C6 |
| Attack system | AttackCalculator, garbage, cash | C7 |
| Multi-board layout | GameView (6 grids), Player, avatar | C8 |
| AI opponents | AIController, Random/Greedy | C9 |
| Menus and flow | MenuView, SettingsManager | C10 |
| Persistence | SettingsManager, UserDefaults | C10 |

---

## Build Chunks (Execute in Order)

| Chunk | Outcome | Sub-Plan |
|-------|---------|----------|
| **C1** | App launches, placeholder in simulator | [P001/archive/C1-bootstrap.plan.md](P001/archive/C1-bootstrap.plan.md) *(archived)* |
| **C2** | Empty 8×16 grid renders | [P001/C2-grid.plan.md](P001/C2-grid.plan.md) |
| **C3** | Viruses visible on grid | [P001/C3-viruses.plan.md](P001/C3-viruses.plan.md) |
| **C4** | Capsule move/rotate/drop playable | [P001/C4-capsule.plan.md](P001/C4-capsule.plan.md) |
| **C5** | Match + gravity work | [P001/C5-match-gravity.plan.md](P001/C5-match-gravity.plan.md) |
| **C6** | Turn flow, win/elimination (2 players) | [P001/C6-turn-flow.plan.md](P001/C6-turn-flow.plan.md) |
| **C7** | Attack + garbage | [P001/C7-attack.plan.md](P001/C7-attack.plan.md) |
| **C8** | 6 boards + avatars | [P001/C8-layout.plan.md](P001/C8-layout.plan.md) |
| **C9** | AI opponents (5 AI + 1 human) | [P001/C9-ai.plan.md](P001/C9-ai.plan.md) |
| **C10** | Menus, game over, restart, settings | [P001/C10-menus.plan.md](P001/C10-menus.plan.md) |

---

## Test Checkpoint Delegation

- **Logic-Test** (P001-LT): After C5, C6, C7, C8—validate move validation, turn/win/tie, garbage targeting, AI contract. See [P001/logic-test.plan.md](P001/logic-test.plan.md).
- **UI-Test**: At C10—E2E user journeys, layout, contrast, iPhone/iPad viewports. Delegate when C10 reaches Test plan ready.

---

## Risks & Rollback

- **SpriteKit–SwiftUI**: Use SpriteView; keep GameScene simple. Rollback: remove SpriteView, fall back to placeholder.
- **Logic bugs**: Logic-Test coverage per sub-plan. Rollback: revert to last passing commit.
- **Plan file**: Full spec (Part A), elaborations, Investigator gap analysis, Logic-Test tables, Infrastructure review, and Phase 1–10 detail: `.cursor/plans/tabletopgame_spec_and_implementation_cafdbc90.plan.md` (comprehensive reference; load when sub-plan needs more context).
