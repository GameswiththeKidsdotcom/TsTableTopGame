---
name: ""
overview: ""
todos: []
isProject: false
---

# P001 – TabletopGame Spec and Implementation

**Scope**: Dr. Mario–style head-to-head (2-player) puzzle game (Swift/SwiftUI/SpriteKit). iOS & iPadOS v1. Single-device, offline-only.

**Confidence**: 90% (Investigator validated). Platform: v1 iOS/iPadOS only; Android/web = v2.

**Next hand off (cut & paste)**: See [Master-Plan.md](../Master-Plan.md) or [C10-validation-chunks.plan.md](C10-validation-chunks.plan.md) for the current executable prompt.

---

## Feature → Object Map


| Feature                           | Objects                               | Chunk          |
| --------------------------------- | ------------------------------------- | -------------- |
| App shell                         | TableTopGameApp, ContentView          | C1             |
| Grid display                      | GameScene, GridNode, Grid, SpriteView | C2             |
| Virus display                     | Virus, PillColor, cell rendering      | C3             |
| Capsule control                   | Capsule, CapsuleNode, input handlers  | C4             |
| Match and gravity                 | MatchResolver, GravityEngine          | C5             |
| Turn flow                         | GameState, WinConditionChecker        | C6             |
| Attack system                     | AttackCalculator, garbage, cash       | C7 - Perfected |
| Multi-board layout (head-to-head) | GameView (2 grids), Player, avatar    | C8             |
| AI opponent (head-to-head)        | AIController, Random/Greedy           | C9             |
| Menus and flow                    | MenuView, SettingsManager             | C10            |
| Persistence                       | SettingsManager, UserDefaults         | C10            |


---

## Build Chunks (Execute in Order)


| Chunk              | Outcome                                | Sub-Plan                                                                            |
| ------------------ | -------------------------------------- | ----------------------------------------------------------------------------------- |
| **C1**             | App launches, placeholder in simulator | [archive/C1-bootstrap.plan.md](archive/C1-bootstrap.plan.md) *(archived)* |
| **C2**             | Empty 8×16 grid renders                | [C2-grid.plan.md](C2-grid.plan.md)                                        |
| **C3**             | Viruses visible on grid                | [C3-viruses.plan.md](C3-viruses.plan.md)                                  |
| **C4**             | Capsule move/rotate/drop playable      | [C4-capsule.plan.md](C4-capsule.plan.md)                                  |
| **C5**             | Match + gravity work                   | [C5-match-gravity.plan.md](C5-match-gravity.plan.md)                      |
| **C6**             | Turn flow, win/elimination (2 players) | [C6-turn-flow.plan.md](C6-turn-flow.plan.md)                              |
| **C7 - Perfected** | Attack + garbage                       | [C7-attack.plan.md](C7-attack.plan.md)                                    |
| **C8**             | 2 boards + avatars (head-to-head)      | [C8-layout.plan.md](C8-layout.plan.md)                                    |
| **C9**             | AI opponent (1 AI + 1 human)           | [C9-ai.plan.md](C9-ai.plan.md)                                            |
| **C10**            | Menus, game over, restart, settings    | [C10-menus.plan.md](C10-menus.plan.md)                                    |
| **C10 validation** | Small executable chunks (C10-V1–V11)   | [C10-validation-chunks.plan.md](C10-validation-chunks.plan.md)             |


---

## Test Checkpoint Delegation

- **Logic-Test** (P001-LT): After C5, C6, C7, C8—validate move validation, turn/win/tie, garbage targeting, AI contract. See [logic-test.plan.md](logic-test.plan.md).
- **UI-Test**: At C10—E2E user journeys, layout, contrast, iPhone/iPad viewports. Delegate when C10 reaches Test plan ready.

---

## Risks & Rollback

- **SpriteKit–SwiftUI**: Use SpriteView; keep GameScene simple. Rollback: remove SpriteView, fall back to placeholder.
- **Logic bugs**: Logic-Test coverage per sub-plan. Rollback: revert to last passing commit.
- **Plan file**: Sub-plans under `.cursor/Plans/P001/` are the source of detail. An optional comprehensive reference (single large spec/elaboration file) may be added under `.cursor/Plans/` if needed; see Master-Plan "Where plans live."

