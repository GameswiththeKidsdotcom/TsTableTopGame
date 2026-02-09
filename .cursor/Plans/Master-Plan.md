# Master Plan

## Next hand off (cut & paste)

Execute or validate **C10-V9: Layout and contrast** per [.cursor/Plans/P001/C10-validation-chunks.plan.md](.cursor/Plans/P001/C10-validation-chunks.plan.md). Outcome: GameOverOverlay white-on-black; Restart/Return to Menu buttons tappable; HUD contrast. Agent: UI-Test. After completion, update this prompt and the same section in the sub-plan to the next chunk (C10-V10), and set Code/unit and Manual/UI for C10-V9 in the C10 Validation Chunks table below.

---

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
| P001-E2E-WATCH | E2E watchable boot/wait fix | 1 | Active waits for menu and game HUD; script waits for Simulator boot before tests. Fixes watchable run so app and game are visible during E2E. Plan: [e2e_active_wait_and_simulator_boot](.cursor/plans/e2e_active_wait_and_simulator_boot_afb0c50c.plan.md). Chunks A1–A2 (test), B1–B2 (script), C1–C2 (docs, Master-Plan). | Validated | 95% | 92% |
| P001 | TabletopGame Spec and Implementation | 1 | Dr. Mario–style head-to-head (2-player) puzzle game (Swift/SwiftUI/SpriteKit). Main plan: [.cursor/Plans/P001-tabletopgame.plan.md](.cursor/Plans/P001-tabletopgame.plan.md). Sub-plans: [.cursor/Plans/P001/](.cursor/Plans/P001/) (C1–C10, logic-test, ui-test). C10 validation chunks: [C10-validation-chunks.plan.md](.cursor/Plans/P001/C10-validation-chunks.plan.md) (C10-V1–V11). Execute by build chunks for early iPhone simulator visibility. **Test checkpoints**: Logic-Test after C5–C8; UI-Test at C10. | Test plan ready | N/A | 90% |
| P001-LT | TabletopGame Logic-Test (user move validation) | 1 | Sub-plan of P001. See [.cursor/Plans/P001/logic-test.plan.md](.cursor/Plans/P001/logic-test.plan.md). Validate moves, turns, attack, elimination, win/tie. Delegate Logic-Test agent after C5, C6, C7, C8. | Test plan ready | 92% | 88% |
| P001-UI | TabletopGame UI-Test (E2E, layout, contrast) | 1 | Sub-plan of P001. See [.cursor/Plans/P001/ui-test.plan.md](.cursor/Plans/P001/ui-test.plan.md). E2E user journeys, win/lose/tie overlay validation, iPhone/iPad viewports, layout and contrast. Delegate at C10. | Test plan ready | N/A | N/A |
| P001-E2E | Full playthrough E2E harness | 1 | XCUITest full playthrough: Launch → Menu → New Game → Play until game over → Overlay → Restart/Return to Menu. Chunks E2E-P1–P8. Plan: [.cursor/Plans/P001/E2E-full-playthrough.plan.md](.cursor/Plans/P001/E2E-full-playthrough.plan.md). Watchable improvements: P001-E2E-WATCH. | Test plan ready | N/A | 90% |

---

## P001 Build Chunk Progress (TabletopGame)

When executing P001, track progress by **Planner Build Chunks** (C1–C10). After each chunk, run in iPhone simulator and confirm the visible outcome before advancing.

**Chunk-level confidence**: Updated by Blaster/Investigator when running per-chunk fidelity (Step 5). Each sub-plan file under `.cursor/Plans/P001/` must contain a **Confidence** section; keep this table in sync with those sub-plans.

| Chunk | Outcome | Status | Confidence (root cause) | Confidence (solution path) |
|-------|---------|--------|--------------------------|-----------------------------|
| C1 | App launches, placeholder visible | Done | 95% | 95% |
| C2 | Empty grid renders | Done | 92% | 90% |
| C3 | Viruses visible on grid | Done | 88% | 90% |
| C4 | Capsule move/rotate/drop playable | Done | 90% | 88% |
| C5 | Match + gravity work | Done | 90% | 88% |
| C6 | Turn flow, win/elimination (2 players) | Done | 92% | 90% |
| C7 - Perfected | Attack + garbage | Done | 95% | 95% |
| C8 | 2 boards + avatars (head-to-head) | Done | 92% | 92% |
| C9 | AI opponent (1 AI + 1 human) | Done | 92% | 91% |
| C10 | Menus, game over, restart; settings persist | Code built | 92% | 92% |
| C11 | App Store prep (optional) | — | N/A | N/A |

---

## P001 C10 Validation Chunks (Small Executable Pieces)

C10 code is built. Remaining work decomposed for AI execution. See [.cursor/Plans/P001/C10-validation-chunks.plan.md](.cursor/Plans/P001/C10-validation-chunks.plan.md). **E2E execution strategy** (phases, regression command, XCUITest, builder steps): E2E Optimized Test Plan — use the plan in context or `.cursor/plans/e2e_optimized_test_plan_1e64f74b.plan.md`.

**Plan status**: Chunk plan and confidence validated by Blaster/Investigator/Logic-Test/UI-Test.

**Validation status (two gates):**  
- **Code/unit**: Code path verified + relevant unit tests passed (no app run).  
- **Manual/UI**: App run in simulator or XCUITest and outcome confirmed. Use **Done** when that run has been performed; **—** otherwise.

| Chunk | Outcome | Plan status | Code/unit | Manual/UI | Confidence (root cause) | Confidence (solution path) |
|-------|---------|-------------|-----------|-----------|--------------------------|----------------------------|
| C10-V1 | Launch → Menu → New Game | Validated | Done | — | 92% | 92% |
| C10-V2 | Game Over (win) overlay | Validated | Done | — | 92% | 92% |
| C10-V3 | Game Over (lose) overlay – P0/P1 top-out | Validated | Done | — | 92% | 92% |
| C10-V4 | Game Over (tie) overlay | Validated | Done | — | 92% | 92% |
| C10-V5 | Restart, Return to Menu | Validated | Done | — | 92% | 92% |
| C10-V6 | Settings sheet | Validated | Done | — | 92% | 92% |
| C10-V7 | Settings persist (kill app, relaunch) | Validated | Done | — | 92% | 92% |
| C10-V8 | Viewport layout (iPhone SE, 15 Pro Max, iPad) | Validated | Done | Done | 92% | 92% |
| C10-V9 | Layout and contrast (GameOverOverlay, buttons, HUD) | Validated | Done | — | 92% | 92% |
| C10-V10 | Logic-test E2E (fixture-based; optional) | Validated | Done | — | 90% | 90% |
| C10-V11 | Infrastructure (offline, no network) | Validated | — | — | 92% | 92% |

---

## Adding or updating plans

1. **When creating a new plan**: Add a row to the matrix with a unique Plan ID (e.g. `P001`, or a short slug like `auth-fix`), plan name, priority rank, description, current state, and confidence values (use `N/A` if not applicable, e.g. before analysis).
2. **When advancing a plan**: Update **Current state** (and confidence columns if they change).
3. **When reprioritizing**: Adjust **Priority rank** and reorder rows so rank 1 is at the top; keep the table sorted by priority rank ascending (1 first).

## Where plans live

- **Main plans**: `.cursor/Plans/<plan-id>-<short-name>.plan.md` (e.g. `P001-tabletopgame.plan.md`) — short index with links to sub-plans.
- **Sub-plans**: `.cursor/Plans/<plan-id>/<sub-id>-<short-name>.plan.md` (e.g. `P001/C2-grid.plan.md`) — full steps, validation, rollback per chunk.
- **Archived subplans**: `.cursor/Plans/P001/archive/` — completed and validated chunks (e.g. C1-bootstrap).
- **E2E watchable fix**: `.cursor/plans/e2e_active_wait_and_simulator_boot_afb0c50c.plan.md` — active waits, Simulator boot wait; chunks A1–C2.
- **Comprehensive reference**: `.cursor/plans/tabletopgame_spec_and_implementation_cafdbc90.plan.md` — full spec, elaborations, Investigator gap analysis (load when sub-plan needs more context).
