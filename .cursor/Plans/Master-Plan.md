# Master Plan
##Prioritize 
- regression fixes
- defect corrections
- app store compliance
- new features

Always ensure analysis is performed prior to a builder agent working on the plan. 

## Concurrent agents (max 2)

At most **two agents** may work in parallel. Two hand offs are allowed only when their work **does not conflict**.

**Conflicts (do not run both if any apply):**
- Same file or overlapping file set is edited by both.
- Same plan chunk or same sub-plan is executed by both.
- Both update the same Master-Plan row or same plan state.
- One change depends on the other's outcome (order required).

**Non-conflicting examples (safe for two agents):**
- **Lane A** in app code (e.g. `GameState.swift`), **Lane B** in test code only (e.g. `TableTopGameUITests.swift` or `TableTopGameTests.swift`) with no shared files.
- **Lane A** UI-Test / E2E (XCUITest), **Lane B** Logic-Test / unit tests (no app code edits).
- **Lane A** one sub-plan or chunk (e.g. P001-E2E-WATCH A2), **Lane B** a different sub-plan or chunk with no file overlap (e.g. P001 C10 validation in a different area).
- One agent runs tests only (read-only validation) while the other edits a disjoint set of files.

When in doubt, run one agent at a time. Planner: when updating hand offs, if a second non-conflicting task exists, add it under **Second hand off** and state the non-conflict reason briefly.

---

## Next hand off (cut & paste) — Lane A

**P002 G2 — GameState step-wise resolution.** [P002-gravity-animation.plan.md](.cursor/Plans/P002/P002-gravity-animation.plan.md). G1 complete. Builder: add `isResolving`, `ResolutionStep`, `advanceResolutionStep()`; refactor `lockCapsule()`. Logic-Test checkpoint after G2. Plan: `.cursor/Plans/P002/P002-gravity-animation.plan.md`.

## Second hand off (cut & paste) — Lane B

**P006 G1 — Level selection** (Builder). [P006-G1-level-selection.plan.md](.cursor/Plans/P006/P006-G1-level-selection.plan.md). Add level picker to Settings; pass to GameState(level:). No conflict with Lane A (P002 G1 touches GravityEngine; P006 G1 touches SettingsManager, GameView).

**C11-A1**: Done. **C11-A2**: Done. **C11-A3**: Deferred until P005 monetization built; runbook ready ([asc-setup-runbook.md](.cursor/Plans/P001-C11/asc-setup-runbook.md)).


### Next priorities (summary)

| Priority | What | Agent | Plan / notes |
|----------|------|--------|---------------|
| 1 | P002 G2 — GameState step-wise resolution (G1 done) | Builder, Logic-Test | P002/P002-gravity-animation.plan.md |
| 2 | P001-RestartFix — Complete (R1+R2 done 2026-02-14) | — | P001-RestartFix/P001-RestartFix.plan.md |
| 3 | E2E full playthrough — complete (full suite green 2026-02-08; E2E-P8 implemented) | — | .cursor/Plans/P001/E2E-full-playthrough.plan.md |
| 4 | P001-C11 App Store prep (A4, A5) | Builder, human | P001-C11/P001-C11-app-store.plan.md (chunks A1–A5) |
| 5 | P006 Spec gaps (G1 Level, G2 AI strength, G3 ContentView) | Builder | P006/P006-spec-gaps.plan.md (G1–G3) |
| 6 | P003 AI animated drop | Builder | P003/P003-ai-animated-drop.plan.md (chunks A1–A2) |
| 7 | C10 Manual/UI validation — complete (all C10-V1–V11 done 2026-02-08) | — | C10-validation-chunks.plan.md |
| 8 | P004 Power-up System — Pending | Investigator, Builder | .cursor/Plans/P004/P004-power-up-planner-review.md |
| 9 | P005 Monetization — Pending | Investigator, Builder | P005/P005-monetization.plan.md (M1–M6) |
| — | C11-A3 ASC setup (human) | Human | After P005 (and P004) built; runbook ready |

*P002 G1 next. P001-RestartFix R1+R2 complete. C11-A1/A2 done; C11-A3 deferred until P005 built. P006 (spec gaps) fleshed out; features-for-planner.md provides elaboration for Planner. P003 queued after P001-C11. P005: paid = no ads, power-ups anytime; free = ads after win only.*

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
| P001-RestartFix | Restart button at game over | 2 | Restart button at game ending does not work. Root cause: SpriteView does not replace presented SKScene when scene parameter changes. Fix: `.id(sceneIdentity)` on SpriteView; change identity in startNewGame(). Plan: [P001-RestartFix.plan.md](.cursor/Plans/P001-RestartFix/P001-RestartFix.plan.md). **R1+R2 complete 2026-02-14**; `testGameOverRealGameRestart` added. | Testing complete | 92% | 90% |
| P001-E2E-WATCH | E2E watchable boot/wait fix | 2 | Active waits for menu and game HUD; script waits for Simulator boot before tests. Fixes watchable run so app and game are visible during E2E. Plan: [e2e_active_wait_and_simulator_boot](.cursor/Plans/P001-E2E-WATCH/e2e_active_wait_and_simulator_boot_afb0c50c.plan.md). **All chunks done** (A1–C2). **Pushed 2026-02-08.** | Complete and ready for github push | 95% | 92% |
| P001 | TabletopGame Spec and Implementation | 2 | Dr. Mario–style head-to-head (2-player) puzzle game (Swift/SwiftUI/SpriteKit). Main plan: [.cursor/Plans/P001/P001-tabletopgame.plan.md](.cursor/Plans/P001/P001-tabletopgame.plan.md). Sub-plans: [.cursor/Plans/P001/](.cursor/Plans/P001/) (C1–C10, logic-test, ui-test). C10 validation chunks: [C10-validation-chunks.plan.md](.cursor/Plans/P001/C10-validation-chunks.plan.md) (C10-V1–V11). Execute by build chunks for early iPhone simulator visibility. **Test checkpoints**: Logic-Test after C5–C8; UI-Test at C10. | Complete and ready for github push | N/A | 90% |
| P001-LT | TabletopGame Logic-Test (user move validation) | 2 | Sub-plan of P001. See [.cursor/Plans/P001/logic-test.plan.md](.cursor/Plans/P001/logic-test.plan.md). Validate moves, turns, attack, elimination, win/tie. Delegate Logic-Test agent after C5, C6, C7, C8. | Testing complete | 92% | 88% |
| P001-UI | TabletopGame UI-Test (E2E, layout, contrast) | 2 | Sub-plan of P001. See [.cursor/Plans/P001/ui-test.plan.md](.cursor/Plans/P001/ui-test.plan.md). E2E user journeys, win/lose/tie overlay validation, iPhone/iPad viewports, layout and contrast. Delegate at C10. | Testing complete | N/A | N/A |
| P001-E2E | Full playthrough E2E harness | 2 | XCUITest full playthrough: Launch → Menu → New Game → Play until game over → Overlay → Restart/Return to Menu. Chunks E2E-P1–P8. Plan: [.cursor/Plans/P001/E2E-full-playthrough.plan.md](.cursor/Plans/P001/E2E-full-playthrough.plan.md). Watchable improvements: P001-E2E-WATCH. **Full suite green 2026-02-08** (unit + UI on iPhone 16). E2E-P8 viewport matrix implemented (testC10V8 + CI). | Testing complete | N/A | 90% |
| P002 | Gravity drop animation | 3 | Animated gravity when matches cleared; pips drop slowly to final position. Plan: [.cursor/Plans/P002/P002-gravity-animation.plan.md](.cursor/Plans/P002/P002-gravity-animation.plan.md). Chunks G1–G4. **G1 complete** (applyReturningMoves); G2 next. | Code built (G1) | 95% | 90% |
| P001-C11 | App Store prep | 4 | Gap strategy for App Store submission. Plan: [.cursor/Plans/P001-C11/P001-C11-app-store.plan.md](.cursor/Plans/P001-C11/P001-C11-app-store.plan.md). Sub-plans: [.cursor/Plans/P001-C11/](.cursor/Plans/P001-C11/) (C11-A1–A5). Chunks: App icon, Support URL, ASC metadata, screenshots, upload/submit. A3 sequenced after P005 built; runbook will be updated for IAP/ads. | Validated | 92% | 90% |
| P006 | Spec gap features | 5 | Level selection UI, AI strength (Easy/Hard), ContentView cleanup. Plan: [P006-spec-gaps.plan.md](.cursor/Plans/P006/P006-spec-gaps.plan.md). Sub-plans: [P006/](.cursor/Plans/P006/) (G1–G3). Reference: [features-for-planner.md](.cursor/Plans/features-for-planner.md). | Validated | 98% | 95% |
| P003 | AI animated drop | 6 | AI capsule drops row-by-row (visible) instead of instant hard-drop. Plan: [.cursor/Plans/P003/P003-ai-animated-drop.plan.md](.cursor/Plans/P003/P003-ai-animated-drop.plan.md). Chunks A1 (GameState place-only), A2 (GameScene two-phase AI). | Validated | 95% | 92% |
| P004 | Power-up System | 7 | Purchase power-ups with cash; hold 1; Clear Row, Send Garbage, Double Cash. AI same rules. Planner review: [P004-power-up-planner-review.md](.cursor/Plans/P004/P004-power-up-planner-review.md). Main plan and sub-plans (P1–P5) to be created per review. | Pending analysis | N/A | N/A |
| P005 | Monetization | 8 | Paid = no ads, power-ups anytime; free = ads after win only, power-ups turn-only. Plan: [P005-monetization.plan.md](.cursor/Plans/P005/P005-monetization.plan.md). Sub-plans: [P005/](.cursor/Plans/P005/) (M1–M6: IAPManager, Paywall, ASC, StoreKit testing, Ads after win, Power-up gating). | Pending analysis | N/A | N/A |

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
| C10 | Menus, game over, restart; settings persist | Done | 92% | 92% |
| C11 | App Store prep | A1–A2 done; A3 deferred until P005 built; runbook ready | 92% | 90% |

**C11 chunks (P001-C11)**: A1 App icon, A2 Support URL, A3 ASC setup, A4 Screenshots, A5 Upload/submit. See [P001-C11-app-store.plan.md](.cursor/Plans/P001-C11/P001-C11-app-store.plan.md).

---

## P001 C10 Validation Chunks (Small Executable Pieces)

C10 code is built. Remaining work decomposed for AI execution. See [.cursor/Plans/P001/C10-validation-chunks.plan.md](.cursor/Plans/P001/C10-validation-chunks.plan.md). **E2E execution strategy** (phases, regression command, XCUITest, builder steps): See C10-validation-chunks.plan.md and E2E-full-playthrough.plan.md; use E2E optimized test plan in context if referenced elsewhere.

**Plan status**: Chunk plan and confidence validated by Blaster/Investigator/Logic-Test/UI-Test.

**Validation status (two gates):**  
- **Code/unit**: Code path verified + relevant unit tests passed (no app run).  
- **Manual/UI**: App run in simulator or XCUITest and outcome confirmed. Use **Done** when that run has been performed; **—** otherwise.

| Chunk | Outcome | Plan status | Code/unit | Manual/UI | Confidence (root cause) | Confidence (solution path) |
|-------|---------|-------------|-----------|-----------|--------------------------|----------------------------|
| C10-V1 | Launch → Menu → New Game | Validated | Done | Done | 92% | 92% |
| C10-V2 | Game Over (win) overlay | Validated | Done | Done | 92% | 92% |
| C10-V3 | Game Over (lose) overlay – P0/P1 top-out | Validated | Done | Done | 92% | 92% |
| C10-V4 | Game Over (tie) overlay | Validated | Done | Done | 92% | 92% |
| C10-V5 | Restart, Return to Menu | Validated | Done | Done | 92% | 92% |
| C10-V6 | Settings sheet | Validated | Done | Done | 92% | 92% |
| C10-V7 | Settings persist (kill app, relaunch) | Validated | Done | Done | 92% | 92% |
| C10-V8 | Viewport layout (iPhone SE, 15 Pro Max, iPad) | Validated | Done | Done | 92% | 92% |
| C10-V9 | Layout and contrast (GameOverOverlay, buttons, HUD) | Validated | Done | Done | 92% | 92% |
| C10-V10 | Logic-test E2E (fixture-based; optional) | Validated | Done | Done | 90% | 90% |
| C10-V11 | Infrastructure (offline, no network) | Validated | Done | Done | 92% | 92% |

---

## Adding or updating plans

1. **When creating a new plan**: Add a row to the matrix with a unique Plan ID (e.g. `P001`, or a short slug like `auth-fix`), plan name, priority rank, description, current state, and confidence values (use `N/A` if not applicable, e.g. before analysis).
2. **When advancing a plan**: Update **Current state** (and confidence columns if they change).
3. **When reprioritizing**: Adjust **Priority rank** and reorder rows so rank 1 is at the top; keep the table sorted by priority rank ascending (1 first).

## Where plans live

- **Master-Plan**: `.cursor/Plans/Master-Plan.md` — only file at parent level.
- **Main plans (index)**: `.cursor/Plans/<plan-id>/<plan-id>-<short-name>.plan.md` (e.g. `P001/P001-tabletopgame.plan.md`) — short index with links to sub-plans.
- **Sub-plans**: `.cursor/Plans/<plan-id>/<sub-id>-<short-name>.plan.md` (e.g. `P001/C2-grid.plan.md`) — full steps, validation, rollback per chunk.
- **Archived subplans**: `.cursor/Plans/P001/archive/` — completed and validated chunks (e.g. C1-bootstrap).
- **E2E watchable fix (P001-E2E-WATCH)**: `.cursor/Plans/P001-E2E-WATCH/e2e_active_wait_and_simulator_boot_afb0c50c.plan.md` — active waits, Simulator boot wait; chunks A1–C2.
- **Gravity animation (P002)**: `.cursor/Plans/P002/P002-gravity-animation.plan.md` — pips drop slowly when matches cleared; chunks G1–G4.
- **App Store prep (P001-C11)**: `.cursor/Plans/P001-C11/P001-C11-app-store.plan.md` — index; sub-plans under `.cursor/Plans/P001-C11/` (C11-A1–A5).
- **AI animated drop (P003)**: `.cursor/Plans/P003/P003-ai-animated-drop.plan.md` — AI capsule drops row-by-row; chunks A1–A2.
- **Power-up (P004)**: Planner review at `.cursor/Plans/P004/P004-power-up-planner-review.md`. When ready, create main plan at `P004/P004-power-up.plan.md` and sub-plans under `.cursor/Plans/P004/` (P1–P5).
- **Monetization (P005)**: [P005-monetization.plan.md](.cursor/Plans/P005/P005-monetization.plan.md) — Paid = no ads, power-ups anytime; free = ads after win only. Sub-plans (M1–M6).
- **Spec gaps (P006)**: [P006-spec-gaps.plan.md](.cursor/Plans/P006/P006-spec-gaps.plan.md) — Level selection, AI strength, ContentView cleanup. Sub-plans (G1–G3).
- **Features for Planner**: [features-for-planner.md](.cursor/Plans/features-for-planner.md) — Elaborated feature set (Investigator + ideation + Blaster scope) for Planner decomposition. Reference when creating or refining plans.

### Plan folder layout (current)

```
.cursor/Plans/
├── Master-Plan.md                      # ONLY file at parent
├── P001-RestartFix/
│   └── P001-RestartFix.plan.md        # Restart button fix
├── P001/
│   ├── P001-tabletopgame.plan.md      # index; links to P001/*
│   ├── archive/
│   │   └── C1-bootstrap.plan.md
│   ├── C2-grid.plan.md … C10-menus.plan.md
│   ├── C10-validation-chunks.plan.md
│   ├── E2E-full-playthrough.plan.md
│   ├── logic-test.plan.md
│   └── ui-test.plan.md
├── P001-C11/
│   ├── P001-C11-app-store.plan.md     # index; chunks A1–A5
│   ├── C11-A1-app-icon.plan.md … C11-A5-upload-submit.plan.md
│   ├── asc-setup-runbook.md
│   └── support-url.md
├── P001-E2E-WATCH/
│   └── e2e_active_wait_and_simulator_boot_afb0c50c.plan.md
├── P002/
│   └── P002-gravity-animation.plan.md  # chunks G1–G4
├── P003/
│   └── P003-ai-animated-drop.plan.md  # chunks A1–A2
├── P004/
│   └── P004-power-up-planner-review.md
├── P006/
│   ├── P006-spec-gaps.plan.md         # index; chunks G1–G3
│   ├── P006-G1-level-selection.plan.md
│   ├── P006-G2-ai-strength.plan.md
│   └── P006-G3-contentview-cleanup.plan.md
├── features-for-planner.md            # elaborated features for Planner
└── P005/
    ├── P005-monetization.plan.md      # index; M1–M6
    ├── M1-iap-manager.plan.md … M4-storekit-testing.plan.md
    ├── M5-ads-after-win.plan.md
    └── M6-powerup-gating.plan.md
```

All matrix links use paths under `.cursor/Plans/` (capital P). Keep sub-plan files small; one logical unit per file.
